#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <string.h>

#define MAX_DRIVES 20
#define MAX_PATH 256

// --- 1. Mount Virtual Filesystems ---
void mount_vfs() {
    printf("[Init] Mounting Virtual Filesystems...\n");
    // mount(source, target, filesystemtype, mountflags, data)
    mount("none", "/proc", "proc", 0, "");
    mount("none", "/sys", "sysfs", 0, "");
    mount("none", "/dev", "devtmpfs", 0, "");
}

// --- 2. Hardware Scanning ---
void scan_hardware() {
    printf("[Init] Triggering hardware scan (USB/PCIe)...\n");
    // Call BusyBox's mdev to populate /dev with plugged-in hardware
    system("/bin/busybox mdev -s");
    sleep(2); // Give devices time to register
}

// --- 3. Scan & Menu Selection ---
void interactive_drive_menu(char *selected_drive) {
    FILE *fp;
    char path[MAX_PATH];
    char drives[MAX_DRIVES][MAX_PATH];
    int count = 1;

    printf("\n===========================================\n");
    printf("        OS - Boot Drive Selection      \n");
    printf("===========================================\n");
    printf("Scanning for available filesystems...\n\n");

    // Use BusyBox blkid to find actual formatted drives
    fp = popen("/bin/busybox blkid", "r");
    if (fp == NULL) {
        printf("[!] FATAL: Failed to run blkid.\n");
        execl("/bin/busybox", "busybox", "sh", NULL);
    }

    // Parse the output
    while (fgets(path, sizeof(path), fp) != NULL) {
        // Find the colon (e.g., "/dev/sda1: LABEL=...") to isolate the device path
        char *colon = strchr(path, ':');
        if (colon != NULL) {
            *colon = '\0'; // Terminate the string at the colon
            strncpy(drives[count], path, MAX_PATH);
            // Print the menu option (restoring the colon for display)
            *colon = ':'; 
            printf("  [%d] %s", count, path);
            count++;
        }
    }
    pclose(fp);

    if (count == 1) {
        printf("[!] No filesystems detected. Dropping to shell.\n");
        execl("/bin/busybox", "busybox", "sh", NULL);
    }

    printf("\nSelect the drive to boot from [1-%d]: ", count - 1);
    int choice = 0;
    
    if (scanf("%d", &choice) != 1 || choice < 1 || choice >= count) {
        printf("[!] Invalid selection. Dropping to shell.\n");
        execl("/bin/busybox", "busybox", "sh", NULL);
    }

    strncpy(selected_drive, drives[choice], MAX_PATH);
    printf("[Init] Selected %s for boot.\n", selected_drive);
}

// --- 4. Mount the Main Root ---
void mount_root(const char *target, const char *mountpoint) {
    printf("[Init] Mounting %s to %s...\n", target, mountpoint);
    
    // We use BusyBox mount here because it auto-detects filesystem types (ext4, vfat, etc.)
    char cmd[512];
    snprintf(cmd, sizeof(cmd), "/bin/busybox mount -o ro %s %s", target, mountpoint);
    
    if (system(cmd) != 0) {
        printf("[!] FATAL: Failed to mount %s.\n", target);
        execl("/bin/busybox", "busybox", "sh", NULL);
    }
}

// --- 5. Clean Up ---
void cleanup_vfs() {
    printf("[Init] Cleaning up temporary RAM disk mounts...\n");
    // Unmount in reverse order
    umount("/dev");
    umount("/sys");
    umount("/proc");
}

// --- 6. Handover (Pivot) ---
void boot_dinit(const char *new_root, const char *init_path) {
    printf("[Init] Pivoting root to %s and starting %s...\n", new_root, init_path);
    // Replace the current C program with BusyBox's switch_root utility
    execl("/bin/busybox", "busybox", "switch_root", new_root, init_path, NULL);
}

// --- Main Controller ---
int main() {
    char target_drive[MAX_PATH];

    // 1. Mount VFS
    mount_vfs();

    // 2. Hardware scan (Comment out to disable plug-and-play scanning)
    scan_hardware();

    // 3. Display Menu
    interactive_drive_menu(target_drive);

    // 4. Mount selected drive
    mount_root(target_drive, "/mnt/root");

    // 5. Cleanup
    cleanup_vfs();

    // 6. Pivot to Stage-2 OS
    boot_dinit("/mnt/root", "/sbin/dinit");

    // 7. Ultimate Fallback (If switch_root fails)
    printf("[!] Kernel Panic: switch_root failed!\n");
    execl("/bin/busybox", "busybox", "sh", NULL);

    return 0;
}
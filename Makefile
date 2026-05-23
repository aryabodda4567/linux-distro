CC = gcc

SRC_DIR = src
ROOTFS_DIR = rootfs

# =========================
# Build Type
# Usage:
# make TYPE=dynamic
# make TYPE=static
# =========================

TYPE ?= static

ifeq ($(TYPE),static)
	CFLAGS = -static
else
	CFLAGS =
endif

# =========================
# Find all source files
# =========================

SOURCES := $(shell find $(SRC_DIR) -name "*.c")

# Convert:
# src/sbin/test.c -> rootfs/sbin/test
TARGETS := $(patsubst $(SRC_DIR)/%.c,$(ROOTFS_DIR)/%,$(SOURCES))

# =========================
# Kernel + Initramfs
# =========================

KERNEL ?= bzImage
INITRAMFS ?= initramfs.cpio.gz

# =========================
# Default Target
# =========================

all: build

# =========================
# Build Executables
# Incremental builds:
# only changed files rebuild
# =========================

build: $(TARGETS)

$(ROOTFS_DIR)/%: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@
	@echo "[BUILT $(TYPE)] $< -> $@"

# =========================
# Create initramfs
# =========================

cpio: build
	cd $(ROOTFS_DIR) && \
	find . | cpio -o -H newc | gzip > ../$(INITRAMFS)

	@echo "[CPIO] Created $(INITRAMFS)"

# =========================
# Boot QEMU
# =========================

boot: cpio
	qemu-system-x86_64 \
	-kernel $(KERNEL) \
	-initrd $(INITRAMFS) \
	-m 256M

# =========================
# Clean Generated Files
# =========================

clean:
	find $(ROOTFS_DIR) -type f -executable -delete
	rm -f *.cpio.gz
	@echo "[CLEAN] Done"

# =========================
# Phony Targets
# =========================

.PHONY: all build cpio boot clean

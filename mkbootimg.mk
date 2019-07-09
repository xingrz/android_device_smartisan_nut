DTBTOOL_NAME := dtbToolCM

DTBTOOL := $(HOST_OUT_EXECUTABLES)/$(DTBTOOL_NAME)$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img

possible_dtb_dirs = $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/dts/ $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/

define build-dtimage-target
    $(call pretty,"Target dt image: $@")
    $(hide) for dir in $(possible_dtb_dirs); do \
        if [ -d "$$dir" ]; then \
            dtb_dir="$$dir"; \
            break; \
        fi; \
    done; \
    $(DTBTOOL) $(BOARD_DTBTOOL_ARGS) -o $@ -s $(BOARD_KERNEL_PAGESIZE) -p $(KERNEL_OUT)/scripts/dtc/ "$$dtb_dir";
    $(hide) chmod a+r $@
endef

$(INSTALLED_DTIMAGE_TARGET): $(DTBTOOL) $(INSTALLED_KERNEL_TARGET)
	$(build-dtimage-target)
	@echo -e ${CL_CYN}"Made DT image: $@"${CL_RST}

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_DTIMAGE_TARGET)
ALL_MODULES.$(LOCAL_MODULE).INSTALLED += $(INSTALLED_DTIMAGE_TARGET)

INTERNAL_RECOVERYIMAGE_ARGS += --dt $(INSTALLED_DTIMAGE_TARGET)

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
		$(INSTALLED_DTIMAGE_TARGET) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	@echo -e ${PRT_IMG}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE))
	@echo -e ${PRT_IMG}"----- Made recovery image: $@ --------"${CL_RST}

#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2018 The LineageOS Project
# Copyright (C) 2019 The MoKee Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

DEVICE_PATH := device/smartisan/nut

# Assertions
TARGET_OTA_ASSERT_DEVICE := nut,msm8916_32,msm8916_32_603,msm8916_32_cmcc,msm8916_32_cdma,msm8916_32_younger,msm8916_32_603_younger,msm8916_32_cmcc_younger,msm8916_32_cdma_younger

# Platform
TARGET_BOARD_PLATFORM := msm8916
TARGET_BOOTLOADER_BOARD_NAME := MSM8916

TARGET_NO_BOOTLOADER := true

# Architecture
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53

TARGET_USES_64_BIT_BINDER := true

# ANT+
BOARD_ANT_WIRELESS_DEVICE := "vfs-prerelease"

# Audio
AUDIO_FEATURE_ENABLED_ANC_HEADSET := true
AUDIO_FEATURE_ENABLED_ACDB_LICENSE := true
AUDIO_FEATURE_ENABLED_EXTN_FORMATS := true
AUDIO_FEATURE_ENABLED_KPI_OPTIMIZE := true
AUDIO_FEATURE_ENABLED_MULTI_VOICE_SESSIONS := true
AUDIO_FEATURE_ENABLED_NEW_SAMPLE_RATE := true
BOARD_USES_ALSA_AUDIO := true
USE_CUSTOM_AUDIO_POLICY := 1
USE_XML_AUDIO_POLICY_CONF := 1

# Bluetooth
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(DEVICE_PATH)/bluetooth

# Camera
TARGET_PROCESS_SDK_VERSION_OVERRIDE := \
    /system/vendor/bin/mm-qcamera-daemon=23
    /system/bin/cameraserver=23 \
    /system/bin/mediaserver=23

# Charger
BOARD_CHARGER_ENABLE_SUSPEND := true
BOARD_CHARGER_DISABLE_INIT_BLANK := true
BACKLIGHT_PATH := /sys/class/leds/lcd-backlight/brightness

# Display
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

OVERRIDE_RS_DRIVER := libRSDriver_adreno.so
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS := 0x02000000
TARGET_CONTINUOUS_SPLASH_ENABLED := true
TARGET_FORCE_HWC_FOR_VIRTUAL_DISPLAYS := true
TARGET_USES_ION := true

# Encryption
TARGET_HW_DISK_ENCRYPTION := true
TARGET_PROVIDES_KEYMASTER := true
TARGET_KEYMASTER_WAIT_FOR_QSEE := true

# Exclude serif fonts for saving system.img size.
EXCLUDE_SERIF_FONTS := true

# Filesystem
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_CACHEIMAGE_PARTITION_SIZE := 157286400
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 16777216
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1610612736

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USES_MKE2FS := true
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4

BOARD_ROOT_EXTRA_FOLDERS := firmware bt_firmware persist

# GPS
TARGET_NO_RPC := true
USE_DEVICE_SPECIFIC_GPS := true

# HIDL
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml

# Kernel
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_CMDLINE := console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom user_debug=30 msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_KERNEL_IMAGE_NAME := zImage
BOARD_KERNEL_SEPARATED_DT := true

KERNEL_TOOLCHAIN := $(shell pwd)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-eabi-4.8/bin

TARGET_KERNEL_ARCH := arm
TARGET_KERNEL_CROSS_COMPILE_PREFIX := arm-eabi-
TARGET_KERNEL_SOURCE := kernel/smartisan/msm8939
TARGET_KERNEL_CONFIG := mokee_nut_defconfig

# Manifest
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml

# Media
TARGET_USES_MEDIA_EXTENSIONS := true

# Power
TARGET_POWERHAL_SET_INTERACTIVE_EXT := $(DEVICE_PATH)/power/power_ext.c
TARGET_HAS_LEGACY_POWER_STATS := true
TARGET_HAS_NO_WLAN_STATS := true
TARGET_USES_INTERACTION_BOOST := true

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# QCOM
BOARD_USES_QCOM_HARDWARE := true

# Radio
MALLOC_SVELTE := true

# Recovery
TARGET_RECOVERY_UPDATER_LIBS := librecovery_updater_nut
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/recovery.fstab
BOARD_NO_SECURE_DISCARD := true

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := $(DEVICE_PATH)

# SELinux
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

# Shims
TARGET_LD_SHIM_LIBS := \
    /system/vendor/bin/mm-qcamera-daemon|libshim_camera.so \
    /system/vendor/bin/perfd|libshim_atomic.so \
    /system/vendor/lib/hw/camera.vendor.msm8916.so|libshim_atomic.so \
    /system/vendor/lib/libflp.so|libshims_flp.so \
    /system/vendor/lib/libizat_core.so|libshims_get_process_name.so

# Wi-Fi
BOARD_HAS_QCOM_WLAN := true
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_qcwcn
BOARD_WLAN_DEVICE := qcwcn
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_qcwcn

PRODUCT_VENDOR_MOVE_ENABLED := true
TARGET_DISABLE_WCNSS_CONFIG_COPY := true
TARGET_USES_QCOM_WCNSS_QMI := true

WIFI_DRIVER_FW_PATH_AP := "ap"
WIFI_DRIVER_FW_PATH_STA := "sta"
WPA_SUPPLICANT_VERSION := VER_0_8_X

WIFI_HIDL_FEATURE_DISABLE_AP_MAC_RANDOMIZATION := true

# inherit from the proprietary version
include vendor/smartisan/nut/BoardConfigVendor.mk

#
# Copyright (C) 2014 The CyanogenMod Project
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

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),nut)

include $(call all-makefiles-under,$(LOCAL_PATH))

include $(CLEAR_VARS)

AUDIO_MBHC_BIN_SYMLINK := $(TARGET_OUT_ETC)/firmware/wcd9306/wcd9306_mbhc.bin
$(AUDIO_MBHC_BIN_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Audio MBHC bin link: $@"
	@mkdir -p $(dir $@)
	@rm -f $@
	$(hide) ln -sf /data/misc/audio/mbhc.bin $@

AUDIO_ANC_BIN_SYMLINK := $(TARGET_OUT_ETC)/firmware/wcd9306/wcd9306_anc.bin
$(AUDIO_ANC_BIN_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Audio ANC bin link: $@"
	@mkdir -p $(dir $@)
	@rm -f $@
	$(hide) ln -sf /data/misc/audio/wcd9320_anc.bin $@

ALL_DEFAULT_INSTALLED_MODULES += $(AUDIO_MBHC_BIN_SYMLINK) $(AUDIO_ANC_BIN_SYMLINK)

RFS_MSM_ADSP_SYMLINKS := $(TARGET_OUT)/rfs/msm/adsp/
$(RFS_MSM_ADSP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM ADSP folder structure: $@"
	@rm -rf $@
	@mkdir -p $@/readonly
	$(hide) ln -sf /data/tombstones/lpass $@/ramdumps
	$(hide) ln -sf /persist/rfs/msm/adsp $@/readwrite
	$(hide) ln -sf /persist/rfs/shared $@/shared
	$(hide) ln -sf /persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /firmware $@/readonly/firmware

RFS_MSM_MPSS_SYMLINKS := $(TARGET_OUT)/rfs/msm/mpss/
$(RFS_MSM_MPSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM MPSS folder structure: $@"
	@rm -rf $@
	@mkdir -p $@/readonly
	$(hide) ln -sf /data/tombstones/modem $@/ramdumps
	$(hide) ln -sf /persist/rfs/msm/mpss $@/readwrite
	$(hide) ln -sf /persist/rfs/shared $@/shared
	$(hide) ln -sf /persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /firmware $@/readonly/firmware

ALL_DEFAULT_INSTALLED_MODULES += $(RFS_MSM_ADSP_SYMLINKS) $(RFS_MSM_MPSS_SYMLINKS)

endif

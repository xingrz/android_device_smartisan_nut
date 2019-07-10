#
# Copyright (C) 2019 The MoKee Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_l_mr1.mk)

# Inherit from nut device
$(call inherit-product, device/smartisan/nut/device.mk)

# Inherit some common MK stuff.
$(call inherit-product, vendor/mk/config/common_full_phone.mk)

PRODUCT_PROPERTY_OVERRIDES += \
    ro.mk.maintainer=XiNGRZ

PRODUCT_NAME := mk_nut
PRODUCT_BRAND := SMARTISAN
PRODUCT_DEVICE := nut
PRODUCT_MANUFACTURER := smartisan
PRODUCT_MODEL := YQ601

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME="msm8916_32" \
    PRIVATE_BUILD_DESC="msm8916_32-user 5.1.1 LMY47V 1 release-keys"

BUILD_FINGERPRINT := SMARTISAN/msm8916_32:5.1.1/LMY47V/1:user/release-keys

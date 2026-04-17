#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from honda device
$(call inherit-product, device/oneplus/honda/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_DEVICE := honda
PRODUCT_NAME := lineage_honda
PRODUCT_MANUFACTURER := OnePlus
PRODUCT_BRAND := OnePlus
PRODUCT_MODEL := OnePlus Nord CE5 5G

PRODUCT_GMS_CLIENTID_BASE := android-oneplus

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="CPH2719-user 16 BP2A.250605.015 V.5778546-3527091-352708e release-keys" \
    BuildFingerprint=OnePlus/CPH2719/OP613BL1:16/BP2A.250605.015/V.5778546-3527091-352708e:user/release-keys \
    DeviceName=OP613BL1 \
    DeviceProduct=CPH2719 \
    SystemDevice=OP613BL1 \
    SystemName=CPH2719
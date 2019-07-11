/*
 * Copyright (C) 2016 The Android Open Source Project
 * Copyright (C) 2019 The MoKee Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "light"

#include "Light.h"

#include <android-base/logging.h>

namespace {
using android::hardware::light::V2_0::LightState;

static constexpr int RAMP_DURATION = 400;

static constexpr int DEFAULT_MAX_BRIGHTNESS = 255;

static uint32_t rgbToBrightness(const LightState& state) {
    uint32_t color = state.color & 0x00ffffff;
    return ((77 * ((color >> 16) & 0xff)) + (150 * ((color >> 8) & 0xff)) +
            (29 * (color & 0xff))) >> 8;
}

static bool isLit(const LightState& state) {
    return (state.color & 0x00ffffff);
}
}  // anonymous namespace

namespace android {
namespace hardware {
namespace light {
namespace V2_0 {
namespace implementation {

Light::Light(std::pair<std::ofstream, uint32_t>&& lcd_backlight,
             std::ofstream&& red_led, std::ofstream&& green_led, std::ofstream&& blue_led,
             std::ofstream&& red_ontime, std::ofstream&& red_period, std::ofstream&& red_ramp_time,
             std::ofstream&& red_blink)
    : mLcdBacklight(std::move(lcd_backlight)),
      mRedLed(std::move(red_led)),
      mGreenLed(std::move(green_led)),
      mBlueLed(std::move(blue_led)),
      mRedOnTime(std::move(red_ontime)),
      mRedPeriod(std::move(red_period)),
      mRedRampTime(std::move(red_ramp_time)),
      mRedBlink(std::move(red_blink)) {
    auto backlightFn(std::bind(&Light::setLcdBacklight, this, std::placeholders::_1));
    auto attentionFn(std::bind(&Light::setAttentionLight, this, std::placeholders::_1));
    auto batteryFn(std::bind(&Light::setBatteryLight, this, std::placeholders::_1));
    auto buttonsFn(std::bind(&Light::setButtonsLight, this, std::placeholders::_1));
    auto notificationFn(std::bind(&Light::setNotificationLight, this, std::placeholders::_1));
    mLights.emplace(std::make_pair(Type::BACKLIGHT, backlightFn));
    mLights.emplace(std::make_pair(Type::ATTENTION, attentionFn));
    mLights.emplace(std::make_pair(Type::BATTERY, batteryFn));
    mLights.emplace(std::make_pair(Type::BUTTONS, buttonsFn));
    mLights.emplace(std::make_pair(Type::NOTIFICATIONS, notificationFn));
}

// Methods from ::android::hardware::light::V2_0::ILight follow.
Return<Status> Light::setLight(Type type, const LightState& state) {
    auto it = mLights.find(type);

    if (it == mLights.end()) {
        return Status::LIGHT_NOT_SUPPORTED;
    }

    it->second(state);

    return Status::SUCCESS;
}

Return<void> Light::getSupportedTypes(getSupportedTypes_cb _hidl_cb) {
    std::vector<Type> types;

    for (auto const& light : mLights) {
        types.push_back(light.first);
    }

    _hidl_cb(types);

    return Void();
}

void Light::setLcdBacklight(const LightState& state) {
    std::lock_guard<std::mutex> lock(mLock);

    uint32_t brightness = rgbToBrightness(state);

    // If max panel brightness is not the default (255),
    // apply linear scaling across the accepted range.
    if (mLcdBacklight.second != DEFAULT_MAX_BRIGHTNESS) {
        int old_brightness = brightness;
        brightness = brightness * mLcdBacklight.second / DEFAULT_MAX_BRIGHTNESS;
        LOG(VERBOSE) << "scaling brightness " << old_brightness << " => " << brightness;
    }

    mLcdBacklight.first << brightness << std::endl;
}

void Light::setAttentionLight(const LightState& state) {
    std::lock_guard<std::mutex> lock(mLock);
    mAttentionState = state;
    dispatchLightLocked();
}

void Light::setBatteryLight(const LightState& state) {
    std::lock_guard<std::mutex> lock(mLock);
    mBatteryState = state;
    dispatchLightLocked();
}

void Light::setButtonsLight(const LightState& state) {
    std::lock_guard<std::mutex> lock(mLock);
    mButtonsState = state;
    dispatchLightLocked();
}

void Light::setNotificationLight(const LightState& state) {
    std::lock_guard<std::mutex> lock(mLock);

    uint32_t brightness, color, rgb[3];
    LightState localState = state;

    // If a brightness has been applied by the user
    brightness = (localState.color & 0xff000000) >> 24;
    if (brightness > 0 && brightness < 255) {
        // Retrieve each of the RGB colors
        color = localState.color & 0x00ffffff;
        rgb[0] = (color >> 16) & 0xff;
        rgb[1] = (color >> 8) & 0xff;
        rgb[2] = color & 0xff;

        // Apply the brightness level
        if (rgb[0] > 0) {
            rgb[0] = (rgb[0] * brightness) / 0xff;
        }
        if (rgb[1] > 0) {
            rgb[1] = (rgb[1] * brightness) / 0xff;
        }
        if (rgb[2] > 0) {
            rgb[2] = (rgb[2] * brightness) / 0xff;
        }

        // Update with the new color
        localState.color = (rgb[0] << 16) + (rgb[1] << 8) + rgb[2];
    }

    mNotificationState = localState;
    dispatchLightLocked();
}

void Light::dispatchLightLocked() {
    if (isLit(mNotificationState)) {
        setNotificationLightLocked(mNotificationState);
    } else if (isLit(mAttentionState)) {
        setNotificationLightLocked(mAttentionState);
    } else if (isLit(mBatteryState)) {
        setNotificationLightLocked(mBatteryState);
    } else if (isLit(mButtonsState)) {
        setButtonLightLocked(mButtonsState);
    } else {
        // Lights off
        mRedLed << 0 << std::endl;
        mGreenLed << 0 << std::endl;
        mBlueLed << 0 << std::endl;
        mRedBlink << 0 << std::endl;
    }
}

void Light::setButtonLightLocked(const LightState& state) {
    uint32_t brightness = rgbToBrightness(state);

    // Disable all blinking to start
    mRedBlink << 0 << std::endl;

    mRedLed << brightness << std::endl;
    mGreenLed << brightness << std::endl;
    mBlueLed << brightness << std::endl;
}

void Light::setNotificationLightLocked(const LightState& state) {
    int brightness, buttonBrightness;
    int blink;
    int onMs, offMs;
    int periodMs, rampMs, pauseHi;

    switch (state.flashMode) {
        case Flash::TIMED:
            onMs = state.flashOnMs;
            offMs = state.flashOffMs;
            break;
        case Flash::NONE:
        default:
            onMs = 0;
            offMs = 0;
            break;
    }

    brightness = rgbToBrightness(state);
    buttonBrightness = rgbToBrightness(mButtonsState);
    blink = onMs > 0 && offMs > 0;

    // Disable all blinking to start
    mRedBlink << 0 << std::endl;

    if (blink) {
        periodMs = onMs + offMs;
        rampMs = RAMP_DURATION;
        pauseHi = onMs - rampMs;

        if (pauseHi < onMs / 2) {
            pauseHi = onMs / 2;
            rampMs = (onMs - pauseHi) / 2;
        }

        // Red
        mRedOnTime << pauseHi << std::endl;
        mRedPeriod << periodMs << std::endl;
        mRedRampTime << rampMs << std::endl;

        // Start the party
        mRedBlink << brightness << std::endl;
        mGreenLed << 0 << std::endl;
        mBlueLed << 0 << std::endl;
    } else {
        mRedLed << brightness << std::endl;
        mGreenLed << buttonBrightness << std::endl;
        mBlueLed << buttonBrightness << std::endl;
    }
}

}  // namespace implementation
}  // namespace V2_0
}  // namespace light
}  // namespace hardware
}  // namespace android

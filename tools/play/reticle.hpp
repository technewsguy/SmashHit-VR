// The VR aiming reticle (ours; the Gear VR original had no pointer marker): a red scope sight drawn in code, so it
// ships without an image file. Outer ring with tick marks, four inner ring segments, a crosshair with thick outer
// arms and a thin centre line with a scale. Everything outside the shape is fully transparent.
#pragma once

#include <algorithm>
#include <cmath>
#include <cstdint>

#include "assets/asset_decode.hpp"

namespace sh::play {

// True where the reticle is red. (x, y) in units of the outer radius, centre (0, 0).
inline bool reticle_covers(float x, float y) {
    const float r = std::hypot(x, y);
    if (r > 1.0f) return false;
    const float ax = std::abs(x), ay = std::abs(y);
    const float along = std::max(ax, ay), across = std::min(ax, ay);  // along / across the nearest crosshair arm

    // Outer ring, with short clear tick marks every 6 degrees (longer every 30) cut into its outer half
    // (not where a crosshair arm joins it).
    if (r >= 0.86f) {
        constexpr float kPi = 3.14159265f;
        const float deg = std::atan2(y, x) * 180.0f / kPi + 360.0f;
        const float to_tick = std::abs(std::fmod(deg + 3.0f, 6.0f) - 3.0f);           // degrees to the nearest tick
        const bool major = std::abs(std::fmod(deg + 15.0f, 30.0f) - 15.0f) < 3.0f;
        const float inner = major ? 0.905f : 0.93f;
        const bool notch = across > 0.032f && to_tick * kPi / 180.0f * r < 0.0085f && r > inner && r < 0.975f;
        return !notch;
    }
    // Inner ring: four segments, broken where the crosshair arms pass.
    if (r >= 0.70f && r <= 0.765f && across > 0.11f) return true;
    // Crosshair: thick outer arms, then a thin line through the centre.
    if (along >= 0.50f && across <= 0.032f) return true;
    if (across <= 0.012f) return true;
    // The thin line's scale: a tick every 0.0625, longer every fourth.
    if (along < 0.47f && along > 0.03f) {
        const float k = along / 0.0625f, to_tick = std::abs(k - std::round(k)) * 0.0625f;
        const bool major = static_cast<int>(std::round(k)) % 4 == 0;
        if (to_tick <= 0.007f && across <= (major ? 0.055f : 0.032f)) return true;
    }
    return false;
}

// The reticle as a size x size RGBA image (4 x 4 samples per pixel). Colour is red everywhere, alpha is the coverage,
// so filtering and mipmaps never darken the edges.
inline Image make_reticle(int size = 512) {
    Image img;
    img.width = img.height = size, img.channels = 4;
    img.pixels.resize(static_cast<size_t>(size) * size * 4);
    const float half = size * 0.5f, unit = half - 2.0f;  // a two-pixel clear border
    for (int py = 0; py < size; ++py)
        for (int px = 0; px < size; ++px) {
            int hits = 0;
            for (int sy = 0; sy < 4; ++sy)
                for (int sx = 0; sx < 4; ++sx) {
                    const float x = (px + (sx + 0.5f) / 4.0f - half) / unit, y = (py + (sy + 0.5f) / 4.0f - half) / unit;
                    hits += reticle_covers(x, y);
                }
            std::uint8_t* p = &img.pixels[(static_cast<size_t>(py) * size + px) * 4];
            p[0] = 235, p[1] = 32, p[2] = 26, p[3] = static_cast<std::uint8_t>(hits * 255 / 16);
        }
    return img;
}

}  // namespace sh::play

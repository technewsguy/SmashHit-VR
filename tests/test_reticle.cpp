// The VR aiming reticle (tools/play/reticle.hpp): clear outside and in its gaps, red on its lines.
// test_reticle <out.png> also writes the image, for a look.
#include <cstdio>
#include <fstream>

#include "play/reticle.hpp"

using namespace sh;

static int failures = 0;
static void check(bool ok, const char* what) {
    if (!ok) std::printf("FAIL: %s\n", what), ++failures;
}

int main(int argc, char** argv) {
    const Image img = play::make_reticle(512);
    auto alpha = [&](int x, int y) { return img.pixels[(static_cast<size_t>(y) * 512 + x) * 4 + 3]; };
    check(img.width == 512 && img.height == 512 && img.pixels.size() == 512u * 512u * 4u, "size");
    check(alpha(0, 0) == 0 && alpha(511, 511) == 0 && alpha(511, 0) == 0, "corners clear");
    check(alpha(256 + 120, 256 - 120) == 0, "clear between the rings and the crosshair");
    check(alpha(256, 256 + 250) == 255 && alpha(256, 256 + 240) == 255, "outer ring where the vertical arm meets it");
    check(alpha(256 + 230, 256) == 255, "thick arm meets the outer ring");
    check(alpha(256, 256) == 255, "centre line");
    check(alpha(256 + 100, 256 + 100) == 0, "clear inside the inner ring");
    const int ring = static_cast<int>(256 + 0.73f * 254 * 0.7071f);
    check(alpha(ring, ring) == 255, "inner ring segment");
    check(img.pixels[0] == 235 && img.pixels[1] == 32 && img.pixels[2] == 26, "red even where clear (no dark fringes)");
    if (argc > 1) {
        const Bytes png = encode_png(img);
        std::ofstream(argv[1], std::ios::binary).write(reinterpret_cast<const char*>(png.data()), static_cast<std::streamsize>(png.size()));
        std::printf("wrote %s\n", argv[1]);
    }
    std::printf(failures ? "%d failure(s)\n" : "reticle OK\n", failures);
    return failures ? 1 : 0;
}

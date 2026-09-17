// Xray wallpaper: a second picture behind the wallpaper, with a hole around the
// pointer that lets it through.
//
// The plugin draws one picture on a see-through surface above the DMS
// wallpaper. Everything it does not draw stays clear, so the wallpaper, its
// transitions, desktop widgets and other background plugins keep working.
//
//   image below (default): the picture is drawn inside the hole. The opacity
//                          setting lets it through everywhere else as well.
//   image on top:          the picture is drawn everywhere but the hole, so the
//                          hole shows the wallpaper underneath.
//   lens:                  the surface above the windows, where only the hole
//                          is drawn.
//
// The picture is mapped like DMS maps the wallpaper (WallpaperBackground,
// calculateUV): 0 stretch, 1 fit, 2 crop; tiling and scrolling behave like crop.
//
// Colours leave this shader premultiplied by their alpha.

#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    float fillMode;
    float imageW;
    float imageH;
    float screenW;
    float screenH;

    float centerX;      // pointer in pixels
    float centerY;
    float radius;       // px
    float softness;     // px of the soft edge
    float open;         // 0 hole closed, 1 fully open
    float ringWidth;    // px, 0 for no ring
    float dimTop;       // 0..1 darkens the upper layer
    float dimBottom;    // 0..1 darkens the layer below
    float topOpacity;   // 0..1, how much the upper layer covers
    float imageOnTop;   // 1 puts the picture above the wallpaper
    float lens;         // 1 draws only the hole, for the surface above the windows
    vec4 ringColor;
} ubuf;

layout(binding = 1) uniform sampler2D source;

vec2 imageUv(vec2 uv, vec2 image) {
    vec2 screen = vec2(ubuf.screenW, ubuf.screenH);
    if (ubuf.fillMode < 0.5)
        return uv;
    if (ubuf.fillMode < 1.5) {
        float s = min(screen.x / image.x, screen.y / image.y);
        vec2 off = (screen - image * s) * 0.5;
        return ((uv * screen) - off) / (image * s);
    }
    float s = max(screen.x / image.x, screen.y / image.y);
    vec2 off = (image * s - screen) / (image * s);
    return uv * (vec2(1.0) - off) + off * 0.5;
}

void main() {
    vec2 uv = imageUv(qt_TexCoord0, vec2(ubuf.imageW, ubuf.imageH));
    // in fit mode the picture does not reach the screen edges
    float inside = (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) ? 0.0 : 1.0;
    vec3 image = texture(source, clamp(uv, 0.0, 1.0)).rgb;

    vec2 px = qt_TexCoord0 * vec2(ubuf.screenW, ubuf.screenH);
    float d = length(px - vec2(ubuf.centerX, ubuf.centerY));
    float r = ubuf.radius * ubuf.open;
    float soft = max(1.0, ubuf.softness);

    // 1 where the upper layer covers, 0 inside the hole
    float cover = smoothstep(r - soft, r + soft, d);
    float hole = 1.0 - cover;

    float ring = 0.0;
    if (ubuf.ringWidth > 0.0 && r > 1.0) {
        float band = (d - r) / ubuf.ringWidth;
        ring = exp(-band * band) * 0.8 * ubuf.open;
    }

    float imageAlpha;
    float darken;
    vec3 rgb;

    if (ubuf.lens > 0.5) {
        // above the windows there is no wallpaper to show, so the hole always
        // carries the picture
        imageAlpha = hole;
        darken = 0.0;
        rgb = image * (1.0 - ubuf.dimBottom);
    } else if (ubuf.imageOnTop > 0.5) {
        imageAlpha = cover * ubuf.topOpacity;
        darken = ubuf.dimBottom * hole;
        rgb = image * (1.0 - ubuf.dimTop);
    } else {
        imageAlpha = max(hole, 1.0 - ubuf.topOpacity);
        darken = ubuf.dimTop;
        rgb = image * (1.0 - ubuf.dimBottom);
    }

    imageAlpha *= inside;
    // the darkening is black, so it adds alpha and no colour
    float alpha = imageAlpha + darken * (1.0 - imageAlpha);
    vec3 outRgb = rgb * imageAlpha + ubuf.ringColor.rgb * ring;
    alpha = clamp(alpha + ring, 0.0, 1.0);

    fragColor = vec4(clamp(outRgb, 0.0, 1.0), alpha) * ubuf.qt_Opacity;
}

// Full-screen beer: textured liquid, foam mapped along the dynamic surface
// and glass condensation. Two passes on the same program (uPass):
//   0 = air + beer body (opaque, the whole screen)
//   1 = foam + glass (premultiplied alpha, drawn over the carbonation sprites)
//
// The surface comes from BeerSim/BeerRenderer as an analytic function (level
// plus three damped waves along the surface direction), so the shader and the
// Dart clip/fallback paths agree pixel for pixel without sending arrays.
// Coordinates are logical pixels (FlutterFragCoord), so texture scale is the
// same on every device; textures are sampled through fract() (tiling) with
// bilinear filtering set from Dart.
#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;      // 0, 1   canvas size (logical px)
uniform float uTime;     // 2      seconds
uniform vec2 uN;         // 3, 4   unit vector of "down" (gravity) on screen
uniform float uLevel;    // 5      surface distance from the origin along uN
uniform float uAmp;      // 6      wave amplitude (px)
uniform float uPhase;    // 7      wave phase
uniform float uK1;       // 8      base wave number
uniform float uFoam;     // 9      nominal foam thickness (px), 0 = no foam
uniform float uDeep;     // 10     surface -> deepest point of the screen (px)
uniform float uPass;     // 11     0 = beer, 1 = foam + glass
uniform float uHasBeer;  // 12     0 when the glass is empty

uniform sampler2D uBeerTex;   // beer_liquid.jpg  (opaque, tileable)
uniform sampler2D uFoamTex;   // foam.png         (RGBA, tileable in x)
uniform sampler2D uGlassTex;  // condensation.png (RGBA, tileable)

out vec4 fragColor;

const float BEER_TILE = 420.0;   // logical px per beer texture tile
const float GLASS_TILE = 360.0;  // logical px per condensation tile

float surfaceD(float u) {
  float k2 = uK1 * 1.9;
  float k3 = uK1 * 4.7;
  return uLevel - uAmp * (0.58 * sin(u * uK1 + uPhase) +
                          0.30 * sin(u * k2 - uPhase * 1.3) +
                          0.12 * sin(u * k3 + uPhase * 2.1));
}

// Foam height above the surface at u (same formula as the Dart side).
float thick(float u) {
  return uFoam * (1.0 + 0.14 * sin(u * 0.019 + 1.7) +
                  0.08 * sin(u * 0.047 + uPhase * 0.35) +
                  0.04 * sin(u * 0.11 + 0.6));
}

// Soft vertical light band centred between x0 and x1 (fractions of width).
float bandAt(float x, float x0, float x1) {
  float c = (x0 + x1) * 0.5;
  float h = (x1 - x0) * 0.5;
  return clamp(1.0 - abs(x - c) / h, 0.0, 1.0);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 n = uN;
  vec2 t = vec2(n.y, -n.x);  // along the surface
  float u = dot(t, p);
  float d = dot(n, p) - surfaceD(u);  // > 0 inside the beer

  if (uPass < 0.5) {
    // ---- Air: neutral, almost black, a touch lighter at the bottom.
    float gy = p.y / max(uSize.y, 1.0);
    vec3 air = mix(vec3(0.028, 0.027, 0.026), vec3(0.075, 0.070, 0.064), gy);
    if (uHasBeer < 0.5) {
      fragColor = vec4(air, 1.0);
      return;
    }

    // ---- Beer body: two samples of the texture at different scales (breaks
    // the repetition), a slow refraction wobble and a drift against gravity
    // (the suspended streaks rise like the carbonation does).
    vec2 wob = vec2(sin(p.y * 0.021 + uTime * 0.9) + sin(p.x * 0.013 - uTime * 0.6),
                    cos(p.x * 0.017 + uTime * 0.7) + sin(p.y * 0.009 + uTime * 0.5)) * 2.2;
    vec2 q = p + wob - n * (uTime * 9.0);
    vec3 b1 = texture(uBeerTex, fract(q / BEER_TILE)).rgb;
    vec3 b2 = texture(uBeerTex, fract((q * 0.53 + vec2(173.0, 91.0)) / BEER_TILE)).rgb;
    vec3 beer = mix(b1, b2, 0.38);

    // Depth: luminous just under the foam, deeper amber far from it.
    float depth = clamp(d / max(uDeep, 1.0), 0.0, 1.0);
    vec3 tint = mix(vec3(1.10, 1.03, 0.90), vec3(0.60, 0.40, 0.16),
                    smoothstep(0.0, 1.0, depth));
    beer *= tint;
    // Backlight: the body glows a little in its upper middle.
    float glow = exp(-pow((depth - 0.30) / 0.42, 2.0)) * 0.16;
    beer += vec3(1.0, 0.86, 0.45) * glow;
    // Lacing: a thin bright, slightly creamy layer right under the foam.
    float lace = exp(-max(d, 0.0) / 16.0);
    beer = mix(beer, vec3(1.0, 0.93, 0.74), lace * 0.30);

    float a = smoothstep(-0.8, 0.8, d);
    fragColor = vec4(mix(air, beer, a), 1.0);
    return;
  }

  // ---- Pass 1: foam (premultiplied) under the glass.
  vec4 outc = vec4(0.0);
  if (uHasBeer > 0.5 && uFoam > 0.5) {
    float above = -d;                 // > 0 on the air side
    float band = uFoam * 1.45;        // texture height in px (constant scale)
    // texture y: 0 = top of the foam texture, 1 = its translucent bottom,
    // which reaches slightly below the surface into the beer.
    float v = 1.0 - (above + uFoam * 0.42) / band;
    if (v >= 0.0 && v <= 1.0) {
      float vy = clamp(v, 0.002, 0.998);
      // Mapped by distance along the surface (u) and depth in the band (v):
      // never stretched by the tilt. A second, offset copy is blended in by a
      // slow noise along u to hide the tile repetition.
      // Same scale in both directions: the texture is 4:1, so one tile along
      // the surface is 4 band heights (cells stay round).
      float tileLen = band * 4.0;
      vec4 f1 = texture(uFoamTex, vec2(fract(u / tileLen), vy));
      vec4 f2 = texture(uFoamTex, vec2(fract(u / (tileLen * 1.37) + 0.37), vy));
      float m = 0.5 + 0.5 * sin(u * 0.0123 + 1.3) * sin(u * 0.0047 + 0.4);
      vec4 f = mix(f1, f2, smoothstep(0.25, 0.75, m));
      // Top edge: the broad thickness profile, bumped by the foam's own
      // bubbles (bright domes rise a little, gaps sink), so the outline is
      // made of cells instead of a drawn zigzag.
      float lum = f.a > 0.01 ? f.r / f.a : 0.0;
      float T = thick(u) + (lum - 0.88) * 26.0;
      f *= 1.0 - smoothstep(T - 1.5, T + 1.0, above);
      outc = f;
    }
  }

  // ---- Glass, fixed to the screen: condensation (two scales) and soft
  // reflections near the sides, plus a slight darkening of the edges.
  vec4 g1 = texture(uGlassTex, fract(p / GLASS_TILE));
  vec4 g2 = texture(uGlassTex, fract(p / (GLASS_TILE * 1.71) + vec2(0.31, 0.57))) * 0.65;
  vec4 g = g1 + g2 * (1.0 - g1.a);
  outc = g + outc * (1.0 - g.a);

  float x = p.x / max(uSize.x, 1.0);
  float refl = 0.10 * bandAt(x, 0.045, 0.16) + 0.15 * bandAt(x, 0.075, 0.088) +
               0.06 * bandAt(x, 0.86, 0.95) + 0.09 * bandAt(x, 0.915, 0.923);
  outc = vec4(vec3(refl), refl) + outc * (1.0 - refl);

  float vig = 0.20 * (1.0 - smoothstep(0.0, 0.08, x)) +
              0.20 * smoothstep(0.92, 1.0, x);
  outc = vec4(0.0, 0.0, 0.0, vig) + outc * (1.0 - vig);
  fragColor = outc;
}

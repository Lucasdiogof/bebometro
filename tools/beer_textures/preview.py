"""CPU preview of the beer composition (NOT a Flutter capture).

Re-implements shaders/beer.frag and the bubble pass of BeerRenderer in numpy,
with the same textures, tile sizes, surface and foam formulas, to judge the
material without running the app.

    python tools/beer_textures/preview.py OUT_DIR [angle_deg ...]
"""
import math
import os
import sys

import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
A = os.path.join(ROOT, 'assets', 'glass')
BEER_TILE, GLASS_TILE = 420.0, 360.0


def load(name):
    im = Image.open(os.path.join(A, name)).convert('RGBA')
    a = np.asarray(im).astype(np.float32) / 255.0
    a[..., :3] *= a[..., 3:4]  # premultiplied, as Flutter samples it
    return a


def sample(tex, u, v):
    """Bilinear, wrap (fract) like the shader."""
    h, w = tex.shape[:2]
    x = (u % 1.0) * w - 0.5
    y = (v % 1.0) * h - 0.5
    x0 = np.floor(x).astype(int)
    y0 = np.floor(y).astype(int)
    fx = (x - x0)[..., None]
    fy = (y - y0)[..., None]
    x0w, x1w = x0 % w, (x0 + 1) % w
    y0w, y1w = y0 % h, (y0 + 1) % h
    c = (tex[y0w, x0w] * (1 - fx) * (1 - fy) + tex[y0w, x1w] * fx * (1 - fy) +
         tex[y1w, x0w] * (1 - fx) * fy + tex[y1w, x1w] * fx * fy)
    return c


def smooth(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)


def render(angle_deg, W=390, H=844, volume=0.70, t=3.0, amp=2.5, phase=1.1):
    beer, foam, glass, bubble = (load('beer_liquid.jpg'), load('foam.png'),
                                 load('condensation.png'), load('bubble.png'))
    ang = math.radians(angle_deg)
    nx, ny = math.sin(ang), math.cos(ang)
    ys, xs = np.mgrid[0:H, 0:W].astype(np.float32) + 0.5
    proj = nx * xs + ny * ys
    # level that holds `volume` of the screen (same idea as BeerSim.levelFor)
    level = float(np.quantile(proj, 1 - volume))
    deep = max(1.0, float(proj.max()) - level)
    k1 = 2 * math.pi / (W * 0.9)
    foam_px = min(max(H * 0.10, 40.0), 110.0)

    u = ny * xs - nx * ys
    sd = level - amp * (0.58 * np.sin(u * k1 + phase) +
                        0.30 * np.sin(u * k1 * 1.9 - phase * 1.3) +
                        0.12 * np.sin(u * k1 * 4.7 + phase * 2.1))
    d = proj - sd

    # pass 0
    gy = ys / H
    air = (np.array([0.028, 0.027, 0.026]) * (1 - gy[..., None]) +
           np.array([0.075, 0.070, 0.064]) * gy[..., None])
    wobx = (np.sin(ys * 0.021 + t * 0.9) + np.sin(xs * 0.013 - t * 0.6)) * 2.2
    woby = (np.cos(xs * 0.017 + t * 0.7) + np.sin(ys * 0.009 + t * 0.5)) * 2.2
    qx = xs + wobx - nx * t * 9.0
    qy = ys + woby - ny * t * 9.0
    b1 = sample(beer, qx / BEER_TILE, qy / BEER_TILE)[..., :3]
    b2 = sample(beer, (qx * 0.53 + 173) / BEER_TILE, (qy * 0.53 + 91) / BEER_TILE)[..., :3]
    col = b1 * 0.62 + b2 * 0.38
    depth = np.clip(d / deep, 0, 1)
    k = smooth(0, 1, depth)[..., None]
    tint = np.array([1.10, 1.03, 0.90]) * (1 - k) + np.array([0.60, 0.40, 0.16]) * k
    col = col * tint
    glow = np.exp(-((depth - 0.30) / 0.42) ** 2) * 0.16
    col = col + np.array([1.0, 0.86, 0.45]) * glow[..., None]
    lace = np.exp(-np.maximum(d, 0) / 16.0)[..., None]
    col = col * (1 - lace * 0.30) + np.array([1.0, 0.93, 0.74]) * lace * 0.30
    a = smooth(-0.8, 0.8, d)[..., None]
    img = air * (1 - a) + col * a

    # bubbles (sprites, inside the liquid, fading near the surface)
    rng = np.random.default_rng(3)
    bh, bw = bubble.shape[:2]
    for _ in range(72):
        for _try in range(8):
            x, y = rng.random() * W, rng.random() * H
            dep = nx * x + ny * y - level
            if dep > 10:
                break
        else:
            continue
        big = rng.random()
        r = 0.7 + big ** 3 * 2.3
        reach = min(max(dep / 16, 0), 1)
        near = min(max(1 - dep / (H * 0.6), 0.25), 1)
        alpha = reach * (0.55 + 0.45 * near)
        on = r * 1.35 * 2 / 0.92
        left, sp = (80, 8) if on <= 10 else ((64, 16) if on <= 26 else (0, 64))
        size = max(2, int(round(on)))
        src = bubble[0:sp, left:left + sp]
        spr = np.asarray(Image.fromarray((src * 255).astype(np.uint8), 'RGBA')
                         .resize((size, size), Image.BILINEAR)).astype(np.float32) / 255
        x0, y0 = int(x - size / 2), int(y - size / 2)
        if x0 < 0 or y0 < 0 or x0 + size > W or y0 + size > H:
            continue
        s = spr * alpha  # premultiplied * modulate
        region = img[y0:y0 + size, x0:x0 + size]
        mask = (d[y0:y0 + size, x0:x0 + size] > 0)[..., None]
        img[y0:y0 + size, x0:x0 + size] = np.where(
            mask, s[..., :3] + region * (1 - s[..., 3:4]), region)

    # pass 1: foam then glass (premultiplied over)
    above = -d
    band = foam_px * 1.45
    v = 1 - (above + foam_px * 0.42) / band
    inband = (v >= 0) & (v <= 1)
    vy = np.clip(v, 0.002, 0.998)
    tile_len = band * 4.0
    f1 = sample(foam, u / tile_len, vy)
    f2 = sample(foam, u / (tile_len * 1.37) + 0.37, vy)
    m = 0.5 + 0.5 * np.sin(u * 0.0123 + 1.3) * np.sin(u * 0.0047 + 0.4)
    mm = smooth(0.25, 0.75, m)[..., None]
    f = f1 * (1 - mm) + f2 * mm
    T = foam_px * (1 + 0.14 * np.sin(u * 0.019 + 1.7) + 0.08 * np.sin(u * 0.047 + phase * 0.35) +
                   0.04 * np.sin(u * 0.11 + 0.6))
    lum = np.where(f[..., 3] > 0.01, f[..., 0] / np.maximum(f[..., 3], 1e-6), 0)
    T = T + (lum - 0.88) * 26.0
    f = f * (1 - smooth(T - 1.5, T + 1.0, above))[..., None]
    f = np.where(inband[..., None], f, 0)
    g1 = sample(glass, xs / GLASS_TILE, ys / GLASS_TILE)
    g2 = sample(glass, xs / (GLASS_TILE * 1.71) + 0.31, ys / (GLASS_TILE * 1.71) + 0.57) * 0.65
    g = g1 + g2 * (1 - g1[..., 3:4])
    over = g + f * (1 - g[..., 3:4])
    xn = xs / W

    def bandAt(x, x0, x1):
        c, h = (x0 + x1) / 2, (x1 - x0) / 2
        return np.clip(1 - np.abs(x - c) / h, 0, 1)

    refl = (0.10 * bandAt(xn, 0.045, 0.16) + 0.15 * bandAt(xn, 0.075, 0.088) +
            0.06 * bandAt(xn, 0.86, 0.95) + 0.09 * bandAt(xn, 0.915, 0.923))[..., None]
    over = np.concatenate([np.repeat(refl, 3, -1), refl], -1) + over * (1 - refl)
    vig = (0.20 * (1 - smooth(0, 0.08, xn)) + 0.20 * smooth(0.92, 1.0, xn))[..., None]
    over = np.concatenate([np.zeros_like(over[..., :3]), vig], -1) + over * (1 - vig)
    img = over[..., :3] + img * (1 - over[..., 3:4])
    return Image.fromarray((np.clip(img, 0, 1) * 255).astype(np.uint8), 'RGB')


if __name__ == '__main__':
    out = sys.argv[1]
    angles = [float(a) for a in sys.argv[2:]] or [0.0, 25.0]
    for ang in angles:
        p = os.path.join(out, f'beer_preview_{int(ang)}.png')
        render(ang).save(p)
        print(p)

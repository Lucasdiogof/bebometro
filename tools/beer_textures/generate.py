"""Generates the textures of the full-screen beer (assets/glass/).

Everything here is procedural and original: no photograph, screenshot or
third-party asset is used, so the output is owned by the project (same
license as the repository). Deterministic (fixed seeds): running it again
produces the same files.

    python tools/beer_textures/generate.py

Outputs (all tileable where noted, sizes chosen for ~2 texels per logical
pixel at the tile sizes used by the shader):

* beer_liquid.jpg  512x512, tileable both ways. Golden body with depth
  variations, vertical "bubble trail" streaks and fine suspended glints.
  Colour only; depth darkening and backlight are applied by the shader.
* foam.png         1024x256 RGBA, tileable horizontally. y=0 is the air side,
  y=255 the beer side. Dense cream with micro cells (Worley membranes),
  larger bubbles with highlight and shadow near the top, and a translucent,
  irregular transition into the beer at the bottom.
* condensation.png 512x512 RGBA, tileable. Droplets and mist on the glass:
  mostly transparent, with highlights and refraction shadows.
* bubble.png       96x64 RGBA sprite sheet: one carbonation bubble seen as a
  tiny lens, at 64, 16 and 8 px.

Requires numpy and Pillow.
"""
import os

import numpy as np
from PIL import Image

OUT = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'glass')


# --------------------------------------------------------------- helpers

def fft_noise(h, w, beta, seed, aniso=(1.0, 1.0)):
    """Tileable 1/f^beta noise in [0, 1]. aniso stretches the spectrum
    (x, y): a small x weight gives vertical streaks."""
    rng = np.random.default_rng(seed)
    white = rng.standard_normal((h, w))
    fy = np.fft.fftfreq(h)[:, None] * aniso[1]
    fx = np.fft.fftfreq(w)[None, :] * aniso[0]
    f = np.sqrt(fx * fx + fy * fy)
    f[0, 0] = 1.0
    spec = np.fft.fft2(white) / (f ** beta)
    spec[0, 0] = 0
    n = np.real(np.fft.ifft2(spec))
    n -= n.min()
    n /= n.max()
    return n


def worley(h, w, cell, seed, wrap_y=False):
    """F1 and F2 distances (pixels) to jittered points on a grid; tileable
    horizontally (and vertically when wrap_y)."""
    rng = np.random.default_rng(seed)
    gx, gy = w // cell, max(1, h // cell)
    pts = (np.stack(np.meshgrid(np.arange(gx), np.arange(gy)), -1) +
           rng.random((gy, gx, 2))) * cell  # (gy, gx, 2) as (x, y)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    cx = (xx // cell).astype(int)
    cy = np.clip((yy // cell).astype(int), 0, gy - 1)
    f1 = np.full((h, w), 1e9, np.float32)
    f2 = np.full((h, w), 1e9, np.float32)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            nx = cx + dx
            ny = cy + dy
            ox = np.zeros_like(xx)
            oy = np.zeros_like(yy)
            ox[nx < 0] = -w
            ox[nx >= gx] = w
            nxw = nx % gx
            if wrap_y:
                oy[ny < 0] = -h
                oy[ny >= gy] = h
                nyw = ny % gy
            else:
                nyw = np.clip(ny, 0, gy - 1)
            px = pts[nyw, nxw, 0] + ox
            py = pts[nyw, nxw, 1] + oy
            d = np.sqrt((xx - px) ** 2 + (yy - py) ** 2)
            f2 = np.where(d < f1, f1, np.minimum(f2, d))
            f1 = np.minimum(f1, d)
    return f1, f2


def stamp(canvas, alpha, cx, cy, r, w, h, fn, wrap_x=True, wrap_y=False):
    """Calls fn(dx, dy, r) -> (rgb, a) on the bounding box of a disc and
    composites it over canvas/alpha (straight alpha, 'over')."""
    offs_x = [-w, 0, w] if wrap_x else [0]
    offs_y = [-h, 0, h] if wrap_y else [0]
    for ox in offs_x:
        for oy in offs_y:
            x0 = int(np.floor(cx + ox - r - 2))
            x1 = int(np.ceil(cx + ox + r + 2))
            y0 = int(np.floor(cy + oy - r - 2))
            y1 = int(np.ceil(cy + oy + r + 2))
            if x1 < 0 or y1 < 0 or x0 >= w or y0 >= h:
                continue
            xa, xb = max(x0, 0), min(x1, w)
            ya, yb = max(y0, 0), min(y1, h)
            yy, xx = np.mgrid[ya:yb, xa:xb].astype(np.float32)
            rgb, a = fn(xx + 0.5 - (cx + ox), yy + 0.5 - (cy + oy), r)
            a = np.clip(a, 0, 1)[..., None]
            dst = canvas[ya:yb, xa:xb]
            da = alpha[ya:yb, xa:xb][..., None]
            out_a = a + da * (1 - a)
            safe = np.where(out_a > 1e-6, out_a, 1)
            canvas[ya:yb, xa:xb] = (rgb * a + dst * da * (1 - a)) / safe
            alpha[ya:yb, xa:xb] = out_a[..., 0]


def save_rgba(path, rgb, a, size):
    img = np.dstack([np.clip(rgb, 0, 1), np.clip(a, 0, 1)])
    im = Image.fromarray((img * 255 + 0.5).astype(np.uint8), 'RGBA')
    im = im.resize(size, Image.LANCZOS)
    im.save(path, optimize=True)


def smooth(x, a, b):
    t = np.clip((x - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


# ------------------------------------------------------------ beer liquid

def beer_liquid():
    s = 1024  # rendered at 2x, saved at 512 (tileable)
    low = fft_noise(s, s, 2.0, 11)
    mid = fft_noise(s, s, 1.3, 12)
    # vertical bubble trails: spectrum squeezed along y -> long in y
    trails = fft_noise(s, s, 1.5, 13, aniso=(1.0, 7.0))
    fine = fft_noise(s, s, 0.5, 14)
    lum = 1.0 + 0.10 * (low - 0.5) + 0.05 * (mid - 0.5)
    lum += 0.12 * smooth(trails, 0.60, 0.88)
    lum -= 0.04 * smooth(1 - trails, 0.65, 0.92)
    light = np.array([1.00, 0.86, 0.36])
    gold = np.array([1.00, 0.72, 0.14])
    t = smooth(low, 0.2, 0.8)[..., None]
    base = light * (1 - t) * 0.45 + gold * (0.55 + t * 0.45)
    rgb = base * lum[..., None]
    rng = np.random.default_rng(15)
    specks = (fine > 0.80) & (rng.random((s, s)) > 0.80)
    rgb[specks] = rgb[specks] * 0.5 + np.array([1.0, 0.97, 0.85]) * 0.5
    im = Image.fromarray((np.clip(rgb, 0, 1) * 255).astype(np.uint8), 'RGB')
    im = im.resize((512, 512), Image.LANCZOS)
    im.save(os.path.join(OUT, 'beer_liquid.jpg'), quality=90, optimize=True)


# ------------------------------------------------------------------ foam

def foam():
    W, H = 2048, 512  # 2x of 1024x256
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    v = yy / H  # 0 top (air) .. 1 bottom (beer)

    # Micro foam everywhere: bright cells with thin darker membranes.
    f1, f2 = worley(H, W, 9, 21)
    g1, g2 = worley(H, W, 5, 22)
    cell_a = smooth(f2 - f1, 0.0, 2.6)   # 0 on membranes, 1 inside cells
    cell_b = smooth(g2 - g1, 0.0, 1.6)
    dome = np.clip(1 - f1 / 9.0, 0, 1)     # brighter at cell centres
    shade_n = fft_noise(H, W, 1.5, 23)
    cream = np.array([1.0, 0.985, 0.95])
    gap = np.array([0.82, 0.78, 0.70])
    k = (0.55 * cell_a + 0.45 * cell_b)[..., None]
    rgb = gap * (1 - k) + cream * k
    rgb *= (0.94 + 0.08 * dome + 0.05 * (shade_n - 0.5))[..., None]
    warm = smooth(v, 0.40, 0.95)[..., None]
    rgb = rgb * (1 - warm * 0.22) + np.array([0.95, 0.82, 0.52]) * warm * 0.22
    # the translucent transition into the beer is creamy, never grey
    low = smooth(v, 0.62, 0.95)[..., None]
    rgb = rgb * (1 - low * 0.55) + np.array([1.0, 0.93, 0.74]) * low * 0.55

    # Alpha: dense band, irregular translucent transition at the bottom.
    edge_n = fft_noise(H, W, 1.8, 24, aniso=(3.0, 1.0))
    bottom = 0.72 + 0.10 * (edge_n - 0.5) * 2
    alpha = np.clip(1 - smooth(v, bottom - 0.10, bottom + 0.14), 0, 1)

    # Larger bubbles, packed without overlap, mostly near the top.
    rng = np.random.default_rng(25)
    cands = []
    for _ in range(60000):
        y = rng.random() ** 1.4 * H * 0.85
        top = 1 - y / H
        rmax = 5 + 34 * top ** 2.4
        r = 3.5 + (rmax - 3.5) * rng.random() ** 2.4
        cands.append((r, rng.random() * W, y))
    cands.sort(key=lambda c: -c[0])
    cell = 48
    grid = {}
    placed = []

    def free(x, y, r):
        gx, gy = int(x // cell), int(y // cell)
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                for (px, py, pr) in grid.get(((gx + dx) % (W // cell), gy + dy), ()):
                    ddx = abs(x - px)
                    ddx = min(ddx, W - ddx)
                    if ddx * ddx + (y - py) ** 2 < (r + pr - 0.30 * min(r, pr)) ** 2:
                        return False
        return True

    for r, x, y in cands:
        if free(x, y, r):
            key = (int(x // cell) % (W // cell), int(y // cell))
            grid.setdefault(key, []).append((x, y, r))
            placed.append((x, y, r))

    def bubble_fn(dx, dy, r):
        d = np.sqrt(dx * dx + dy * dy) / r
        inside = (1 - smooth(d, 0.93, 1.0))
        # dome: lit from the top-left, darker towards the lower rim
        lit = np.clip(0.985 - 0.05 * (dx + dy) / r - 0.04 * d * d, 0, 1)
        col = np.ones(d.shape + (3,)) * np.array([1.0, 0.985, 0.95])
        col = col * lit[..., None]
        edge = smooth(d, 0.80, 0.99)
        col = col * (1 - 0.20 * edge[..., None])
        # thin film: a hint of see-through warmth in big bubbles
        film = smooth(d, 0.0, 0.6) * (1 - edge) * min(1.0, r / 30) * 0.12
        col = col * (1 - film[..., None]) + np.array([0.86, 0.80, 0.68]) * film[..., None]
        hx, hy = dx / r + 0.36, dy / r + 0.40
        spec = np.exp(-(hx * hx + hy * hy) / 0.006) * 0.9
        rim = np.exp(-((dx / r - 0.32) ** 2 + (dy / r - 0.40) ** 2) / 0.05) * 0.22
        col = col + ((spec + rim)[..., None]) * (1 - col)
        return col, inside

    for (x, y, r) in placed:
        stamp(rgb, alpha, x, y, r, W, H, bubble_fn)
    save_rgba(os.path.join(OUT, 'foam.png'), rgb, alpha, (1024, 256))
    return len(placed)


# ------------------------------------------------------- glass condensation

def condensation():
    S = 1024  # 2x of 512
    rgb = np.ones((S, S, 3))
    alpha = np.zeros((S, S))
    rng = np.random.default_rng(31)

    def drop_fn(dx, dy, r):
        # slightly elongated downwards (gravity), soft lens look
        ey = dy / 1.12
        d = np.sqrt(dx * dx + ey * ey) / r
        inside = (1 - smooth(d, 0.9, 1.0))
        col = np.ones(d.shape + (3,)) * 0.92
        # refraction: darker lower rim, bright upper-left highlight
        lower = smooth(dy / r, 0.1, 0.9) * smooth(d, 0.55, 0.98)
        col = col * (1 - 0.75 * lower[..., None])
        hx, hy = dx / r + 0.35, dy / r + 0.38
        spec = np.exp(-(hx * hx + hy * hy) / 0.035)
        caus = np.exp(-((dx / r - 0.25) ** 2 + (dy / r - 0.45) ** 2) / 0.05) * 0.5
        col = col + ((spec + caus)[..., None]) * (1 - col)
        a = inside * (0.07 + 0.45 * lower + 0.80 * spec + 0.35 * caus)
        return col, a

    # mist: many tiny droplets
    for _ in range(5200):
        r = 1.0 + rng.random() ** 2 * 2.6
        stamp(rgb, alpha, rng.random() * S, rng.random() * S, r, S, S,
              drop_fn, wrap_x=True, wrap_y=True)
    # medium and a few large drops
    for _ in range(420):
        r = 4 + rng.random() ** 2.5 * 14
        stamp(rgb, alpha, rng.random() * S, rng.random() * S, r, S, S,
              drop_fn, wrap_x=True, wrap_y=True)
    for _ in range(22):
        r = 16 + rng.random() * 10
        stamp(rgb, alpha, rng.random() * S, rng.random() * S, r, S, S,
              drop_fn, wrap_x=True, wrap_y=True)
    save_rgba(os.path.join(OUT, 'condensation.png'), rgb, alpha * 0.85,
              (512, 512))


# ---------------------------------------------------------------- bubble

def bubble():
    """Sprite sheet 96x64: the 64 px bubble at x=0, the same bubble
    pre-reduced to 16 px at x=64 and to 8 px at x=80 (no aliasing when the
    atlas draws tiny bubbles without mipmaps)."""
    S = 256  # 4x of 64
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float32)
    c = S / 2
    r = S * 0.46
    dx, dy = (xx + 0.5 - c) / r, (yy + 0.5 - c) / r
    d = np.sqrt(dx * dx + dy * dy)
    inside = (1 - smooth(d, 0.94, 1.0))
    rim = smooth(d, 0.62, 0.97) * inside
    rgb = np.ones((S, S, 3)) * np.array([1.0, 0.97, 0.88])
    ring = np.exp(-((d - 0.80) ** 2) / 0.006) * inside
    rgb = rgb * (1 - 0.45 * ring[..., None])
    spec = np.exp(-((dx + 0.34) ** 2 + (dy + 0.36) ** 2) / 0.018)
    spec2 = np.exp(-((dx - 0.30) ** 2 + (dy - 0.38) ** 2) / 0.03) * 0.45
    rgb = rgb + ((spec + spec2)[..., None]) * (1 - rgb)
    a = inside * (0.10 + 0.55 * rim + 0.40 * ring + 0.9 * spec + 0.5 * spec2)
    img = np.dstack([np.clip(rgb, 0, 1), np.clip(a, 0, 1)])
    big = Image.fromarray((img * 255 + 0.5).astype(np.uint8), 'RGBA')
    sheet = Image.new('RGBA', (96, 64), (0, 0, 0, 0))
    sheet.paste(big.resize((64, 64), Image.LANCZOS), (0, 0))
    sheet.paste(big.resize((16, 16), Image.LANCZOS), (64, 0))
    sheet.paste(big.resize((8, 8), Image.LANCZOS), (80, 0))
    sheet.save(os.path.join(OUT, 'bubble.png'), optimize=True)


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    beer_liquid()
    n = foam()
    condensation()
    bubble()
    for f in sorted(os.listdir(OUT)):
        print(f, os.path.getsize(os.path.join(OUT, f)))
    print('foam bubbles:', n)

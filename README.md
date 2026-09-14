# valk-image

Image decoding, encoding and processing for [Valk](https://valk-lang.dev), in pure Valk:
no native libraries, so it cross-compiles like any other package.

```valk
use image

fn main() {
    let photo = image.read("photo.png") ! panic("Cannot read photo")
    let thumb = photo.cover(300, 200) ! panic("Cannot resize")
    thumb.write("thumb.png") ! panic("Cannot write thumbnail")
}
```

## What it does

- `Image`: 8-bit gray, RGB or RGBA pixels with `get`, `set`, `set_pixel` and `row` access,
  `clone`, `to_gray`, `to_rgb` and `to_rgba`.
- `crop`, `flip_horizontal`, `flip_vertical`, `rotate_90`, `rotate_180`, `rotate_270`.
- `resize(width, height, filter)` with `nearest`, `box`, `bilinear`, `bicubic` and
  `lanczos` filters, plus `fit` (largest that fits) and `cover` (fill and crop).
- PNG: `decode_png` reads every bit depth and color type, palettes and transparency;
  `encode_png` writes 8-bit gray, RGB or RGBA. Interlaced files are not read yet.
- `decode` sniffs the format, `read(path)` and `Image.write(path)` go through files.

Every operation returns a new image. An `Image` holds only plain data, so it can be
converted to `shared` and handed to another thread.

## Install

```sh
vman install github.com/ctxcode/valk-image
```

```valk
use image
```

## Develop

```sh
make test   # builds and runs tests/, which embed the reference images in tests/assets
make lint
make doc    # docs/api.md
```

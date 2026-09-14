# valk-image

Image decoding, encoding and processing for [Valk](https://valk-lang.dev), in pure Valk:
no native libraries, so it cross-compiles like any other package.

```valk
use image

fn main() {
    let photo = image.read("photo.jpg") ! panic("Cannot read photo")
    let thumb = photo.cover(300, 200) ! panic("Cannot resize")
    thumb.write("thumb.jpg") ! panic("Cannot write thumbnail")
}
```

## What it does

- `Image`: 8-bit gray, RGB or RGBA pixels with `get`, `set`, `set_pixel` and `row` access,
  `clone`, `to_gray`, `to_rgb` and `to_rgba`.
- `crop`, `flip_horizontal`, `flip_vertical`, `rotate_90`, `rotate_180`, `rotate_270`.
- `resize(width, height, filter)` with `nearest`, `box`, `bilinear`, `bicubic` and
  `lanczos` filters, plus `fit` (largest that fits) and `cover` (fill and crop).
- PNG: `decode_png` reads every bit depth and color type, palettes, transparency and
  interlacing; `encode_png` writes 8-bit gray, RGB or RGBA.
- JPEG: `decode_jpeg` reads baseline files (gray and YCbCr, any chroma sampling, restart
  markers); `encode_jpeg(quality)` writes baseline gray or 4:2:0 YCbCr, or 4:4:4 with
  `subsample_chroma: false`. Progressive files are not read yet.
- BMP: `decode_bmp` reads uncompressed 1 to 32-bit files including bit-field masks;
  `encode_bmp` writes 8-bit gray, 24-bit RGB or 32-bit RGBA.
- `decode` sniffs the format, `read(path)` and `Image.write(path)` go through files and
  pick the encoder by extension.

Every operation returns a new image. An `Image` holds only plain data, so it can be
converted to `shared` and handed to another thread.

## Example: a thumbnail service

A small server that takes any PNG, JPEG or BMP as the request body and answers with a
300x200 JPEG thumbnail. The three steps are decode, resize, encode; each one that can
fail turns into a 400 with the reason.

```valk
use image
use valk.http

fn main() {
    println("Thumbnail service on http://127.0.0.1:8080")
    http.serve("127.0.0.1", 8080, thumbnail) ! panic("Cannot start the server")
}

fn thumbnail(req: http.Request) http.Response {
    if req.method != "POST" : return http.Response.text("POST an image to get a thumbnail", 405)

    // Sniffs the format from the first bytes
    let photo = image.decode(req.body) ! return http.Response.text("Not an image: " + E.message, 400)

    // Scale to fill 300x200 and crop the overflow evenly
    let thumb = photo.cover(300, 200) ! return http.Response.text("Cannot resize: " + E.message, 400)

    return http.Response.new(thumb.encode_jpeg(85), 200, "image/jpeg")
}
```

Run it and post a picture:

```sh
$ valk build . --run &
Thumbnail service on http://127.0.0.1:8080
$ curl --data-binary @holiday.png http://127.0.0.1:8080/ -o thumb.jpg
$ file thumb.jpg
thumb.jpg: JPEG image data, JFIF standard 1.01, ... 300x200, components 3
```

A 5 MB photo takes about 150 ms end to end. For a browser form, `req.files()` gives
the parts of a `multipart/form-data` upload instead of `req.body`.

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

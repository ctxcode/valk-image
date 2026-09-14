# valk-image

Image decoding, encoding and processing for [Valk](https://valk-lang.dev), written in
pure Valk. Reads and writes PNG, JPEG and BMP; resizes, crops, flips and rotates.

## Install

```sh
vman install github.com/ctxcode/valk-image
```

## Basic usage

Read a file, make a thumbnail, write it back. The format follows the file extension.

```valk
use image

fn main() {
    let photo = image.read("photo.jpg") ! panic("Cannot read photo: " + E.message)
    let thumb = photo.cover(300, 200) ! panic("Cannot resize: " + E.message)
    thumb.write("thumb.png") ! panic("Cannot write thumbnail: " + E.message)
}
```

Images in memory are plain bytes: `width` by `height` pixels of 1 (gray), 3 (RGB) or
4 (RGBA) channels.

```valk
use image

fn main() {
    let img = image.Image.new(64, 64, 3) ! panic("Cannot create image")
    img.set_pixel(10, 10, .{ 255, 0, 0 })      // one red pixel
    let red = img.get(10, 10, 0)               // channel 0 of that pixel: 255
    let gray = img.to_gray()                   // a 1-channel copy
    let bytes = gray.encode_png()              // the file contents as a String
    println(red.to(String) + " " + bytes.bytes.to(String))
}
```

Every operation returns a new image and leaves the original untouched. Functions that
can fail throw `ImageError`, with the reason in `E.message`.

## API

### Files and formats

| Function | Does |
|---|---|
| `image.read(path)` | Reads and decodes a file, any supported format |
| `img.write(path)` | Encodes by extension (`.png`, `.jpg`/`.jpeg`, `.bmp`) and writes |
| `image.decode(data)` | Decodes bytes, recognizing the format from the first bytes |
| `image.decode_png(data)`, `decode_jpeg`, `decode_bmp` | Decode one format |
| `image.is_png(data)`, `is_jpeg`, `is_bmp` | Check what the bytes are |
| `image.jpeg_orientation(data)` | The EXIF orientation tag, 1 to 8 |
| `img.encode_png(level (6))` | PNG bytes; `level` is the compression level 0-9 |
| `img.encode_jpeg(quality (85), subsample_chroma (true))` | JPEG bytes; quality 1-100 |
| `img.encode_bmp()` | BMP bytes |

Every `encode_*` has an `encode_*_into(writer)` twin that writes to any `io.Writer`.

| Format | Reads | Writes |
|---|---|---|
| PNG | all bit depths and color types, palettes, transparency, interlaced | 8-bit gray, RGB, RGBA |
| JPEG | baseline and progressive, any chroma sampling, turned upright by EXIF orientation | baseline gray or YCbCr |
| BMP | uncompressed 1 to 32-bit, including bit-field masks | 8-bit gray, 24-bit RGB, 32-bit RGBA |

### Image

| Member | Does |
|---|---|
| `Image.new(width, height, channels (4))` | A black, transparent image |
| `Image.from_pixels(width, height, channels, pixels)` | Wraps existing bytes |
| `width`, `height`, `channels`, `pixels` | The dimensions and the raw bytes |
| `get(x, y, channel (0))`, `set(x, y, value, channel (0))` | One byte of one pixel |
| `set_pixel(x, y, values)` | All channels of one pixel |
| `row(y)` | The bytes of one row, writable |
| `clone()`, `to_gray()`, `to_rgb()`, `to_rgba()` | Copies, converted when asked |

### Transforms

| Method | Does |
|---|---|
| `resize(width, height, filter (lanczos))` | Scales to exactly that size |
| `fit(width, height, filter (lanczos))` | Largest size that fits, same proportions |
| `cover(width, height, filter (lanczos))` | Fills the size and crops the overflow evenly |
| `crop(x, y, width, height)` | A rectangle of the image |
| `flip_horizontal()`, `flip_vertical()` | Mirrors |
| `rotate_90()`, `rotate_180()`, `rotate_270()` | Turns clockwise |

The resize filters are `image.Filter.nearest`, `box`, `bilinear`, `bicubic` and
`lanczos`. `nearest` is fastest and blocky, `lanczos` is slowest and sharpest.

### Errors

`ImageError` has four codes: `invalid` (the data is not that format), `unsupported`
(a valid file using a feature this library does not read), `too_large` (more than
`image.MAX_PIXELS` pixels) and `range` (a coordinate or size outside the image).

## Example: a thumbnail service

An HTTP handler that takes an image as the request body and answers with a JPEG
thumbnail.

```valk
use image
use valk.http

fn main() {
    http.serve("127.0.0.1", 8080, thumbnail) ! panic("Cannot start the server")
}

fn thumbnail(req: http.Request) http.Response {
    let photo = image.decode(req.body) ! return http.Response.text("Not an image: " + E.message, 400)
    let thumb = photo.cover(300, 200) ! return http.Response.text("Cannot resize: " + E.message, 400)
    return http.Response.new(thumb.encode_jpeg(85), 200, "image/jpeg")
}
```

```sh
curl --data-binary @photo.png http://127.0.0.1:8080/ -o thumb.jpg
```

## Development

```sh
make test   # runs tests/ against the reference images in tests/assets
make lint
make doc    # regenerates docs/api.md
```

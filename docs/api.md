
# Documentation

Namespaces: [main](#main)

---

# main

## Aliases for 'main'

```js
// The most pixels an `Image` may hold: a hostile header cannot ask for more memory.
+ value MAX_PIXELS (64 * 1024 * 1024)
```

## Errors for 'main'

```js
// Thrown by the decoders, encoders and the operations that take coordinates.
error ImageError (invalid, unsupported, too_large, range) payload { message: String ("") }
```

## Enums for 'main'

```js
// How `resize` samples the source.
+ enum Filter { nearest, box, bilinear, bicubic, lanczos }
```

## Functions for 'main'

```js
// Decodes an image, recognizing the format from its first bytes: PNG, JPEG, WebP, GIF or BMP. A GIF gives its first frame.
+ fn decode(data: local &[u8]) Image !ImageError
// Decodes a Windows bitmap.
+ fn decode_bmp(data: local &[u8]) Image !ImageError
// Decodes a GIF: its first frame, over the whole canvas.
+ fn decode_gif(data: local &[u8]) Image !ImageError
// Decodes every frame of a GIF, each composed onto the canvas as a browser shows it, with its delay and the loop count.
+ fn decode_gif_animation(data: local &[u8]) Animation !ImageError
// Decodes a JPEG image.
+ fn decode_jpeg(data: local &[u8]) Image !ImageError
// Decodes a PNG image.
+ fn decode_png(data: local &[u8]) Image !ImageError
// Decodes a WebP image.
+ fn decode_webp(data: local &[u8]) Image !ImageError
// Whether `data` starts like a Windows bitmap.
+ fn is_bmp(data: local &[u8]) bool
// Whether `data` starts with a GIF signature.
+ fn is_gif(data: local &[u8]) bool
// Whether `data` starts with the JPEG marker sequence.
+ fn is_jpeg(data: local &[u8]) bool
// Whether `data` starts with the PNG signature.
+ fn is_png(data: local &[u8]) bool
// Whether `data` starts like a WebP file.
+ fn is_webp(data: local &[u8]) bool
// Returns the EXIF orientation of a JPEG, 1 to 8, or 1 when the file has none.
+ fn jpeg_orientation(data: local &[u8]) uint
// Reads and decodes the image file at `path`.
+ fn read(path: String) Image !ImageError
```

## Classes for 'main'

```js
// An animated image: its frames in order and how often it plays.
+ class Animation {
    // The frames, each a whole canvas.
    + frames: Array[Frame]
    // How many times the animation plays; 0 plays it forever. A decoded GIF without a loop count plays once.
    + loops: uint

    // Encodes the animation as a GIF, with the colours of each frame chosen as `encode_gif` does.
    + fn encode_gif(dither: bool (true)) String !ImageError
}
```

```js
// One picture of an animation: the whole canvas as it shows at that moment.
+ class Frame {
    // How long the frame shows, in milliseconds.
    + delay_ms: uint
    // The full image at this point of the animation.
    + image: Image
}
```

```js
// An 8-bit image: `width` by `height` pixels of `channels` bytes each, row by row.
+ class Image {
    // Bytes per pixel: 1, 3 or 4.
    ~ channels: u8
    // Rows.
    ~ height: uint
    // The pixel bytes, `width * height * channels` of them, top row first.
    ~ pixels: mut &[u8]
    // Pixels per row.
    ~ width: uint

    // Returns a copy.
    + fn clone() Image
    // Returns exactly `width` by `height`: the image is scaled to cover that size and the overflow is cropped away evenly on both sides.
    + fn cover(width: uint, height: uint, filter: Filter (Filter.lanczos)) Image !ImageError
    // Returns the `width` by `height` rectangle whose top-left corner is (`x`, `y`).
    + fn crop(x: uint, y: uint, width: uint, height: uint) Image !ImageError
    // Encodes the image as a Windows bitmap: 8-bit with a gray palette, 24-bit RGB, or 32-bit RGBA with a V4 header so readers know where the alpha is.
    + fn encode_bmp() String
    // Writes the image as a bitmap to `out` and returns the bytes written; see `encode_bmp`.
    + fn encode_bmp_into(out: Writer) uint !io:IoError
    // Encodes the image as a GIF, with more than 256 colours reduced to a palette of 256.
    + fn encode_gif(dither: bool (true)) String !ImageError
    // Encodes the image as a baseline JPEG at `quality` (1..100).
    + fn encode_jpeg(quality: uint (85), subsample_chroma: bool (true)) String
    // Writes the image as JPEG to `out` and returns the bytes written; see `encode_jpeg`.
    + fn encode_jpeg_into(out: Writer, quality: uint (85), subsample_chroma: bool (true)) uint !io:IoError
    // Encodes the image as PNG: 8-bit gray, RGB or RGBA, one IDAT chunk.
    + fn encode_png(level: uint (6)) String
    // Writes the image as PNG to `out` and returns the bytes written; see `encode_png`.
    + fn encode_png_into(out: Writer, level: uint (6)) uint !io:IoError
    // Encodes the image as a lossy WebP at `quality`, from 0 (smallest) to 100 (best).
    + fn encode_webp(quality: uint (75)) String !ImageError
    // Encodes the image as a lossless WebP: every pixel, and the alpha of an RGBA image, is kept exactly.
    + fn encode_webp_lossless() String !ImageError
    // Returns the largest image that fits inside `width` by `height` with the same proportions; an image that already fits is returned unchanged.
    + fn fit(width: uint, height: uint, filter: Filter (Filter.lanczos)) Image !ImageError
    // Returns the image mirrored left to right.
    + fn flip_horizontal() Image
    // Returns the image mirrored top to bottom.
    + fn flip_vertical() Image
    // Wraps existing pixel bytes; `pixels` must hold exactly `width * height * channels`.
    + static fn from_pixels(width: uint, height: uint, channels: u8, pixels: mut &[u8]) Image !ImageError
    // Returns channel `channel` of pixel (`x`, `y`); panics outside the image.
    + fn get(x: uint, y: uint, channel: u8 (0)) u8
    // Creates a black, fully transparent image. `channels` must be 1, 3 or 4.
    + static fn new(width: uint, height: uint, channels: u8 (4)) Image !ImageError
    // The byte offset of pixel (`x`, `y`).
    + fn offset(x: uint, y: uint) uint
    // Returns the image scaled to `width` by `height` with `filter`.
    + fn resize(width: uint, height: uint, filter: Filter (Filter.lanczos)) Image !ImageError
    // Returns the image turned upside down.
    + fn rotate_180() Image
    // Returns the image turned a quarter turn counter-clockwise.
    + fn rotate_270() Image
    // Returns the image turned a quarter turn clockwise.
    + fn rotate_90() Image
    // The bytes of row `y`, writable.
    + fn row(y: uint) mut &[u8]
    // Sets channel `channel` of pixel (`x`, `y`); panics outside the image.
    + fn set(x: uint, y: uint, value: u8, channel: u8 (0)) void
    // Sets every channel of pixel (`x`, `y`) from `values`, one byte per channel.
    + fn set_pixel(x: uint, y: uint, values: local &[u8]) void
    // Bytes per row.
    + get stride: uint
    // Returns a one-channel copy, weighting the channels as the eye does (Rec. 601).
    + fn to_gray() Image
    // Returns a three-channel copy; the alpha of an RGBA image is dropped.
    + fn to_rgb() Image
    // Returns a four-channel copy; the added alpha is opaque.
    + fn to_rgba() Image
    // Encodes the image by the extension of `path` (`.png`, `.jpg`/`.jpeg`, `.webp`, `.gif` or `.bmp`) and writes it there, with each encoder's defaults; WebP is lossy.
    + fn write(path: String) void !ImageError
}
```

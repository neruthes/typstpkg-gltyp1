#import "types.C.typ": *

#let sample(tex, u, v) = {
  if tex.repeat {
    u = calc.rem(u, 1.0)
    v = calc.rem(v, 1.0)
  }
  (tex.sample)(u, v)
}

#let perlin-noise(seed: 0) = texture-2d((u, v) => {
  perlin(u, v, seed)
})

#let checkerboard(size: 8) = texture-2d((u, v) => {
  let x = calc.floor(u * size)
  let y = calc.floor(v * size)
  calc.rem(x + y, 2)
})

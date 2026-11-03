// gltyp1/texture.C.typ
#import "types.C.typ": *

// 采样入口，处理 repeat/mirror/clamp
#let sample(tex, u, v) = {
  if tex.repeat {
    u = calc.rem(u, 1.0)
    v = calc.rem(v, 1.0)
  }
  (tex.sample)(u, v)
}

// 内置程序化纹理
#let perlin-noise(seed: 0) = texture-2d((u, v) => {
  // 你的 Perlin 实现，返回 float
  perlin(u, v, seed)
})

#let checkerboard(size: 8) = texture-2d((u, v) => {
  let x = calc.floor(u * size)
  let y = calc.floor(v * size)
  calc.rem(x + y, 2)
})

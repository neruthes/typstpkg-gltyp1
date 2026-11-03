#let _fade(t) = t * t * t * (t * (t * 6 - 15) + 10)

#let _lerp(a, b, t) = a + t * (b - a)

#let _grad2(hash, x, y) = {
  let h = calc.rem(hash, 8)
  let u = if h < 4 { x } else { y }
  let v = if h < 4 { y } else { x }
  let s1 = if calc.rem(h, 2) == 0 { 1 } else { -1 }
  let s2 = if h < 4 and calc.rem(h, 2) == 0 { 1 } else { -1 }
  s1 * u + s2 * v
}

#let _hash2(ix, iy, seed) = {
  let n = ix * 374761393 + iy * 668265263 + seed * 144269504088896
  calc.rem(calc.abs(n), 256)
}


#let perlin-2d(
  seed: 0,
  frequency: 4.0,
  octaves: 3,
  lacunarity: 2.0,
  gain: 0.5,
  fractal-type: "fbm",
) = (x, y) => {
  let amp = 1.0
  let freq = frequency
  let sum = 0.0
  let norm = 0.0

  for i in range(octaves) {
    let xi = calc.floor(x * freq)
    let yi = calc.floor(y * freq)
    let xf = x * freq - xi
    let yf = y * freq - yi

    let u = _fade(xf)
    let v = _fade(yf)

    let aa = _grad2(_hash2(xi, yi, seed), xf, yf)
    let ba = _grad2(_hash2(xi + 1, yi, seed), xf - 1, yf)
    let ab = _grad2(_hash2(xi, yi + 1, seed), xf, yf - 1)
    let bb = _grad2(_hash2(xi + 1, yi + 1, seed), xf - 1, yf - 1)

    let x1 = _lerp(aa, ba, u)
    let x2 = _lerp(ab, bb, u)
    let val = _lerp(x1, x2, v)

    if fractal-type == "billow" { val = calc.abs(val) * 2.0 - 1.0 }
    if fractal-type == "ridged" { val = 1.0 - calc.abs(val) }

    sum += val * amp
    norm += amp
    amp *= gain
    freq *= lacunarity
  }

  let n = sum / norm
  if fractal-type == "ridged" { n } else { (n + 1.0) / 2.0 }
}


#let perlin-texture(
  seed: 0,
  width: 256,
  height: 256,
  frequency: 4.0,
  octaves: 3,
  lacunarity: 2.0,
  gain: 0.5,
  fractal-type: "fbm",
  repeat: true,
) = {
  let data = range(height).map(y => range(width).map(
    x => perlin-2d(
      seed: seed,
      frequency: frequency,
      octaves: octaves,
      lacunarity: lacunarity,
      gain: gain,
      fractal-type: fractal-type,
    )(x / width, y / height),
  ))

  (
    kind: "texture2d",
    width: width,
    height: height,
    repeat: repeat,

    sample: (u, v) => {
      if repeat {
        u = calc.rem(u, 1.0)
        v = calc.rem(v, 1.0)
      } else {
        u = calc.min(calc.max(u, 0.0), 1.0)
        v = calc.min(calc.max(v, 0.0), 1.0)
      }

      let px = u * (width - 1)
      let py = v * (height - 1)
      let x0 = calc.floor(px)
      let y0 = calc.floor(py)
      let x1 = calc.min(x0 + 1, width - 1)
      let y1 = calc.min(y0 + 1, height - 1)
      let fx = px - x0
      let fy = py - y0

      let c00 = data.at(y0).at(x0)
      let c10 = data.at(y0).at(x1)
      let c01 = data.at(y1).at(x0)
      let c11 = data.at(y1).at(x1)

      _lerp(
        _lerp(c00, c10, fx),
        _lerp(c01, c11, fx),
        fy,
      )
    },
  )
}



#import "components/types.C.typ": *
#import "components/drawcalls.C.typ": *
#import "components/texture.C.typ": *
#import "components/shader.C.typ": *
#import "components/noise.C.typ": *


// ---------- Geometry (internal for now) ----------

#let _sign(p1, p2, p3) = (p1.at(0) - p3.at(0)) * (p2.at(1) - p3.at(1)) - (p2.at(0) - p3.at(0)) * (p1.at(1) - p3.at(1))

#let _point-in-tri(p, a, b, c) = {
  let d1 = _sign(p, a, b)
  let d2 = _sign(p, b, c)
  let d3 = _sign(p, c, a)
  let has_neg = d1 < 0 or d2 < 0 or d3 < 0
  let has_pos = d1 > 0 or d2 > 0 or d3 > 0
  not (has_neg and has_pos)
}

#let _barycentric(p, a, b, c) = {
  let v0 = (b.at(0) - a.at(0), b.at(1) - a.at(1))
  let v1 = (c.at(0) - a.at(0), c.at(1) - a.at(1))
  let v2 = (p.at(0) - a.at(0), p.at(1) - a.at(1))
  let den = v0.at(0) * v1.at(1) - v1.at(0) * v0.at(1)
  if den == 0 { return (1.0, 0.0, 0.0) }
  let v = (v2.at(0) * v1.at(1) - v1.at(0) * v2.at(1)) / den
  let w = (v0.at(0) * v2.at(1) - v2.at(0) * v0.at(1)) / den
  (1.0 - v - w, v, w)
}

// ---------- Rasterizer ----------

#let _blend-over(fg, bg) = {
  let fa = fg.a
  let ba = bg.a
  let oa = fa + ba * (1 - fa)
  if oa <= 0.0 { return (r: 0.0, g: 0.0, b: 0.0, a: 0.0) }
  (
    r: (fg.r * fa + bg.r * ba * (1 - fa)) / oa,
    g: (fg.g * fa + bg.g * ba * (1 - fa)) / oa,
    b: (fg.b * fa + bg.b * ba * (1 - fa)) / oa,
    a: oa,
  )
}

#let create-canvas(w, h, body) = {
  let commands = body(w, h)

  let prepared = commands.map(cmd => {
    if cmd.shader_fragment != none {
      cmd
    } else {
      let col = cmd.color
      cmd + (shader_fragment: _ctx => col)
    }
  })

  let fb = range(w * h).map(i => {
    let px = calc.rem(i, w) + 0.5
    let py = calc.floor(i / w) + 0.5
    let rgba = (r: 0.0, g: 0.0, b: 0.0, a: 0.0)

    for cmd in prepared {
      if _point-in-tri((px, py), cmd.a, cmd.b, cmd.c) {
        let bary = _barycentric((px, py), cmd.a, cmd.b, cmd.c)
        let ctx = (
          UV: (bary.at(1), bary.at(2)),
          SCREEN_UV: (px / w, py / h),
          BARY: bary,
        )
        let fg = (cmd.shader_fragment)((MAT: cmd.material, CTX: ctx))
        if fg != none and fg.a > 0.0 {
          rgba = _blend-over(fg, rgba)
        }
      }
    }

    (
      int(calc.round(rgba.r * 255)),
      int(calc.round(rgba.g * 255)),
      int(calc.round(rgba.b * 255)),
      int(calc.round(rgba.a * 255)),
    )
  })

  bytes(fb.flatten())
}

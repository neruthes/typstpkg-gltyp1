#import "types.C.typ": *

#let texture(tex, uv) = {
  let (u, v) = (uv.at(0), uv.at(1))
  if tex.repeat {
    u = calc.rem(u, 1.0)
    v = calc.rem(v, 1.0)
  }
  let val = (tex.sample)(u, v)
  if type(val) == float or type(val) == int {
    rgba(r: val, g: val, b: val, a: 1.0)
  } else {
    val
  }
}

#let run-fragment(frag, mat, ctx) = {
  let ray = (
    MAT: mat,
    CTX: ctx,
  )
  (frag.run)(ray)
}

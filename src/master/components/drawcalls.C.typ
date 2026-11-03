// gltyp1/drawcalls.C.typ
// Draw-call constructors. Each returns a dictionary the rasterizer
// understands. Extend with draw_line, draw_circle, draw_mesh, etc.

#import "types.C.typ" as T

// Internal: normalize a fill argument (rgba dict or T.material) into a
// material dictionary. Keeps draw_* signatures simple and future-proof.
#let _to-material(fill) = {
  if fill == none { return none }
  if type(fill) == dictionary and "shader_fragment" in fill {
    return fill
  }
  // plain color dict (r,g,b,a)
  return T.material(albedo: fill)
}

#let draw-plain-triangle(a, b, c, fill) = {
  let mat = _to-material(fill)
  (
    kind: "triangle",
    a: a,
    b: b,
    c: c,
    color: fill,
    material: mat,
    shader_fragment: none,
  )
}

#let draw-generic-triangle(a, b, c, material: (:)) = {
  let mat = _to-material(material)
  (
    kind: "triangle",
    a: a,
    b: b,
    c: c,
    color: none,
    material: mat,
    shader_fragment: if mat == none { none } else { mat.at("shader_fragment", default: none) },
  )
}

// Convenience alias matching the original POC naming
#let draw_triangle = draw-plain-triangle



#let draw-shaded-triangle(a, b, c, program: none, uniforms: (:)) = (
  kind: "triangle",
  a: a,
  b: b,
  c: c,
  color: none,
  material: none,
  shader_fragment: if program == none { none } else { program.fragment.run },
  vertex_shader: if program == none { none } else { program.vertex.run },
  uniforms: uniforms,
)

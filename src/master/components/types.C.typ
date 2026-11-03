





#let rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0) = (r: r, g: g, b: b, a: a)

#let color(r: 0.0, g: 0.0, b: 0.0, a: 1.0) = rgba(r: r, g: g, b: b, a: a)


#let material(
  albedo: none,
  normal: none,
  metallic: none,
  roughness: none,
  ao: none,
  emissive: none,
  shader_fragment: none,
  textures: (:),
  extra: (:),
) = {
  let m = (
    albedo: albedo,
    normal: normal,
    metallic: metallic,
    roughness: roughness,
    ao: ao,
    emissive: emissive,
    shader_fragment: shader_fragment,
    textures: textures,
  )
  for (k, v) in extra {
    if v != none and k not in m { m.insert(k, v) }
  }
  m
}

#let shader-material(
  albedo: none,
  shader_fragment: none,
  normal: none,
  metallic: none,
  roughness: none,
  ao: none,
  emissive: none,
) = material(
  albedo: albedo,
  normal: normal,
  metallic: metallic,
  roughness: roughness,
  ao: ao,
  emissive: emissive,
  shader_fragment: shader_fragment,
)


#let shader-fragment(f) = f





#let texture-2d(f, size: (1.0, 1.0), repeat: true) = (
  kind: "texture2d",
  sample: f,
  size: size,
  repeat: repeat,
)


#let vertex-shader(f) = (
  kind: "vertex_shader",
  run: f,
)


#let fragment-shader(f) = (
  kind: "fragment_shader",
  run: f,
)


#let shader-program(vertex: none, fragment: none, uniforms: (:)) = (
  kind: "shader_program",
  vertex: vertex,
  fragment: fragment,
  uniforms: uniforms,
)

// gltyp1/types.C.typ
// Typed constructor functions for materials and shader fragments.
// Named params are used throughout so we can extend to full PBR later
// (metallic, roughness, AO, emissive, normal maps, etc.) without
// breaking the API.

#let rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0) = (r: r, g: g, b: b, a: a)

#let color(r: 0.0, g: 0.0, b: 0.0, a: 1.0) = rgba(r: r, g: g, b: b, a: a)

// types.C.typ
#let material(
  albedo: none,
  normal: none,
  metallic: none,
  roughness: none,
  ao: none,
  emissive: none,
  shader_fragment: none,
  textures: (:), // 新增：命名纹理表
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

// A shader fragment is just a function: (ray) -> rgba | none
#let shader-fragment(f) = f





// 程序化纹理：一个从 UV 采样返回标量或颜色的函数
#let texture-2d(f, size: (1.0, 1.0), repeat: true) = (
  kind: "texture2d",
  sample: f, // (u, v) -> float | rgba
  size: size, // 逻辑尺寸，用于平铺计算
  repeat: repeat,
)

// 顶点着色器：接收顶点属性，返回变换后的位置 + varyings
#let vertex-shader(f) = (
  kind: "vertex_shader",
  run: f, // (attrs, uniforms) -> (position: (x,y), varyings: (:))
)

// 片元着色器：接收 ray，返回 rgba | none
#let fragment-shader(f) = (
  kind: "fragment_shader",
  run: f,
)

// 完整的着色器程序
#let shader-program(vertex: none, fragment: none, uniforms: (:)) = (
  kind: "shader_program",
  vertex: vertex,
  fragment: fragment,
  uniforms: uniforms,
)

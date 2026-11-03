#import "/src/master/gltyp1.typ" as gl

#let generic-material = gl.shader-material(
  albedo: gl.rgba(r: 1.0, g: 0.5, b: 0.0),
  shader_fragment: ray => {
    let ctx = ray.CTX
    let u = ctx.UV.at(0)
    let v = ctx.UV.at(1)
    let t = ray.MAT.albedo
    (r: t.r * u, g: t.g * v, b: t.b, a: 0.9)
  },
)



#let my-material = gl.material(
  textures: (
    NoiseTexture1: gl.perlin-texture(
      seed: 42,
      frequency: 3.0,
      octaves: 4,
      fractal-type: "fbm",
    ),
  ),
  shader_fragment: ray => {
    let COLOR = gl.texture(ray.MAT.textures.NoiseTexture1, ray.CTX.SCREEN_UV)
    COLOR.a = 0.92
    return COLOR
  },
)

#let final-fb = gl.create-canvas(400, 300, (w, h) => {
  let layers = ()
  layers.push(gl.draw-plain-triangle(
    (1, 1),
    (33, 6),
    (7, 55),
    gl.rgba(r: 0.03, g: 0.34, b: 1.0),
  ))
  layers.push(gl.draw-generic-triangle(
    (60, 10),
    (200, 40),
    (120, 120),
    material: generic-material,
  ))
  layers.push(gl.draw-generic-triangle(
    (150, 100),
    (390, 120),
    (300, 290),
    material: gl.shader-material(
      shader_fragment: ray => {
        let s = ray.CTX.SCREEN_UV
        let cell = calc.floor(s.at(0) * 20) + calc.floor(s.at(1) * 20)
        if calc.rem(cell, 2) == 0 {
          gl.rgba(r: 0.9, g: 0.9, b: 0.9)
        } else {
          gl.rgba(r: 0.1, g: 0.1, b: 0.1)
        }
      },
    ),
  ))
  layers.push(gl.draw-generic-triangle(
    (12, 50),
    (380, 6),
    (250, 320),
    material: my-material,
  ))
  return layers
})

#box(stroke: 0.4pt + gray, image(
  final-fb,
  format: (encoding: "rgba8", width: 400, height: 300),
  width: 100%,
))

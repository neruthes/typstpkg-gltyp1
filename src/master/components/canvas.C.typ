#import "types.C.typ": *
// ShaderMaterial, VertexShader, FragmentShader, rgba, color, texture-2d
// all come from types.C.typ.

// ---------------------------------------------------------------------------
// CanvasItem: a node in the scene/group tree.
//
//   material: none  -> "transparent" group: NOT a framebuffer boundary.
//                      Its layers are spliced directly into the parent's
//                      draw list, inheriting the parent's group material.
//
//   material: mat   -> "opaque" group: IS a framebuffer boundary.
//                      Its layers are rendered into an offscreen target,
//                      then the target is composited via a single draw call
//                      carrying `mat` (the post-process / shading for the
//                      whole group result).
//
//   layers: ordered list of children, each either a draw call (geometry-only)
//           or another CanvasItem. Nesting is arbitrary.
// ---------------------------------------------------------------------------

#let CanvasItem(material: none, layers: (), transform: none) = (
  kind: "canvas_item",
  material: material, // already a ShaderMaterial dict or none
  layers: layers,
  transform: transform,
)

#let add-layer(item, layer) = {
  item.layers.push(layer)
  item
}

// ---------------------------------------------------------------------------
// Geometry-only draw calls. No material — shading comes from the enclosing
// framebuffer group's material at composite time.
// ---------------------------------------------------------------------------

#let draw-triangle(a, b, c) = (
  kind: "triangle",
  a: a,
  b: b,
  c: c,
)
#let draw_triangle = draw-triangle


// ---------------------------------------------------------------------------
// Compile a CanvasItem tree into a flat render list.
//
// Output entries are one of:
//   - { kind: "triangle", a, b, c, material: <group mat or none> }
//       A leaf draw. `material` is the *enclosing* group's material,
//       i.e. the shading that applies directly to this primitive.
//       (none means: default/unshaded pass.)
//
//   - { kind: "framebuffer", material, draw_list }
//       A group boundary. `draw_list` is itself a flat render list
//       describing what goes into the offscreen target; `material` is
//       the post-process applied when compositing that target.
//
// The recursion: when we hit a CanvasItem with material != none, we emit a
// single "framebuffer" entry whose inner draw_list is the compiled children,
// and *reset* the inherited group material to none for those children
// (they're shaded by whatever group they're in *inside* the framebuffer,
// or unshaded at the bottom).
//
// When we hit a CanvasItem with material == none, we splice: recurse with the
// same inherited group material.
// ---------------------------------------------------------------------------

#let compile-canvas(root) = {
  let out = ()
  let visit(item, group-material) = {
    if item.kind == "canvas_item" {
      if item.material == none {
        // transparent group: splice into parent
        for layer in item.layers {
          visit(layer, group-material)
        }
      } else {
        // opaque group: framebuffer boundary
        let inner = ()
        for layer in item.layers {
          // inside the framebuffer, group-material resets to none;
          // nested opaque groups handle their own materials
          compile-into(inner, layer, none)
        }
        out.push((
          kind: "framebuffer",
          material: item.material,
          draw_list: inner,
        ))
      }
    } else {
      // leaf geometry: shade with the enclosing group's material
      out.push(item + (material: group-material))
    }
  }
  // helper because Typst closures can't easily recurse with a shared accumulator
  let compile-into(acc, item, group-material) = {
    if item.kind == "canvas_item" {
      if item.material == none {
        for layer in item.layers { compile-into(acc, layer, group-material) }
      } else {
        let inner = ()
        for layer in item.layers { compile-into(inner, layer, none) }
        acc.push((kind: "framebuffer", material: item.material, draw_list: inner))
      }
    } else {
      acc.push(item + (material: group-material))
    }
  }
  compile-into(out, root, none)
  out
}

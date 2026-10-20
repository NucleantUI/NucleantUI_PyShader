# NucleantUI_PyShader

PyShader source compiled at run time into a NucleantUI shader.

NucleantUI runs SPIR-V and nothing else: `Shader` and `.shader(_:)` are
generic over a `ShaderProtocol` type — a module and the input it reads. This
package adds `PyShaderFunction`, a `ShaderProtocol` whose module is compiled
by [PyShader](https://github.com/NucleantUI/PyShader) from Python source — a
string, or a `.py` file — while the app runs.

```swift
import NucleantUI
import NucleantUI_PyShader

let glow = PyShaderFunction("""
    class Glow:
        intensity: float
        tint: float4

    def main(uv: float2, glow: Glow) -> float4:
        return glow.tint * glow.intensity * smoothstep(0.5, 0.0, distance(uv, float2(0.5)))
    """) {
    model.intensity
    model.tint
}

Shader(glow)
```

- `def main` is a compute shader, dispatched over every pixel; `def vertex`
  with `def fragment` is a vertex + fragment pair. The compiler finds out
  which — the source is compiled for the compute target, and for the
  graphics one only if that fails.
- The input is a `class` parameter of the entry point, read whole: list its
  fields in order with the builder, or hand over a `ShaderInput` model that
  packs them. A change to anything it packs reaches the shader through
  observation.
- Each source is compiled once for the life of the app. Source that does not
  compile is an empty module, and `error` says why — both targets' reasons.

## Run time or build time

This is for source the app only has while it runs — written in it,
downloaded, generated. A shader fixed when the app is built is better
compiled then: PyShader's build plugin turns each `.py` a `pyshader.toml`
lists into a `.spv` resource, which NucleantUI's own `SpirvFunction` runs
with no compiler in the app at all.

## Example

[`Examples/ShaderLab`](Examples/ShaderLab): a PyShader editor — write a
shader, press Run, see it — with sliders as the input every template takes.

```sh
cd Examples/ShaderLab
swift build && .build/debug/ShaderLab
```

## Dependencies

NucleantUI (from 0.0.3) and PyShader (from 0.0.4) by release, up to the
next minor; the sibling checkouts (`../NucleantUI`, `../PyShader`) under
`NUCLEANT_LOCAL_DEV=1`.

```swift
.package(url: "https://github.com/NucleantUI/NucleantUI_PyShader.git", .upToNextMinor(from: "0.0.1"))
```

//
//  Templates.swift
//  ShaderLab
//

/// A shader to start from.
struct Template: Identifiable, Hashable {
    let name: String
    let source: String
    /// For a vertex + fragment pair: vertices per draw.
    let vertices: Int

    var id: String { name }

    static let knobs = """
        class Knobs:
            tint: float4
            a: float
            b: float
            c: float
        """

    static let all: [Template] = [
        Template(name: "Plasma", source: knobs + """


            def main(uv: float2, time: float, knobs: Knobs) -> float4:
                p = uv * (2.0 + knobs.a * 10.0)
                t = time * (0.2 + knobs.b * 2.0)
                v = sin(p.x + t) + sin(p.y * 1.3 - t) + sin((p.x + p.y) * 0.7 + t * 0.5)
                band = 0.5 + 0.5 * sin(v * (1.0 + knobs.c * 4.0))
                return float4(knobs.tint.xyz * band, 1.0)
            """, vertices: 6),
        Template(name: "Rings", source: knobs + """


            def main(uv: float2, time: float, resolution: float2, knobs: Knobs) -> float4:
                p = (uv - 0.5) * float2(resolution.x / resolution.y, 1.0)
                d = length(p)
                rings = 0.5 + 0.5 * sin(d * (10.0 + knobs.a * 60.0) - time * (1.0 + knobs.b * 6.0))
                fade = smoothstep(0.2 + knobs.c * 0.6, 0.0, d)
                return float4(knobs.tint.xyz * rings * fade, 1.0)
            """, vertices: 6),
        Template(name: "Triangle", source: knobs + """


            class V:
                position: float4
                uv: float2

            def vertex(vertex_index: int, time: float, knobs: Knobs) -> V:
                corner = float2(float((vertex_index << 1) & 2), float(vertex_index & 2))
                angle = time * knobs.b
                s = 0.3 + knobs.a * 0.6
                p = (corner - 0.5) * s
                rotated = float2(p.x * cos(angle) - p.y * sin(angle), p.x * sin(angle) + p.y * cos(angle))
                return V(position=float4(rotated, 0.0, 1.0), uv=corner * 0.5)

            def fragment(v: V, knobs: Knobs) -> float4:
                return float4(mix(knobs.tint.xyz, float3(v.uv, 1.0), knobs.c), 1.0)
            """, vertices: 3),
    ]
}

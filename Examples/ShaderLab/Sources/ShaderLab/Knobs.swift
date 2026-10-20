//
//  Knobs.swift
//  ShaderLab
//
//  The sliders, as the input every shader in the lab may take: a parameter
//  `knobs: Knobs` of the class below, which the templates declare.
//
//      class Knobs:
//          tint: float4
//          a: float
//          b: float
//          c: float
//
//  `pack` writes the same fields in the same order.
//

import NucleantUI
import Observation

@MainActor @Observable
final class Knobs: ShaderInput {
    private(set) var tint = Color(hex: 0x4CD3FF)
    private(set) var a = 0.5
    private(set) var b = 0.5
    private(set) var c = 0.5

    static let tints: [Color] = [
        Color(hex: 0x4CD3FF), Color(hex: 0x3DF5A0), Color(hex: 0xFF7A1A), Color(hex: 0xE05CFF), Color(white: 0.95),
    ]

    func set(tint: Color) { self.tint = tint }
    func set(a: Double) { self.a = a }
    func set(b: Double) { self.b = b }
    func set(c: Double) { self.c = c }

    func pack(into bytes: inout [UInt8]) {
        tint.pack(into: &bytes)
        Float(a).pack(into: &bytes)
        Float(b).pack(into: &bytes)
        Float(c).pack(into: &bytes)
    }
}

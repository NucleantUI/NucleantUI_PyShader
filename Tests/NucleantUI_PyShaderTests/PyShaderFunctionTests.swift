//
//  PyShaderFunctionTests.swift
//  NucleantUI_PyShaderTests
//

import Foundation
import Observation
import Testing
import NucleantUI
import PyShader
@testable import NucleantUI_PyShader

@MainActor @Observable
private final class Glow {
    var intensity: Float = 1
}

/// Entry points by execution model, read from the module: 5 compute,
/// 0 vertex, 4 fragment.
private func models(_ words: [UInt32]) -> [UInt32] {
    var models: [UInt32] = []
    var index = 5
    while index < words.count {
        let count = Int(words[index] >> 16)
        if words[index] & 0xFFFF == 15 { models.append(words[index + 1]) }
        index += max(count, 1)
    }
    return models
}

@MainActor
struct PyShaderFunctionCompiling {

    static let compute = """
        class Glow:
            intensity: float

        def main(uv: float2, glow: Glow) -> float4:
            return float4(uv.x * glow.intensity, uv.y, 0.0, 1.0)
        """

    static let graphics = """
        class V:
            position: float4
            uv: float2

        def vertex(vertex_index: int) -> V:
            corner = float2(float((vertex_index << 1) & 2), float(vertex_index & 2))
            return V(position=float4(corner - 1.0, 0.0, 1.0), uv=corner * 0.5)

        def fragment(v: V) -> float4:
            return float4(v.uv, 0.0, 1.0)
        """

    @Test
    func aMainIsACompute() throws {
        let function = PyShaderFunction(Self.compute)
        #expect(function.error == nil)
        #expect(models(function.spirv) == [5])
        #expect(function.spirv == (try PyShader.compile(Self.compute, target: .nucleantUI).spirv))
    }

    @Test
    func aVertexAndFragmentAreAPair() {
        let function = PyShaderFunction(Self.graphics)
        #expect(function.error == nil)
        #expect(models(function.spirv) == [0, 4])
    }

    /// Both targets' reasons, since the source does not say which it meant.
    @Test
    func sourceThatDoesNotCompileSaysWhy() {
        let function = PyShaderFunction("def main(uv: float2) -> float4:\n    return nope\n")
        #expect(function.spirv.isEmpty)
        #expect(function.error?.contains("as a compute shader") == true)
        #expect(function.error?.contains("as a vertex + fragment pair") == true)
    }

    /// The same storage, not a second compile.
    @Test
    func theSameSourceIsCompiledOnce() {
        let one = PyShaderFunction(Self.compute)
        let two = PyShaderFunction(Self.compute)
        #expect(one.spirv.withUnsafeBufferPointer { $0.baseAddress } == two.spirv.withUnsafeBufferPointer { $0.baseAddress })
    }

    @Test
    func aFileCompilesAndAnEditIsSeen() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pyshaderfunction-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appendingPathComponent("glow.py")
        try Self.compute.write(to: file, atomically: true, encoding: .utf8)
        let before = PyShaderFunction(contentsOf: file)
        #expect(before.error == nil)
        #expect(models(before.spirv) == [5])
        try Self.graphics.write(to: file, atomically: true, encoding: .utf8)
        #expect(models(PyShaderFunction(contentsOf: file).spirv) == [0, 4])
    }

    @Test
    func aMissingFileSaysSo() {
        let function = PyShaderFunction(contentsOf: URL(fileURLWithPath: "/nonexistent/glow.py"))
        #expect(function.spirv.isEmpty)
        #expect(function.error?.contains("cannot read") == true)
    }

    /// The builder's values are the input class's fields.
    @Test
    func argumentsAreTheInputClass() {
        let glow = Glow()
        let function = PyShaderFunction(Self.compute) { glow.intensity }
        var bytes: [UInt8] = []
        function.input.pack(into: &bytes)
        #expect(bytes.count == 4)
        glow.intensity = 2
        bytes = []
        function.input.pack(into: &bytes)
        #expect(bytes.withUnsafeBytes { $0.load(as: Float.self) } == 2)
    }

    @Test
    func equalIsTheModuleAndTheInputObject() {
        let input = ShaderNoArguments()
        #expect(PyShaderFunction(Self.compute, input: input) == PyShaderFunction(Self.compute, input: input))
        #expect(PyShaderFunction(Self.compute, input: input) != PyShaderFunction(Self.graphics, input: input))
        #expect(PyShaderFunction(Self.compute, input: input) != PyShaderFunction(Self.compute, input: ShaderNoArguments()))
    }

    /// It is a `ShaderProtocol` type: `Shader<PyShaderFunction<…>>`.
    @Test
    func itIsAShaderView() {
        let view = Shader(PyShaderFunction(Self.compute))
        _ = view
    }
}

//
//  PyShaderFunction.swift
//  NucleantUI_PyShader
//

import Foundation
import NucleantUI
import PyShader

/// PyShader source — a string, or a `.py` file — compiled at run time into a
/// module NucleantUI runs anywhere a `ShaderProtocol` goes.
///
/// ```swift
/// let glow = PyShaderFunction("""
///     class Glow:
///         intensity: float
///         tint: float4
///
///     def main(uv: float2, glow: Glow) -> float4:
///         return glow.tint * glow.intensity * smoothstep(0.5, 0.0, distance(uv, float2(0.5)))
///     """) {
///     model.intensity
///     model.tint
/// }
/// Shader(glow)
/// ```
///
/// For source that is fixed when the app is built, compile it then instead —
/// PyShader's build plugin turns a `.py` into a `.spv` resource, which
/// `SpirvFunction` runs with no compiler in the app. This is for source the
/// app only has at run time: written in it, downloaded, generated.
///
/// The module defines `def main` — a compute shader, run over every pixel —
/// or `def vertex` and `def fragment` — a vertex + fragment pair. Which, the
/// compiler finds out: the source is compiled for the compute target, and
/// for the graphics one only if that fails. Its input is a `class` parameter
/// of the entry point, read whole (see PyShader's class input), packed by
/// `input`.
///
/// Compiled once per source for the life of the app, so a view rebuilt with
/// the same source does not compile it again. Source that does not compile
/// is an empty module, which draws nothing, and the reason is in `error`.
public struct PyShaderFunction<Input: ShaderInput>: ShaderProtocol {
    public let spirv: [UInt32]
    public let input: Input
    public let isAnimated: Bool
    /// Why the source did not compile — both targets' reasons — or `nil`.
    public let error: String?

    /// `source`, a whole PyShader module.
    @MainActor
    public init(_ source: String, input: Input, isAnimated: Bool = true) {
        self.init(compiled: PyShaderModules.compile(source: source), input: input, isAnimated: isAnimated)
    }

    /// The `.py` file at `url`; its imports are found beside it and in the
    /// nearest uv `.venv`, as `pyshaderc` finds them.
    @MainActor
    public init(contentsOf url: URL, input: Input, isAnimated: Bool = true) {
        self.init(compiled: PyShaderModules.compile(file: url), input: input, isAnimated: isAnimated)
    }

    private init(compiled: PyShaderModules.Compiled, input: Input, isAnimated: Bool) {
        self.spirv = compiled.words
        self.error = compiled.error
        self.input = input
        self.isAnimated = isAnimated
    }
}

extension PyShaderFunction where Input == ShaderNoArguments {
    /// A module that takes no input.
    @MainActor
    public init(_ source: String, isAnimated: Bool = true) {
        self.init(source, input: ShaderNoArguments(), isAnimated: isAnimated)
    }

    /// A `.py` file that takes no input.
    @MainActor
    public init(contentsOf url: URL, isAnimated: Bool = true) {
        self.init(contentsOf: url, input: ShaderNoArguments(), isAnimated: isAnimated)
    }
}

extension PyShaderFunction {
    /// A module whose input is the values `arguments` lists, in order — the
    /// fields of its input class.
    @MainActor
    public init<each Value: ShaderValue>(
        _ source: String,
        isAnimated: Bool = true,
        @ShaderArgumentsBuilder arguments: @escaping @MainActor () -> (repeat each Value)
    ) where Input == ShaderTupleArguments<repeat each Value> {
        self.init(source, input: ShaderTupleArguments(arguments), isAnimated: isAnimated)
    }

    /// A `.py` file whose input is the values `arguments` lists, in order.
    @MainActor
    public init<each Value: ShaderValue>(
        contentsOf url: URL,
        isAnimated: Bool = true,
        @ShaderArgumentsBuilder arguments: @escaping @MainActor () -> (repeat each Value)
    ) where Input == ShaderTupleArguments<repeat each Value> {
        self.init(contentsOf: url, input: ShaderTupleArguments(arguments), isAnimated: isAnimated)
    }
}

/// The same module reading the same input object, as `SpirvFunction` is.
extension PyShaderFunction: Equatable {
    public static func == (lhs: PyShaderFunction, rhs: PyShaderFunction) -> Bool {
        lhs.input === rhs.input && lhs.isAnimated == rhs.isAnimated && lhs.spirv == rhs.spirv
    }
}

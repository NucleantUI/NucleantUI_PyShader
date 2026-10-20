//
//  PyShaderModules.swift
//  NucleantUI_PyShader
//

import Foundation
import PyShader

/// Every PyShader module compiled so far, by source: what makes building a
/// `PyShaderFunction` in a view's body cheap after the first time.
@MainActor
final class PyShaderModules {
    struct Compiled {
        let words: [UInt32]
        let error: String?
    }

    private static var compiled: [String: Compiled] = [:]

    static func compile(source: String, textures: [String]) -> Compiled {
        cached("source\n" + source, textures: textures) { target in
            try PyShader.compile(source, target: target)
        }
    }

    /// Keyed by the file's path and what it holds now, so an edited file is
    /// compiled again.
    static func compile(file url: URL, textures: [String]) -> Compiled {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            return Compiled(words: [], error: "PyShader: cannot read \(url.path)")
        }
        return cached("file \(url.path)\n" + text, textures: textures) { target in
            try PyShader.compile(contentsOf: url, target: target)
        }
    }

    /// The compute target first; the graphics one only if that fails. The
    /// error, when both do, is both of theirs, since the source does not say
    /// which it was meant as.
    ///
    /// Both with the content image at binding 2 and `textures` from 4 up, all
    /// top-down, which is how NucleantUI hands a module every image it
    /// samples. PyShader declares the content image only when the source
    /// calls `layer(uv)`, so a source that does not is the same module
    /// either way.
    private static func cached(_ key: String, textures names: [String], _ compile: (ShaderTarget) throws -> CompiledShader) -> Compiled {
        let key = key + "\ntextures " + names.joined(separator: ",")
        if let hit = compiled[key] { return hit }
        let textures = names.enumerated().map { ShaderTexture(name: $1, binding: 4 + $0, isTopDown: true) }
        let compute = ShaderTarget.computeImage(.nucleantUI(samplesContent: true, contentIsTopDown: true, textures: textures))
        let graphics = ShaderTarget.graphics(.nucleantUI(samplesContent: true, contentIsTopDown: true, arguments: [], textures: textures))
        let result: Compiled
        do {
            result = Compiled(words: try compile(compute).spirv, error: nil)
        } catch let computeError {
            do {
                result = Compiled(words: try compile(graphics).spirv, error: nil)
            } catch let graphicsError {
                result = Compiled(
                    words: [],
                    error: "as a compute shader (def main): \(computeError)\n"
                        + "as a vertex + fragment pair (def vertex, def fragment): \(graphicsError)"
                )
            }
        }
        if let error = result.error {
            // Once per source: the result is kept, failure included.
            FileHandle.standardError.write(Data("NucleantUI_PyShader: the source did not compile\n\(error)\n".utf8))
        }
        compiled[key] = result
        return result
    }
}

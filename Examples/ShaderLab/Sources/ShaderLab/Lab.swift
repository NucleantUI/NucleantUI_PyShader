//
//  Lab.swift
//  ShaderLab
//
//  The source being edited and the shader last built from it. Run compiles
//  the source at run time — `PyShaderFunction` — with the knobs as its input;
//  source that does not compile leaves the last shader that did running, and
//  says why.
//

import NucleantUI
import NucleantUI_PyShader
import Observation

@MainActor @Observable
final class Lab {
    /// Edited in place by the editor.
    var source: String
    let knobs = Knobs()
    private(set) var running: PyShaderFunction<Knobs>
    /// What the compiler said about the source last run, if it refused it.
    private(set) var error: String?
    private(set) var vertices: Int
    /// The template the source came from, while it is still that template.
    private(set) var template: Template?

    init() {
        let first = Template.all[0]
        source = first.source
        vertices = first.vertices
        template = first
        running = PyShaderFunction(first.source, input: knobs)
    }

    /// Build the shader from the source as it is now.
    func run() {
        let built = PyShaderFunction(source, input: knobs)
        error = built.error
        if built.error == nil { running = built }
        if template?.source != source { template = nil }
    }

    func load(_ template: Template) {
        source = template.source
        vertices = template.vertices
        self.template = template
        run()
    }
}

//
//  ShaderLabApp.swift
//  ShaderLab
//
//  A PyShader editor: write a shader, press Run, see it. The source is
//  compiled while the app runs — `PyShaderFunction`, from
//  NucleantUI_PyShader — which is what a shader the app only has at run
//  time needs; one fixed when the app is built is compiled then instead, by
//  PyShader's build plugin. Errors from the compiler are shown under the
//  editor, while the shader that last compiled keeps running.
//
//  The sliders are the `Knobs` class every template takes as `knobs`: a
//  slider changes the model, and the shader reads the change through
//  observation without the preview being rebuilt.
//

import NucleantUI
import NucleantUI_PyShader

enum Theme {
    static let panel = Color.dynamic(light: Color(hex: 0xF4F4F6), dark: Color(hex: 0x1A1B1F))
    static let editor = Color.dynamic(light: Color.white, dark: Color(hex: 0x111216))
    static let faint = Color.dynamic(light: Color(white: 0, opacity: 0.45), dark: Color(white: 1, opacity: 0.45))
    static let accent = Color(hex: 0x4C8DFF)
    static let error = Color(hex: 0xFF5C5C)
}

@View
struct RootView {
    @State private var lab = Lab()

    var body: some View {
        HStack(spacing: 0) {
            EditorPane(lab: lab)
                .frame(width: 460)
                .frame(maxHeight: .infinity)
                .background(Theme.panel)

            VStack(spacing: 0) {
                Preview(lab: lab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                KnobsPanel(knobs: lab.knobs)
                    .background(Theme.panel)
            }
        }
    }
}

/// The running shader. Reads which shader is running, not the knobs.
@View
struct Preview {
    let lab: Lab

    var body: some View {
        Shader(lab.running, vertices: lab.vertices)
    }
}

@main
struct ShaderLabApp: NucleantApp {
    var body: some Scene {
        WindowGroup("ShaderLab") {
            RootView()
        }
        .defaultSize(width: 1100, height: 680)
    }
}

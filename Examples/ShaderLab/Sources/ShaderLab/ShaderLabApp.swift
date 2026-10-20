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
//  An effect template runs over a card of ordinary views instead, through
//  `.shader(_:)`, which is generic over the `ShaderProtocol` type as
//  `Shader` is: the card is drawn into a layer the shader reads with
//  `layer(uv)`.
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

/// The running shader — on its own, or as an effect over a sample card,
/// which it reads with `layer(uv)`. Reads which shader is running, not the
/// knobs.
@View
struct Preview {
    let lab: Lab

    var body: some View {
        if lab.isEffect {
            SampleCard()
                .shader(lab.running)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Shader(lab.running, vertices: lab.vertices)
        }
    }
}

/// What an effect template runs over: an ordinary card of views.
@View
struct SampleCard {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Now Playing")
                .font(.footnote)
                .foregroundColor(Theme.faint)
            Text("Shaders in Python")
                .font(.system(size: 26, weight: .bold))
            HStack(spacing: 10) {
                Circle().fill(Theme.accent).frame(width: 18, height: 18)
                Capsule().fill(Color(hex: 0x3DF5A0)).frame(width: 140, height: 10)
                Capsule().fill(Color(hex: 0xFF7A1A)).frame(width: 60, height: 10)
            }
            Text("Every pixel here is drawn by the views first, then read by the shader through layer(uv).")
                .foregroundColor(Theme.faint)
        }
        .padding(24)
        .frame(width: 420)
        .background(Theme.panel)
        .cornerRadius(16)
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

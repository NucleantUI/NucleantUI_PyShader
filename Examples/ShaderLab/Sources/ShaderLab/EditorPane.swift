//
//  EditorPane.swift
//  ShaderLab
//

import NucleantUI

/// The templates, the source, Run, and what the compiler said.
@View
struct EditorPane {
    @Bindable var lab: Lab

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ForEach(Template.all) { template in
                    Text(template.name)
                        .padding(horizontal: 10, vertical: 5)
                        .background(lab.template == template ? Theme.accent.opacity(0.3) : Theme.editor)
                        .cornerRadius(6)
                        .onTapGesture { lab.load(template) }
                }
                Spacer()
                Button("Run") { lab.run() }
                    .tint(Theme.accent)
            }

            TextEditor(text: $lab.source)
                .font(.system(size: 13, design: .monospaced))
                .padding(8)
                .background(Theme.editor)
                .cornerRadius(8)
                .frame(maxHeight: .infinity)

            if let error = lab.error {
                ScrollView(.vertical) {
                    Text(error)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Theme.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 120)
            } else {
                Text("Compiled. A def main runs over every pixel; def vertex and def fragment draw \(lab.vertices) vertices.")
                    .font(.footnote)
                    .foregroundColor(Theme.faint)
            }
        }
        .padding(16)
    }
}

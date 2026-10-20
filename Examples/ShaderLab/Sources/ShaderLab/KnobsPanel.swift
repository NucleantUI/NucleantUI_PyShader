//
//  KnobsPanel.swift
//  ShaderLab
//

import NucleantUI

/// The sliders and the tint, the fields of `class Knobs`.
@View
struct KnobsPanel {
    let knobs: Knobs

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("knobs.tint")
                    .font(.system(size: 13, design: .monospaced))
                    .frame(width: 96, alignment: .leading)
                ForEach(Knobs.tints.indices, id: \.self) { index in
                    let tint = Knobs.tints[index]
                    Circle()
                        .fill(tint)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(knobs.tint == tint ? Theme.accent : Color.clear, lineWidth: 2))
                        .onTapGesture { knobs.set(tint: tint) }
                }
            }
            KnobSlider(name: "knobs.a", value: Binding(get: { knobs.a }, set: { knobs.set(a: $0) }))
            KnobSlider(name: "knobs.b", value: Binding(get: { knobs.b }, set: { knobs.set(b: $0) }))
            KnobSlider(name: "knobs.c", value: Binding(get: { knobs.c }, set: { knobs.set(c: $0) }))
        }
        .padding(16)
    }
}

@View
struct KnobSlider {
    let name: String
    let value: Binding<Double>

    var body: some View {
        HStack(spacing: 12) {
            Text(name)
                .font(.system(size: 13, design: .monospaced))
                .frame(width: 96, alignment: .leading)
            Slider(value: value, in: 0...1)
            Text(String(format: "%.2f", value.wrappedValue))
                .font(.footnote)
                .foregroundColor(Theme.faint)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

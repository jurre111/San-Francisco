//
//  SymbolCustomizeView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct ColorItem: Hashable {
    var name: String
    var color: Color
}
let colors: [ColorItem] = [
    ColorItem(name: "Red", color: .red),
    ColorItem(name: "Orange", color: .orange),
    ColorItem(name: "Yellow", color: .yellow),
    ColorItem(name: "Green", color: .green),
    ColorItem(name: "Mint", color: .mint),
    ColorItem(name: "Teal", color: .teal),
    ColorItem(name: "Cyan", color: .cyan),
    ColorItem(name: "Blue", color: .blue),
    ColorItem(name: "Indigo", color: .indigo),
    ColorItem(name: "Purple", color: .purple),
    ColorItem(name: "Pink", color: .pink),
    ColorItem(name: "Brown", color: .brown),
    ColorItem(name: "White", color: .white),
    ColorItem(name: "Gray", color: .gray),
    ColorItem(name: "Black", color: .black),
    ColorItem(name: "Primary", color: .primary),
    ColorItem(name: "Secondary", color: .secondary),
    ColorItem(name: "Tertiary", color: Color(UIColor.tertiaryLabel))
]

struct SymbolCustomizeView: View {
    @State private var isFavorite: Bool = false
    @State private var page: Int = 0
    let symbol: sfmgr.Symbol

    var body: some View {
        if page == 0 {
            if #available(iOS 18.0, *) {
                iOS18(symbol: symbol, page: $page)
            }
        } else {
            NavigationStack {
                List {
                    Section {
                        Picker("", selection: $page) {
                            Image(systemName: "paintbrush").tag(0)
                            Image(systemName: "circle.dotted.and.circle").tag(1)
                        }
                        .pickerStyle(.segmented)
                    }
                    Section {
                        Text("Animation")
                    }
                }
                .navigationTitle("Animation")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

@available(iOS 18.0, *)
struct iOS18: View {
    let symbol: sfmgr.Symbol
    @State private var isFavorite: Bool = false
    @Binding var page: Int

    @State private var infoSheet: sfmgr.Symbol? = nil
    
    @State private var renderingMode: String = "monochrome"
    @State private var variableColor: (enabled: Bool, value: Double) = (false, 1.0)
    
    @State private var color: ColorItem = ColorItem(name: "Blue", color: .blue)
    @State private var customColor: (enabled: Bool, value: Color) = (false, .blue)
    @State private var opacity: Double = 1.0
    @State private var opacityFocused: Bool = false

    @State private var BGColor: Color = Color(UIColor.secondarySystemGroupedBackground)
    @State private var customBGColor: (enabled: Bool, value: Color) = (false, Color(UIColor.secondarySystemGroupedBackground))
    

    var body: some View {
        NavigationStack {
            List{
                Section {
                    Picker("", selection: $page) {
                        Image(systemName: "paintbrush").tag(0)
                        Image(systemName: "circle.dotted.and.circle").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                ZStack {
                    Color.clear
                        .frame(maxWidth: .infinity, alignment: .center)
                        .aspectRatio(1.0, contentMode: .fit)
                    Image(systemName: symbol.name, variableValue: variableColor.value)
                        .symbolRenderingMode(getRenderingMode(from: renderingMode))
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(customColor.enabled ? customColor.value : color.color)
                        .opacity(opacity)
                        .padding(25)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(customBGColor.enabled ? customBGColor.value : BGColor)
                )
                Section {
                    Picker(selection: $renderingMode) {
                        Text("Monochrome").tag("monochrome")
                        Text("Hierarchical").tag("hierarchical")
                        Text("Palette").tag("palette")
                        Text("Multicolor").tag("multicolor")              
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "paintpalette")
                            Text("Rendering Mode")
                        }
                    }
                    Toggle(isOn: $variableColor.enabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "slider.horizontal.below.square.and.square.filled")
                                .frame(width: 20, alignment: .center)
                            Text("Variable")
                        }
                    }
                    if variableColor.enabled {
                        HStack {
                            Slider(value: $variableColor.value, in: 0.0...1.0, step: 0.01)
                            Text("\(Int(variableColor.value * 100))%")
                                .foregroundColor(.secondary)
                        }
                    }

                }
                Section {
                    Picker("", selection: $customColor.enabled) {
                        Text("System").tag(false)
                        Text("Custom").tag(true)
                    }
                    .pickerStyle(.segmented)
                    HStack(spacing: 12) {
                        Text("Color")
                        Spacer()
                        if customColor.enabled {
                            ColorPicker("", selection: $customColor.value)
                                .labelsHidden()
                                .frame(width: 40)
                        } else {
                            Menu {
                                Picker("", selection: $color) {
                                    ForEach(colors, id: \.self) { entry in
                                        Label {
                                            Text(entry.name)
                                        } icon: {
                                            Image(systemName: "circle.fill")
                                                .foregroundColor(entry.color)
                                                .symbolRenderingMode(.palette)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(color.color)
                                        .font(.system(size: 12))
                                        .symbolRenderingMode(.palette)
                                    Text(color.name)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    HStack {
                        Text("Opacity")
                        Spacer()
                        TextField("100", text: Binding(
                            get: { "\(Int(opacity*100))" },
                            set: { newValue in
                                if let newValue = Double(newValue) {
                                    if newValue > 100 {
                                        opacity = 1.0
                                    } else if newValue < 0 {
                                        opacity = 0
                                    } else {
                                        opacity = newValue / 100
                                    }
                                } else {
                                    if newValue.isEmpty {
                                        opacity = 1.0
                                    }
                                }
                            }
                        ))
                        .foregroundColor(.secondary)
                        .monospaced()
                        .scrollDismissesKeyboard(.immediately)
                        .multilineTextAlignment(.trailing)
                    }
                    Slider(value: $opacity, in: 0.0...1.0, step: 0.01)
                }
                Section {
                    Picker("", selection: $customBGColor.enabled) {
                        Text("System").tag(false)
                        Text("Custom").tag(true)
                    }
                    .pickerStyle(.segmented)
                    HStack(spacing: 12) {
                        Text("Background")
                        Spacer()
                        if customBGColor.enabled {
                            ColorPicker("", selection: $customBGColor.value)
                                .labelsHidden()
                                .frame(width: 40)
                        } else {
                            // Image(systemName: "circle.fill")
                            //     .foregroundColor(BGColor)
                            //     .font(.system(size: 10))
                            // Picker(selection: $BGColor) {
                            //     ColorView(color: Color(UIColor.secondarySystemGroupedBackground), name: "Default").tag(Color(UIColor.secondarySystemGroupedBackground))
                            //     ColorView(color: Color(UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))), name: "Light").tag(Color(UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))))
                            //     ColorView(color: Color(UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))), name: "Dark").tag(Color(UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))))
                            // } label: {
                            //     Text("Background")
                            // }
                        }
                    }
                }
            }
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $infoSheet) { symbol in
                SymbolInfoView(symbol: symbol)
            }
            .toolbar {
                Button {
                    sfmgr.shared.toggleFavorite(symbol: symbol.name)
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                }
                Button {
                    infoSheet = symbol
                } label: {
                    Image(systemName: "info.circle")
                }
            }
            .onAppear {
                isFavorite = sfmgr.shared.favorites.contains(symbol.name)
            }
        }
    }
}

func getRenderingMode(from string: String) -> SymbolRenderingMode? {
    switch string {
        case "default":
            return nil
        case "multicolor":
            return .multicolor
        case "hierarchical":
            return .hierarchical
        case "palette":
            return .palette
        case "monochrome":
            return .monochrome
        default:
            return nil
    }
}
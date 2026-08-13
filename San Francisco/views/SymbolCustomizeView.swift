//
//  SymbolCustomizeView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolCustomizeView: View {
    @State private var isFavorite: Bool = false
    @State private var page: Int = 0
    let symbol: sfmgr.Symbol

    var body: some View {
        if page == 0 {
            if #available(iOS 26.0, *) {
                iOS26(symbol: symbol)
            } else if #available(iOS 18.0, *) {
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

@available(iOS 26.0, *)
struct iOS26: View {
    @State private var infoSheet: sfmgr.Symbol? = nil
    @State private var renderingMode: String = "monochrome"
    @State private var color: Color = .blue
    @State private var BGcolor: Color = .white
    @State private var isFavorite: Bool = false
    @State private var gradientOn = false
    @State private var variableColor: (enabled: Bool, value: Double) = (false, 1.0)
    let symbol: sfmgr.Symbol

    var body: some View {
        NavigationStack {
            List{
                ZStack {
                    Color.clear
                        .frame(maxWidth: .infinity, alignment: .center)
                        .aspectRatio(1.0, contentMode: .fit)
                    Image(systemName: symbol.name, variableValue: variableColor.value)
                        .symbolRenderingMode(getRenderingMode(from: renderingMode))
                        .font(.system(size: 220))
                        .foregroundColor(color)
                        .background(BGcolor)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                HStack(spacing: 12) {
                     VStack(alignment: .center, spacing: 12) {
                        Image(systemName: symbol.name)
                            .symbolRenderingMode(.monochrome)
                            .font(.system(size: 75))
                            .foregroundColor(color)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                            .opacity(renderingMode == "monochrome" ? 1.0 : 0.0)
                    }
                    Spacer()
                     VStack(alignment: .center, spacing: 12) {
                        Image(systemName: symbol.name)
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 75))
                            .foregroundColor(color)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                            .opacity(renderingMode == "hierarchical" ? 1.0 : 0.0)
                    }
                    Spacer()
                     VStack(alignment: .center, spacing: 12) {
                        Image(systemName: symbol.name)
                            .symbolRenderingMode(.palette)
                            .font(.system(size: 75))
                            .foregroundColor(color)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                            .opacity(renderingMode == "palette" ? 1.0 : 0.0)
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: symbol.name)
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 75))
                            .foregroundColor(color)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                            .opacity(renderingMode == "multicolor" ? 1.0 : 0.0)
                    }
                }
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
                    Toggle(isOn: $gradientOn) {
                        HStack(spacing: 12) {
                            Image(systemName: "circle.fill")
                                .frame(width: 20, alignment: .center)
                                .foregroundStyle(.blue)
                                .symbolColorRenderingMode(.gradient)
                            Text("Gradients")
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
                    HStack(spacing: 12) {
                        Text("Color")
                        Spacer()
                        ColorPicker("Color", selection: $color)
                            .labelsHidden()
                            .frame(width: 40)
                    }
                }
                Section {
                    HStack(spacing: 12) {
                        Text("Background")
                        Spacer()
                        ColorPicker("Color", selection: $BGcolor)
                            .labelsHidden()
                            .frame(width: 40)
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

@available(iOS 18.0, *)
struct iOS18: View {
    let symbol: sfmgr.Symbol
    @State private var isFavorite: Bool = false
    @Binding var page: Int

    @State private var infoSheet: sfmgr.Symbol? = nil
    
    @State private var renderingMode: String = "monochrome"
    @State private var variableColor: (enabled: Bool, value: Double) = (false, 1.0)
    
    @State private var color: Color = .blue
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
                        // .aspectRatio(1.0, contentMode: .fit)
                    Image(systemName: symbol.name, variableValue: variableColor.value)
                        .symbolRenderingMode(getRenderingMode(from: renderingMode))
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(customColor.enabled ? customColor.value : color)
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
                            Image(systemName: "circle.fill")
                                .foregroundColor(color)
                                .font(system(size: 10))
                            Picker("", selection: $color) {
                                ColorView(color: Color.red, name: "Red").tag(Color.red)
                                ColorView(color: Color.orange, name: "Orange").tag(Color.orange)
                                ColorView(color: Color.yellow, name: "Yellow").tag(Color.yellow)
                                ColorView(color: Color.green, name: "Green").tag(Color.green)
                                ColorView(color: Color.mint, name: "Mint").tag(Color.mint)
                                ColorView(color: Color.teal, name: "Teal").tag(Color.teal)
                                ColorView(color: Color.cyan, name: "Cyan").tag(Color.cyan)
                                ColorView(color: Color.blue, name: "Blue").tag(Color.blue)
                                ColorView(color: Color.indigo, name: "Indigo").tag(Color.indigo)
                                ColorView(color: Color.purple, name: "Purple").tag(Color.purple)
                                ColorView(color: Color.pink, name: "Pink").tag(Color.pink)
                                ColorView(color: Color.brown, name: "Brown").tag(Color.brown)
                                ColorView(color: Color.white, name: "White").tag(Color.white)
                                ColorView(color: Color.gray, name: "Gray").tag(Color.gray)
                                ColorView(color: Color.black, name: "Black").tag(Color.black)
                                ColorView(color: Color.primary, name: "Primary").tag(Color.primary)
                                ColorView(color: Color.secondary, name: "Secondary").tag(Color.secondary)
                                ColorView(color: Color(UIColor.tertiaryLabel), name: "Tertiary").tag(Color(UIColor.tertiaryLabel))
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
                        .keyboardType(.numberPad)
                        .scrollDismissesKeyboard(.interactively)
                        .multilineTextAlignment(.trailing)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    opacityFocused = false
                                }
                            }
                        }
                    }
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
                            Image(systemName: "circle.fill")
                                .foregroundColor(BGColor)
                                .font(system(size: 10))
                            Picker("", selection: $BGColor) {
                                ColorView(color: Color(UIColor.secondarySystemGroupedBackground), name: "Default").tag(Color(UIColor.secondarySystemGroupedBackground))
                                ColorView(color: Color(UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))), name: "Light").tag(Color(UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))))
                                ColorView(color: Color(UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))), name: "Dark").tag(Color(UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))))
                            }
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

struct ColorView: View {
    let color: Color
    let name: String
    @Environment(\.isPartOfMenu) private var isPartOfMenu
    var body: some View {
        HStack {
            Text(name)
            if isPartOfMenu {
                Image(systemName: "circle.fill")
                    .foregroundColor(color)
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
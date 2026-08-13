//
//  SymbolCustomizeView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolCustomizeView: View {
    @State private var isFavorite: Bool = false
    let symbol: sfmgr.Symbol

    var body: some View {
        if #available(iOS 26.0, *) {
            iOS26(symbol: symbol)
        } else if #available(iOS 18.0, *) {
            iOS18(symbol: symbol)
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
    @State private var infoSheet: sfmgr.Symbol? = nil
    @State private var renderingMode: String = "monochrome"
    @State private var color: Color = .blue
    @State private var BGcolor: String = "system"
    @State private var customBGColor: Color = Color(UIColor.secondarySystemGroupedBackground)
    @State private var isFavorite: Bool = false
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
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(getColor(from: BGcolor) ?? customBGColor)
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
                        Picker("", selection: $BGcolor) {
                            ColorView(color: Color(UIColor.secondarySystemGroupedBackground), name: "System").tag("system")
                            ColorView(color: Color.white, name: "White").tag("white")
                            ColorView(color: Color.black, name: "Black").tag("black")
                            ColorView(color: Color.gray, name: "Gray").tag("gray")
                            ColorView(color: customBGColor, name: "Custom").tag("custom")
                        }
                        if BGcolor == "custom" {
                            ColorPicker("", selection: $customBGColor)
                                .labelsHidden()
                                .frame(width: 40)
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
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .frame(width: 20, alignment: .center)
                .foregroundStyle(color)
            Text(name)
            
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

func getColor(from string: String) -> Color? {
    switch string {
        case "system":
            return Color(UIColor.secondarySystemGroupedBackground)
        case "white":
            return .white
        case "black":
            return .black
        case "blue":
            return .blue
        case "red":
            return .red
        case "green":
            return .green
        case "yellow":
            return .yellow
        case "orange":
            return .orange
        case "pink":
            return .pink
        case "purple":
            return .purple
        case "gray":
            return .gray
        case "custom":
            return nil
        default:
            return .blue
    }
}
//
//  Stylers.swift
//  xCore
//
//  Created by Олег Сазонов on 13.07.2022.
//

import Foundation
import SwiftUI

public class Stylers: xCore {
    public override init() {}
    
    /// Is what it is
    public struct SpikyProgressViewStyle: ProgressViewStyle {
        public init() {}
        public func makeBody(configuration: Configuration) -> some View {
            
            let degrees = (1 - configuration.fractionCompleted!) * 360
            let percent = Int(configuration.fractionCompleted! * 100)
            
            return VStack {
                ZStack{
                    Text("\(percent)%")
                        .fontWeight(.ultraLight)
                        .foregroundColor(percent < 50 ? .primary : (percent < 75) ? .blue : (percent > 75) ? .red : .red)
                        .shadow(radius: 5)
                    CustomCircle(startAngle: .degrees(1), endAngle: .degrees(360 - degrees), trim: CGFloat(percent))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .shadow(radius: 15)
                        .padding(50)
                        .foregroundColor(percent < 50 ? .blue : (percent < 75) ? .green : (percent >= 75) ? .yellow : (percent > 90) ? .primary : .primary)
                        .animation(SettingsMonitor.secondaryAnimation, value: percent)
                        .animation(SettingsMonitor.secondaryAnimation, value: degrees)
                }
                configuration.currentValueLabel
                configuration.label
            }
        }
    }
    
    fileprivate struct CustomCircle: Shape {
        var startAngle: Angle
        var endAngle: Angle
        var trim: CGFloat
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                        radius: rect.width / 2,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false)
            return path.strokedPath(.init(lineWidth: trim / 100 * 80 < 50 ?
                                          50 : trim / 100 * 80,
                                          lineJoin: .round,
                                          dash: [1.5, 3],
                                          dashPhase: 0))
        }
    }
    
    /// Glass backgound of view
    public struct VisualEffectView: NSViewRepresentable {
        public init() {
            
        }
        public func makeNSView(context: Context) -> NSVisualEffectView {
            let view = NSVisualEffectView()
            
            view.blendingMode = .behindWindow    // << important !!
            view.isEmphasized = true
            view.material = NSVisualEffectView.Material.hudWindow//sidebar
            return view
        }
        
        public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        }
    }
    
    /// Is what it is
    public struct GlassyTextField: TextFieldStyle {
        public init(){}
        public func _body(configuration: TextField<Self._Label>) -> some View {
            HStack{
                configuration
                    .multilineTextAlignment(.center)
            }
            .padding(.all)
            //            .background(.ultraThinMaterial)
            .background(content: {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.ultraThinMaterial)
                    .shadow(radius: 5)
                    .blur(radius: 5)
            })
            .foregroundColor(.primary)
            //            .cornerRadius(6)
            //        .frame(width: 300)
        }
    }
    /// Is what it is
    public struct GlassySecureField: TextFieldStyle {
        public init(){}
        public func _body(configuration: TextField<Self._Label>) -> some View {
            HStack{
                Image(systemName: "key").foregroundColor(.gray)
                configuration
                    .multilineTextAlignment(.center)
            }
            .padding(.all)
            //            .background(.ultraThinMaterial)
            .background(content: {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.ultraThinMaterial)
                    .blur(radius: 5)
                    .shadow(radius: 5)
            })
            //            .cornerRadius(6)
            //        .frame(width: 300)
        }
    }
    
    /// V-mark checkbox style
    public struct CheckboxStyle: ToggleStyle {
        var str: String!
        
        public func makeBody(configuration: Self.Configuration) -> some View {
            
            return VStack {
                
                configuration.label
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(configuration.isOn ? .blue : .gray)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onTapGesture {
                        configuration.isOn.toggle()
                    }
                Text(StringLocalizer(str))
            }
            
        }
    }
    
    /// Is what it is
    public struct CustomCircularProgressViewStyle: ProgressViewStyle {
        public func makeBody(configuration: Configuration) -> some View {
            ZStack {
                Circle()
                    .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                    .stroke(.gray, style: StrokeStyle(lineWidth: 5, dash: [10, 5]))
                    .rotationEffect(.degrees(-90))
                //                .frame(width: 200)
            }
        }
    }
    
    public struct CustomGBStyle: GroupBoxStyle {
        public init() {}
        @State private var isRun = false
        public func makeBody(configuration: Configuration) -> some View {
            VStack {
                HStack {
                    if isRun {
                        configuration.label
                        //                            .font(.headline)
                        Spacer()
                    } else {
                        Spacer()
                    }
                }
                Divider()
                if isRun {
                    configuration.content
                } else {
                    Spacer()
                }
            }
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.clear))
            .animation(SettingsMonitor.secondaryAnimation, value: DispatchTime.now())
            .onAppear {
                isRun = true
            }
        }
    }
    
    public struct ColoredButtonStyle: ButtonStyle {
        public init(
            glyph: String = "",
            glyphs: [String] = [""],
            disabled: Bool = false,
            enabled: Bool = false,
            alwaysShowTitle: Bool = false,
            hideTitle: Bool = false,
            width: CGFloat = 200,
            height: CGFloat = 100,
            color: Color = .clear,
            hideBackground: Bool = false,
            backgroundIsNotFill: Bool = false,
            blurBackground: Bool = true,
            backgroundShadow: Bool = true,
            swapItems: Bool = false,
            render: SymbolRenderingMode = .multicolor,
            glow: Bool = true,
            alwaysGlow: Bool = false
        )
        {
            image = glyph
            imageArray = glyphs
            self.disabled = disabled
            self.enabled = enabled
            self.width = width
            onHoverColor = color
            self.height = height
            self.alwaysShowTitle = alwaysShowTitle
            self.hideBackground = hideBackground
            self.backgroundIsNotFill = true
            self.blurBackgound = false
            self.backgroundShadow = backgroundShadow
            self.swapItems = swapItems
            self.render = render
            self.glow = glow
            self.hideTitle = hideTitle
            self.alwaysGlow = alwaysGlow
        }
        var swapItems: Bool
        var image: String
        var backgroundIsNotFill: Bool
        var height: CGFloat
        var alwaysShowTitle: Bool
        var imageArray: [String]
        var hideTitle: Bool
        var disabled: Bool
        var enabled: Bool
        var width: CGFloat
        var onHoverColor: Color
        var hideBackground: Bool
        var backgroundShadow: Bool
        var blurBackgound: Bool
        var render: SymbolRenderingMode
        var glow: Bool
        var alwaysGlow: Bool
        @Environment(\.isEnabled) var isEnabled
        @State private var hovered: Bool = false
        
        func drawBackround() -> some View {
            ZStack{
                if backgroundIsNotFill {
                    Group{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(enabled ? onHoverColor : hovered && !disabled ? onHoverColor : .clear)
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(radius: backgroundShadow ? 5 : 0)
                    }
                    .blur(radius: blurBackgound ? 5 : 0)
                } else {
                    Group{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(enabled ? onHoverColor : hovered && !disabled ? onHoverColor : .clear)
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ultraThinMaterial)
                            .shadow(radius: backgroundShadow ? 5 : 0)
                    }
                    .frame(width: width, height: height, alignment: .center)
                    .blur(radius: blurBackgound ? 5 : 0)
                }
            }
        }
        
        private func addImage() -> some View {
            VStack{
                if image == "darkModeGlyph" {
                    CustomViews.DarkModeIcon(30).padding(.all)
                }else {
                    if image == "β" || image == "𝛼" || image == "ω" {
                        Text(image)
                            .shadow(radius: 2)
                            .font(.custom("San Francisco", size: 30))
                            .foregroundColor(disabled ? .gray : .primary)
                            .padding(.all)
                    } else {
                        if imageArray.first != "" || image != "" {
                            ZStack{
                                Group{
                                    if image == "" {
                                        ForEach(imageArray, id: \.self) { image in
                                            Image(systemName: image).symbolRenderingMode(render)
                                        }
                                    } else if imageArray.first == "" {
                                        Image(systemName: image).symbolRenderingMode(render)
                                    }
                                }
                                .shadow(radius: 2)
                                .font(.custom("San Francisco", size: 30))
                                .foregroundColor(disabled ? .gray : .primary)
                                .padding(.all)
                            }
                        }
                    }
                }
            }
        }
        
        private func addLabel(_ configuration: Configuration) -> some View {
            VStack{
                Group{
                    if !alwaysShowTitle {
                        if hovered || enabled {
                            configuration.label
                        }
                    } else {
                        configuration.label
                    }
                }
                .multilineTextAlignment(.center)
                .allowsHitTesting(!disabled)
                .foregroundColor(disabled ? .gray : .primary)
                .disabled(disabled)
                .padding(.all)
            }
        }
        
        public func makeBody(configuration: Configuration) -> some View {
            HStack{
                addImage()
                if !hideTitle {
                    addLabel(configuration)
                }
            }
            .background(content: {
                if !hideBackground {
                    drawBackround()
                }
            })
            .frame(width: width, height: height, alignment: .center)
            .animation(SettingsMonitor.secondaryAnimation, value: hovered)
            .animation(SettingsMonitor.secondaryAnimation, value: !hovered)
            .onHover(perform: { t in
                self.hovered = t
            })
            .disabled(disabled)
            .glow(color: alwaysGlow ? onHoverColor : glow && hovered && !disabled ? onHoverColor : .clear, anim: hovered)
        }
    }
}

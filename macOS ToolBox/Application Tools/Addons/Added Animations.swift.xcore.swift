//
//  AddedAnimations.swift
//  xCore
//
//  Created by Олег Сазонов on 09.11.2022.
//

import Foundation
import SwiftUI

// MARK: - Pulsing Animation

private struct PulsingAnimation: ViewModifier {
    @State private var isOn: Bool = false
    var direction: MoveDirection
    var color: Color
    func body(content: Content) -> some View {
        let colorComponents = NSColor(color).cgColor.components!
        let colors = stride(from: 0, to: 1, by: 0.01).map { value in
            Color(.displayP3, red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], opacity: value)
        }
        let clearStride = stride(from: 0, to: 1, by: 0.01).map { value in
            Color(.clear)
        }
        
        return content.overlay(GeometryReader { proxy in
            ZStack {
                if direction == .inOut || direction == .outIn {
                    RadialGradient(gradient: Gradient(colors: (colors) + colors.reversed() + clearStride + clearStride),
                                   center: .center,
                                   startRadius: (!self.isOn ? 0 : proxy.size.width),
                                   endRadius: 0)
                        .frame(width: proxy.size.width)
                        .clipped(antialiased: true)
                        .transition(.opacity)
                } else {
                    LinearGradient(gradient: Gradient(colors: colors + colors), startPoint: .trailing, endPoint: .leading)
                        .frame(width: 2*proxy.size.width)
                        .offset(x: self.isOn ? -proxy.size.width : 0)
                        .clipped(antialiased: true)
                        .transition(.opacity)
                }
            }
            .blur(radius: 15)
        })
        .flipped(direction == .leftToRight ? .horizontal : .none, anchor: .center)
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                    isOn = true
                }
            }
        }
        .onChange(of: direction, perform: { _ in
            isOn = false
            DispatchQueue.main.async {
                withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                    isOn = true
                }
            }
        })
        .onChange(of: color, perform: { _ in
            isOn = false
            DispatchQueue.main.async {
                withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                    isOn = true
                }
            }
        })
        .transition(.opacity)
        .mask(content)
    }
}

public extension View {
    func pulsingAnimation(Direction: MoveDirection, Color: Color) -> some View {
        self.modifier(PulsingAnimation(direction: Direction, color: Color))
    }
}

// MARK: - Rainbow Animation

public enum animationDirection {
    case leading
    case trailing
}
private struct RainbowAnimation: ViewModifier {
    @State var isOn: Bool = false
    @State var animationDirection: animationDirection = .leading
    var animation: Animation {
        Animation
            .linear(duration: 4)
            .repeatForever(autoreverses: false)
    }
    let colors = stride(from: 0, to: 1, by: 0.01).map {
        Color(hue: $0, saturation: 1, brightness: 1)
    }
    
    func body(content: Content) -> some View {
        let gradient = LinearGradient(gradient: Gradient(colors: colors+colors), startPoint: animationDirection == .leading ? .leading : .trailing, endPoint: animationDirection == .leading ? .trailing : .leading)
        return content.overlay(GeometryReader { proxy in
            ZStack {
                gradient
                    .frame(width: 2*proxy.size.width)
                    .offset(x: self.isOn ? -proxy.size.width : 0)
                    .clipped(antialiased: true)
            }.blur(radius: 15)
        })
        .onAppear {
            withAnimation(self.animation) {
                self.isOn = true
            }
        }
        .mask(content)
    }
}

public extension View {
    func rainbowAnimation(Direction: animationDirection = .leading) -> some View {
        self.modifier(RainbowAnimation(animationDirection: Direction)).transition(.opacity)
    }
}

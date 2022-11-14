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
    @State var animate = false
    var direction: MoveDirection
    var color: Color = .brown
    
    func maxScale(_ l: Double) -> Double {
        return l / 3
    }
    var animation: Animation {
        .linear(duration: 1/6)
        .speed(1 / 6)
        .repeatForever(autoreverses: false)
    }

    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            VStack{
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.clear)
                    ZStack{
                        HStack{
                            if direction != .leftToRight {
                                Spacer()
                            }
                            Circle()
                                .stroke(style: .init(lineWidth: 10, lineCap: .round))
                                .foregroundColor(color)
                                .scaleEffect(animate ? maxScale(proxy.size.height) : 0.01)
                                .animation(animation, value: animate)
                            if direction != .rightToLeft {
                                Spacer()
                            }
                        }
                    }
                    .blur(radius: 15)
                    .frame(width: proxy.size.width - 30, height: proxy.size.height - 30, alignment: .center)
                    .clipped(antialiased: true)
                }
            }
        })
        .onAppear {
            withAnimation(self.animation) {
                self.animate = true
            }
        }
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

//
//  Cool Circles.swift
//  xCore
//
//  Created by Олег Сазонов on 22.09.2022.
//

import SwiftUI

extension CustomViews {
    public struct CoolCircles: View {
        public init(size: State<CGSize> = State(wrappedValue: CGSize(width: 400, height: 400)),
                    bodyColor: State<Color> = State(wrappedValue: .white),
                    shadowColor: State<Color> = State(wrappedValue: .blue),
                    numberOfCircles: State<Int> = State(wrappedValue: 29),
                    animate: State<Bool> = State(wrappedValue: true),
                    stopAnimation: State<Bool> = State(wrappedValue: false),
                    perspective: State<Bool> = State(wrappedValue: true),
                    dash: State<[CGFloat]> = State(wrappedValue: [5, 3])
        ) {
            self._size = size
            self._color = bodyColor
            self._shadowColor = shadowColor
            self._numberOfCircles = numberOfCircles
            self._animate = animate
            self._stopAnimation = stopAnimation
            self._perspective = perspective
            self._dash = dash
        }
        @State var size: CGSize
        @State var color: Color
        @State var shadowColor: Color
        @State var numberOfCircles: Int
        @State var animate: Bool
        @State var stopAnimation: Bool
        @State var perspective: Bool
        @State var dash: [CGFloat]
        public var body: some View {
            ZStack {
                CustomCircleStruct(size: $size, color: $color, shadowColor: $shadowColor, numberOfCircles: $numberOfCircles, animate: $animate, stopAnimation: $stopAnimation, perspective: $perspective, dash: $dash)
            }
            .padding()
            .onAppear {
                animate.toggle()
            }
            .onChange(of: stopAnimation) { newValue in
                animate.toggle()
            }
        }
    }
    
    fileprivate struct CustomCircleStruct: View{
        @Binding var size: CGSize
        @Binding var color: Color
        @Binding var shadowColor: Color
        @Binding var numberOfCircles: Int
        @Binding var animate: Bool
        @Binding var stopAnimation: Bool
        @Binding var perspective: Bool
        @Binding var dash: [CGFloat]
        @State var offset: Double = 2
        var body: some View {
            ZStack{
                ForEach(0..<numberOfCircles, id: \.self) { index in
                    Round(size: $size,
                          color: $color,
                          shadowColor: $shadowColor,
                          animate: $animate,
                          stopAnimation: $stopAnimation,
                          perspective: $perspective,
                          dash: $dash)
                    .rotationEffect(Angle(degrees: 0 + Double(60 * index) ))//+ Double(offset * Double(index))))
                }
            }
        }
    }
    
    fileprivate struct Round: View {
        @Binding var size: CGSize
        @Binding var color: Color
        @Binding var shadowColor: Color
        @Binding var animate: Bool
        @Binding var stopAnimation: Bool
        @Binding var perspective: Bool
        @Binding var dash: [CGFloat]
        var body: some View {
            VStack{
                Circle()
                    .stroke(style: .init(lineWidth: size.width > size.height ? size.width / 100 : size.height / 100, lineCap: .butt, lineJoin: .round, dash: dash, dashPhase: 0))
                    .foregroundColor(color)
                    .rotation3DEffect(Angle(degrees: animate ? 0 : 180), axis: (x: 90, y: 180, z: 90), anchor: .center, anchorZ: 0, perspective: perspective ? 10 : 0)
                    .rotationEffect(Angle(degrees: animate ? 0 : 359))
                    .animation(stopAnimation ? .easeInOut(duration: 3) : .easeInOut(duration: 3).repeatForever(autoreverses: true), value: animate)
                    .animation(.easeInOut(duration: 3), value: perspective)
                    .animation(.easeInOut(duration: 3), value: color)
                    .animation(.easeInOut(duration: 3), value: shadowColor)
            }.frame(width: size.width, height: size.height, alignment: .center)
                .shadow(color: shadowColor, radius: 5)
        }
    }
}

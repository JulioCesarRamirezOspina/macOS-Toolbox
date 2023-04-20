//
//  Custom Views.swift
//  xCore
//
//  Created by Олег Сазонов on 31.07.2022.
//

import Foundation
import SwiftUI
import Charts

public class CustomViews {
    /// Is what it is
    public struct UTMLogo: View {
        public init(){}
        public var body: some View {
            GeometryReader { gr in
                Path { path in
                    path.addLines([
                        CGPoint(x: gr.size.width / 2, y: gr.size.height / 2),
                        CGPoint(x: gr.size.width / 2, y: gr.size.height / 2)
                    ])
                }
                .stroke(.cyan, style: .init(lineWidth: 20, lineCap: .round, lineJoin: .round))
                
                Path { path in
                    path.addRect(CGRect(x: gr.size.width / 8, y: gr.size.height / 8, width: gr.size.width - gr.size.width / 8 * 2, height: gr.size.height - gr.size.height / 8 * 2))
                }
                .stroke(.cyan, style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                
                Path { path in
                    path.addRect(CGRect(x: gr.size.width / 4, y: gr.size.height / 4, width: gr.size.width - gr.size.width / 4 * 2, height: gr.size.height - gr.size.height / 4 * 2))
                }
                .stroke(.blue, style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                
                Path { path in
                    path.addRect(CGRect(x: 0, y: 0, width: gr.size.width, height: gr.size.height))
                }
                .stroke(.blue, style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
            }
            .frame(width: 140, height: 140, alignment: .center)
            .opacity(0.5).blur(radius: 2)
            .shadow(radius: 15)
            .padding(.all)
        }
    }
    
    public struct ParallelsLogo: View {
        public init(){}
        
        public var body: some View {
            GeometryReader {gr in
                Path {twix in
                    twix.addLines([
                        .init(x: gr.size.width / 3, y: 0),
                        .init(x: gr.size.width / 3, y: gr.size.height)
                    ])
                    twix.closeSubpath()
                    twix.addLines([
                        .init(x: gr.size.width / 3 * 2, y: 0),
                        .init(x: gr.size.width / 3 * 2, y: gr.size.height)
                    ])
                }
                .stroke(RadialGradient(colors: [.red, .white], center: .center, startRadius: 0, endRadius: gr.size.height), style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
            }
            .frame(width: 140, height: 140, alignment: .center)
            .opacity(0.5).blur(radius: 2)
            .shadow(radius: 15)
            .padding(.all)
        }
    }
    
    public struct VBoxLogo: View {
        public init(){}
        public var body: some View {
            GeometryReader { gr in
                Path {leftSide in
                    leftSide.addLines([
                        CGPoint(x: gr.size.width / 2, y: gr.size.height / 3),
                        CGPoint(x: 0, y: gr.size.height / 6),
                        CGPoint(x: 0, y: gr.size.height - (gr.size.height / 6)),
                        CGPoint(x: gr.size.width / 2, y: gr.size.height)
                    ])
                    leftSide.closeSubpath()
                }
                .stroke(style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.green)
                Path {rightSide in
                    rightSide.addLines([
                        CGPoint(x: gr.size.width / 2, y: gr.size.height / 3),
                        CGPoint(x: gr.size.width, y: gr.size.height / 6),
                        CGPoint(x: gr.size.width, y: gr.size.height - (gr.size.height / 6)),
                        CGPoint(x: gr.size.width / 2, y: gr.size.height)
                    ])
                }
                .stroke(style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.red)
                Path {top in
                    top.addLines([
                        CGPoint(x: 0, y: gr.size.height / 6),
                        CGPoint(x: gr.size.width / 2, y: 0),
                        CGPoint(x: gr.size.width, y: gr.size.height / 6),
                        CGPoint(x: gr.size.width / 2, y: gr.size.height / 3),
                        CGPoint(x: 0, y: gr.size.height / 6)
                    ])
                }
                .stroke(style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                Path { centralLine in
                    centralLine.addLines([
                        CGPoint(x: gr.size.width / 2, y: gr.size.height / 3),
                        CGPoint(x: gr.size.width / 2, y: gr.size.height)
                    ])
                }
                .stroke(style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .onAppear {
                    print(gr.size)
                }
            }
            .frame(width: 140, height: 140, alignment: .center)
            .opacity(0.5).blur(radius: 2)
            .shadow(radius: 15)
            .padding(.all)
        }
    }
    
    public struct FusionLogo: View {
        public init(){}
        public var body: some View {
            GeometryReader { gr in
                Path { bluePath in
                    bluePath.addLines([
                        CGPoint(x: gr.size.width / 3 + 10, y: gr.size.height / 3 * 2),
                        CGPoint(x: 0, y: gr.size.height / 3 * 2),
                        CGPoint(x: 0, y: 0),
                        CGPoint(x: gr.size.width / 3 * 2, y: 0),
                        CGPoint(x: gr.size.width / 3 * 2, y: gr.size.height / 3 + 10)
                    ])
                }
                .stroke(style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                
                Path { redPath in
                    redPath.addLines([
                        CGPoint(x: gr.size.width / 3 * 2 - 10, y: gr.size.height / 3),
                        CGPoint(x: gr.size.width, y: gr.size.height / 3),
                        CGPoint(x: gr.size.width, y: gr.size.height),
                        CGPoint(x: gr.size.width / 3, y: gr.size.height),
                        CGPoint(x: gr.size.width / 3, y: gr.size.height / 3 * 2 - 10)
                    ])
                }
                .stroke(style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.red)
            }
            .frame(width: 140, height: 140, alignment: .center)
            .opacity(0.5).blur(radius: 2)
            .shadow(radius: 15)
            .padding(.all)
        }
    }
    
    public struct LinuxLogo: View {
        public init(){}
        public var body: some View {
            ZStack{
                GeometryReader { geometry in
                    Path { path in
                        let width = min(geometry.size.width, geometry.size.height)
                        let height = width * 0.75
                        let spacing = width * 0.030
                        let middle = width * 0.5
                        let topWidth = width * 0.226
                        let topHeight = height * 0.488

                        path.addLines([
                            CGPoint(x: middle, y: spacing),
                            CGPoint(x: middle - topWidth, y: topHeight - spacing),
                            CGPoint(x: middle, y: topHeight / 2 + spacing),
                            CGPoint(x: middle + topWidth, y: topHeight - spacing),
                            CGPoint(x: middle, y: spacing)
                        ])
                        
                        path.move(to: CGPoint(x: middle, y: topHeight / 2 + spacing * 3))
                        path.addLines([
                            CGPoint(x: middle - topWidth, y: topHeight + spacing),
                            CGPoint(x: spacing, y: height - spacing),
                            CGPoint(x: width - spacing, y: height - spacing),
                            CGPoint(x: middle + topWidth, y: topHeight + spacing),
                            CGPoint(x: middle, y: topHeight / 2 + spacing * 3)
                        ])
                    }.padding(.top)
                }.frame(width: 100, height: 100, alignment: .center).foregroundStyle(.shadow(.inner(radius: 5)))


                HStack{
                    Ellipse()
                        .frame(width: 10, height: 20, alignment: .center)
                    Ellipse()
                        .frame(width: 10, height: 20, alignment: .center)
                }
                .foregroundStyle(.primary.shadow(.inner(radius: 2)))
                .padding(.top)
            }
            .padding(.all)
            .background(content: {
                RoundedRectangle(cornerRadius: 15)
                    .inset(by: 10)
                    .stroke(lineWidth: 5)
            })
            .foregroundStyle(RadialGradient(colors: [.blue, .gray, .white], center: .center, startRadius: 0, endRadius: 140))
            .opacity(0.5).blur(radius: 2)
            .shadow(radius: 15)
            .padding(.all)
        }
    }
    
    /// Universal image view by it's system name
    public struct ImageView: View {
        public init(
            imageName: String! = "",
            opacity: Double = 0.5,
            blurRadius: Double = 2,
            defaultGradientColors: [Color] = [.blue, .cyan, .clear]
        ) {
            ImageName = imageName
            Opacity = opacity
            BlurRadius = blurRadius
            DefaultColors = defaultGradientColors
        }
        @State var ImageName: String!
        @State var Opacity: Double
        @State var BlurRadius: Double
        @State var DefaultColors: [Color]
        public var body: some View{
            VStack{
                Image(systemName: ImageName ?? "x.circle.fill")
                    .font(.custom("San Francisco", size: 140))
                    .fontWeight(.light)
                    .foregroundStyle(RadialGradient(colors: DefaultColors, center: .center, startRadius: 0, endRadius: 140))
                    .opacity(Opacity).blur(radius: BlurRadius)
                    .shadow(radius: 15)
            }.padding(.all)
        }
    }
    
    /// Use this to display when user password is not saved
    public struct NoPasswordView: View {
        public init(_ toggleIsPresented: Bool ,toggle: Binding<Bool>) {
            _toggle = Binding(projectedValue: toggle)
            tip = toggleIsPresented
        }
        @Binding public var toggle: Bool
        @State var tip: Bool
        public var body: some View{
            VStack{
                Text("noPassword.string").font(.largeTitle).fontWeight(.heavy).padding(.all)
                AppLogo()
                if tip {
                    Button {
                        toggle.toggle()
                    } label: {
                        Text("ok.button")
                    }.keyboardShortcut(.defaultAction).padding(.all)
                }
            }.padding(.all)
        }
    }
    
    /// Displays App Icon in App
    public struct AppLogo: View{
        public init(width: CGFloat = 180, height: CGFloat = 180){
            self.width = width
            self.height = height
        }
        @Environment(\.colorScheme) var cs
        let symbolColor: Color = Color(nsColor: NSColor(#colorLiteral(red: 0, green: 0.6093161702, blue: 0.8442775607, alpha: 1)))
        let backgroundColor: Color = Color(nsColor: NSColor(#colorLiteral(red: 0.09230715781, green: 0.1385565102, blue: 0.3585530519, alpha: 1)))
        let shadowColor = Color(nsColor: NSColor(#colorLiteral(red: 0, green: 0.5297808051, blue: 0.7691841125, alpha: 1)))
        var width: CGFloat
        var height: CGFloat
        
        private func proportion(_ x: CGFloat, _ p: CGFloat) -> CGFloat {
            return x / 100 * p
        }
        
        private func textProp(_ s: CGSize) -> CGFloat {
            let x = s.width
            let y = s.height
            if x > y {
                return x
            } else {
                return y
            }
        }
        
        public var body: some View {
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    ZStack{
                        if cs != .light {
                            RoundedRectangle(cornerRadius: 30)
                                .frame(width: proportion(width, 85), height: proportion(height, 85), alignment: .center) //85
                                .foregroundColor(backgroundColor)
                                .blur(radius: 0)
                            RoundedRectangle(cornerRadius: 30)
                                .frame(width: proportion(width, 89), height: proportion(height, 89), alignment: .center) //85
                                .foregroundStyle(.ultraThinMaterial)
                                .blur(radius: 2)
                                .shadow(color: shadowColor, radius: 15)
                        }
                        Image(systemName: "command")
                            .font(.custom("San Francisco", size: proportion(textProp(CGSize(width: width, height: height)), 78))) //78
                            .fontWeight(.light)
                            .foregroundStyle(RadialGradient(colors: [symbolColor], center: .center, startRadius: 0, endRadius: proportion(textProp(CGSize(width: width, height: height)), 78))) //78
                            .shadow(radius: 15)
                            .shadow(color: shadowColor, radius: -1)
                            .frame(width: width / 100 * 85, height: height / 100 * 85, alignment: .center)
                    }.frame(width: width, height: height, alignment: .center)
                }
            }
        }
    }
    
    /// Same as ImageView, but for symbols
    public struct SymbolView: View {
        public init(
            symbol: String!,
            opacity: Double = 0.5,
            blurRadius: Double = 2,
            defaultGradientColors: [Color] = [.blue, .gray, .white]
        ){
            self.symbol = symbol
            self.opacity = opacity
            self.blurRadius = blurRadius
            self.defaultGradientColors = defaultGradientColors
        }
        
        public var symbol: String!
        public var opacity: Double = 0.5
        public var blurRadius: Double = 2
        public var defaultGradientColors: [Color] = [.blue, .gray, .white]
        public var body: some View{
            VStack{
                Text(symbol)
                    .font(.custom("San Francisco", size: 140))
                    .fontWeight(.light)
                    .foregroundStyle(RadialGradient(colors: defaultGradientColors, center: .center, startRadius: 0, endRadius: 140))
                    .opacity(opacity).blur(radius: blurRadius)
                    .shadow(radius: 15)
            }.padding(.all)
        }
    }
    
    /// Insert a text and it will be animated as if it's being typed by someone
    public struct AnimatedTextView: View {
        /// INIT
        /// - Parameters:
        ///   - Input: Insert string here
        ///   - Font: ...set font
        ///   - FontWeight: ... and it's weight
        ///   - TimeToStopAnimation: ... time for typing to EOL...
        public init(
            Input: String,
            Font: Font? = .largeTitle,
            FontWeight: Font.Weight? = .bold,
            TimeToStopAnimation: Double? = 0.5
        ) {
            input = StringLocalizer(Input)
            font = Font
            fontWeight = FontWeight
            timeToStopAnimation = TimeToStopAnimation
        }
        @Environment(\.locale) var locale
        var font: Font?
        var fontWeight: Font.Weight?
        var timeToStopAnimation: Double?
        var input: String?
        @State private var dark = false
        @State private var frequency: Double = 0
        @State private var stop = false
        @State private var running = false
        @State private var pend = ""
        
        func displayText() {
            running = true
            let pString = input!
            let arr = Array(pString)
            var index = 0
            let count = arr.count
            var wordCount = 0
            frequency = timeToStopAnimation!/Double(count)
            if timeToStopAnimation != 0 && !ProcessInfo.processInfo.isLowPowerModeEnabled {
                Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { t in
                    if pend.last == " " {wordCount += 1}
                    if pend.last == "\n" {wordCount = 0}
                    if wordCount == 7 { pend += "\n"; wordCount += 1; index -= 1}
                    else
                    {pend += String(arr[index])}
                    if index == count - 1 {
                        stop.toggle()
                        running = false
                        t.invalidate()
                    } else {
                        index += 1
                    }
                }
            } else {
                while(true) {
                    if pend.last == " " {wordCount += 1}
                    if pend.last == "\n" {wordCount = 0}
                    if wordCount == 7 { pend += "\n"; wordCount += 1; index -= 1}
                    else
                    {pend += String(arr[index])}
                    if index == count - 1 {
                        stop.toggle()
                        running = false
                        break
                    } else {
                        index += 1
                    }
                }
            }
        }
        
        /// ... and gaze upon magestic result)
        public var body: some View {
            VStack(alignment: .center){
                HStack{
                    Text(!running ? "\(pend) " : (dark ? "\(pend) " : "\(pend)_"))
                        .font(font)
                        .fontWeight(fontWeight)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.leading)
                        .monospacedDigit()
                        .shadow(radius: 5)
                }
            }
            .padding()
            .environment(\.locale, locale)
            .onAppear {
                displayText()
                if stop {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { daaa in
                        dark.toggle()
                    }
                } else {
                    Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { tt in
                        dark.toggle()
                        if stop {
                            tt.invalidate()
                        }
                    }
                }
            }
        }
    }
    
    /// Animated Icon for Dark Mode
    public struct DarkModeIcon: View {
        public init(_ size: CGFloat = 30) {
            self.size = size
        }
        @Environment(\.colorScheme) var cs
        private var imageName = "circle.lefthalf.filled"
        var size: CGFloat
        public var body: some View {
            ZStack{
                Circle().frame(width: size - 1, height: size - 1, alignment: .center).foregroundColor(cs == .dark ? .black : .white)
                Image(systemName: imageName)
                    .font(.custom("San Francisco", size: size))
                Circle().frame(width: size / 2 - 1, height: size / 2 - 1, alignment: .center).foregroundColor(cs == .dark ? .black : .white)
                Image(systemName: imageName)
                    .font(.custom("San Francisco", size: size / 2)).rotationEffect(Angle(degrees: 180))
            }
            .shadow(radius: 5)
            .animation(SettingsMonitor.secondaryAnimation, value: size)
            .rotationEffect(Angle(degrees: cs == .light ? 0 : 180))
            .animation(SettingsMonitor.secondaryAnimation, value: cs)
        }
    }
    
    public struct DualActionMod: ViewModifier {
        public init(tapAction: @escaping (()->()), longPressAction: @escaping (()->()), frameSize: CGSize, ltActionDelay: Double = 4, padding: Bool = false) {
            self.frameSize = frameSize
            self.tapAction = tapAction
            self.longPressAction = longPressAction
            self._timeLeft = State(initialValue: ltActionDelay * 10)
            self.inititalTimeLeft = ltActionDelay * 10
            self.padding = padding
        }
        @State var w: CGFloat = 1
        @State var h: CGFloat = 1
        var padding: Bool
        @Environment(\.colorScheme) var colorScheme
        var color: Color {
            get {
                switch timeLeft {
                case 40...Double.greatestFiniteMagnitude:
                    if SettingsMonitor.isInMenuBar {
                        if colorScheme == .dark {
                            return .white
                        } else {
                            return .gray
                        }
                    } else {
                        if colorScheme == .dark {
                            return .white
                        } else {
                            return .secondary
                        }
                    }
                case 30...40:
                    return .green
                case 20...30: return .yellow
                case 10...20: return .red
                default: return .brown
                }
            }
        }
        @State private var timer: Timer?
        @State private var timeLeft: Double
        let inititalTimeLeft: Double
        @State private var isLongPressing = false
        private var tapAction: (()->())
        private var longPressAction: (()->())
        private var frameSize: CGSize
        public func body(content: Content) -> some View {
            
            ZStack{
                if !isLongPressing {
                    content
                        .transition(.scale)
                } else {
                    if padding {
                        ZStack{
                            Circle()
                                .trim(from: (timeLeft / 10 ) / (inititalTimeLeft / 10 ), to: isLongPressing ? inititalTimeLeft / 10 : 0.01)
                                .stroke(style: .init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                .foregroundColor(color)
                                .rotationEffect(Angle(degrees: 175))
                                .rotation3DEffect(Angle(degrees: 180), axis: (x: 180, y: 180, z: 0),anchor: .center)
                                .frame(width: frameSize.width, height: frameSize.height, alignment: .center)
                                .glow(color: color, anim: isLongPressing, glowIntensity: .slight)
                            Text(((timeLeft) / 10) >= 2 ? Int((timeLeft) / 10).description : ((timeLeft) / 10).description)
                                .font(.title)
                                .fontWeight(.black)
                                .glow(color: color, glowIntensity: .slight)
                        }
                        .animation(SettingsMonitor.secondaryAnimation, value: timeLeft)
                        .transition(.scale)
                        .padding(.all)
                    } else {
                        ZStack{
                            Circle()
                                .trim(from: (timeLeft / 10 ) / (inititalTimeLeft / 10 ), to: isLongPressing ? inititalTimeLeft / 10 : 0.01)
                                .stroke(style: .init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                .foregroundColor(color)
                                .rotationEffect(Angle(degrees: 175))
                                .rotation3DEffect(Angle(degrees: 180), axis: (x: 180, y: 180, z: 0),anchor: .center)
                                .frame(width: frameSize.width, height: frameSize.height, alignment: .center)
                                .glow(color: color, anim: isLongPressing, glowIntensity: .slight)
                            Text(((timeLeft) / 10) >= 2 ? Int((timeLeft) / 10).description : ((timeLeft) / 10).description)
                                .font(.title)
                                .fontWeight(.black)
                                .glow(color: color, glowIntensity: .slight)
                        }
                        .animation(SettingsMonitor.secondaryAnimation, value: timeLeft)
                        .transition(.scale)
                    }
                }
            }
            .transition(.scale)
            .animation(SettingsMonitor.secondaryAnimation, value: isLongPressing)
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        tapAction()
                    }
            )
            .onLongPressGesture(minimumDuration: inititalTimeLeft / 10, maximumDistance: 200) {
                longPressAction()
            } onPressingChanged: { h in
                isLongPressing = h
                switch isLongPressing {
                case true:
                    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { t in
                        timeLeft -= 1
                    })
                case false:
                    timer?.invalidate()
                    timer = nil
                    timeLeft = inititalTimeLeft
                }
            }
        }
    }
    
    public struct MultiProgressBar: View {
        @Environment(\.colorScheme) var cs
        var total: (label: String, value: Double)
        var values: [(label: String, value: Double, color: Color)] = []
        var intValues: [(label: String, value: Int, color: Color)] = []
        var widthFrame: Double
        var showDots: Bool = true
        var textColor: Color = !SettingsMonitor.isInMenuBar ? .secondary : NSApplication.shared.effectiveAppearance.name == .aqua ? .black : .white
        var geometry: CGSize
        @State var rectHeight: CGFloat = .pi * 1.5
        @State var dummyBool = false
        var fixTo100: Bool = false
        var dontShowLabels = false
        var popOnHover = false
        @State var pops: [(popped: Bool , width: CGFloat)] = []
        private func summaryload(_ s: [(label: String, value: Double, color: Color)]) -> Double {
            var sum: Double = 0
            for each in s {
                sum += each.value
            }
            return sum
        }
        private func summaryIntload(_ s: [(label: String, value: Int, color: Color)]) -> Int {
            var sum: Int = 0
            for each in s {
                sum += each.value
            }
            return sum
        }
        
        private func calculateWidth(fraction: Double, total: Double, width: Double) -> Double {
            return (width / total * (fraction))
        }
        
        private func calculateIntWidth(fraction: Int, total: Double, width: Double) -> Double {
            return width / total * Double(fraction)
        }
        
        public var body: some View {
            VStack{
                VStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: geometry.width, height: rectHeight, alignment: .center)
                            .foregroundStyle(.separator)
                            .shadow(radius: 1)
                        HStack(spacing: 0){
                            if !values.isEmpty {
                                ForEach(0..<values.count, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 5)
                                        .frame(
                                            width: calculateWidth(fraction: values[index].value, total: fixTo100 ? 100 : total.value, width: geometry.width),
                                            height: pops.isEmpty ? rectHeight : pops[index].width, alignment: .center)
                                        .foregroundColor(values[index].color)
                                        .animation(SettingsMonitor.secondaryAnimation, value: values[index].value)
                                        .animation(SettingsMonitor.secondaryAnimation, value: pops.isEmpty ? rectHeight : pops[index].width)
                                        .shadow(radius: 5)
                                        .popover(isPresented: pops.isEmpty ? $dummyBool : $pops[index].popped, content: {
                                            HStack{
                                                Circle()
                                                    .frame(width: 10, height: 10, alignment: .center)
                                                    .foregroundColor(values[index].color)
                                                    .blur(radius: 1)
                                                    .shadow(radius: 2)
                                                Text(StringLocalizer(values[index].label) + "\n" + values[index].value.round(to: 1).description + " " + StringLocalizer("mib.string"))
                                                    .monospacedDigit()
                                                    .font(.footnote)
                                                    .foregroundColor(SettingsMonitor.textColor(cs))
                                                    .shadow(radius: 0)
                                            }.padding(.all)
                                        })
                                        .overlay {
                                            Rectangle().frame(width: calculateWidth(fraction: values[index].value, total: fixTo100 ? 100 : total.value, width: geometry.width), height: rectHeight * 2, alignment: .center).foregroundColor(.clear)
                                                .onHover { b in
                                                    if popOnHover {
                                                        pops[index].popped = b
                                                    }
                                                }
                                                .onHover { wider in
                                                    if popOnHover {
                                                        pops[index].width = wider ? rectHeight * 2 : rectHeight
                                                    }
                                                }
                                        }
                                }
                                RoundedRectangle(cornerRadius: 0.01)
                                .foregroundColor(.clear)
                                .onHover { b in
                                    for each in 0..<pops.count {
                                        pops[each].popped = false
                                        pops[each].width = rectHeight
                                    }
                                }
                            } else {
                                ForEach(0..<intValues.count, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 5)
                                        .frame(
                                            width: calculateIntWidth(fraction: intValues[index].value, total: fixTo100 ? 100 : total.value, width: geometry.width),
                                            height: pops.isEmpty ? rectHeight : pops[index].width, alignment: .center)
                                        .foregroundColor(intValues[index].color)
                                        .animation(SettingsMonitor.secondaryAnimation, value: intValues[index].value)
                                        .animation(SettingsMonitor.secondaryAnimation, value: pops.isEmpty ? rectHeight : pops[index].width)
                                        .shadow(radius: 5)
                                        .popover(isPresented: pops.isEmpty ? $dummyBool : $pops[index].popped, content: {
                                            HStack{
                                                Circle()
                                                    .frame(width: 10, height: 10, alignment: .center)
                                                    .foregroundColor(intValues[index].color)
                                                    .blur(radius: 1)
                                                    .shadow(radius: 2)
                                                Text(StringLocalizer(intValues[index].label) + "\n" + intValues[index].value.description + " " + StringLocalizer("mib.string"))
                                                    .monospacedDigit()
                                                    .font(.footnote)
                                                    .foregroundColor(SettingsMonitor.textColor(cs))
                                                    .shadow(radius: 0)
                                            }
                                        })
                                        .overlay {
                                            Rectangle().frame(width: calculateIntWidth(fraction: intValues[index].value, total: fixTo100 ? 100 : total.value, width: geometry.width), height: rectHeight * 2, alignment: .center).foregroundColor(.clear)
                                                .onHover { b in
                                                    if popOnHover {
                                                        pops[index].popped = b
                                                    }
                                                }
                                                .onHover { wider in
                                                    if popOnHover {
                                                        pops[index].width = wider ? rectHeight * 2 : rectHeight
                                                    }
                                                }
                                        }
                                }
                                RoundedRectangle(cornerRadius: 0.01)
                                .foregroundColor(.clear)
                                .onHover { b in
                                    for each in 0..<pops.count {
                                        pops[each].popped = false
                                        pops[each].width = rectHeight
                                    }
                                }
                            }
                        }
                    }
                }
                if !dontShowLabels {
                    VStack{
                        if !showDots {
                            HStack{
                                Text(StringLocalizer(total.label) + ": " + Int(total.value).description + "%")
                                    .font(.footnote)
                                    .foregroundColor(textColor)
                                    .monospacedDigit()
                                HStack{
                                    Divider()
                                }.frame(width: 10, height: 10, alignment: .center)
                                if !values.isEmpty {
                                    ForEach(0..<values.count, id: \.self) {index in
                                        HStack{
                                            Text(StringLocalizer(values[index].label) + ": " + Int(values[index].value).description + "%")
                                                .font(.footnote)
                                                .foregroundColor(textColor)
                                                .monospacedDigit()
                                        }
                                        if index != values.count - 1 {
                                            HStack{
                                                Divider()
                                            }.frame(width: 10, height: 10, alignment: .center)
                                        }
                                    }
                                } else {
                                    ForEach(0..<intValues.count, id: \.self) {index in
                                        HStack{
                                            Text(StringLocalizer(intValues[index].label) + ": " + Int(intValues[index].value).description + "%")
                                                .font(.footnote)
                                                .foregroundColor(textColor)
                                                .monospacedDigit()
                                        }
                                        if index != values.count - 1 {
                                            HStack{
                                                Divider()
                                            }.frame(width: 10, height: 10, alignment: .center)
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .onAppear(perform: {
                pops = Array(repeating: (false, rectHeight), count: values.count)
            })
            .frame(width: geometry.width)
        }
    }
    
    public struct OverlayButton: ViewModifier {
        @State var popover: AnyView = AnyView(EmptyView())
        @Binding var popoverIsPresented: Bool
        @State var action: () -> ()
        @State var enabledGlyph: String
        @State var disabledGlyph: String
        @State var enabledColor: Color
        @State var disabledColor: Color
        @State var hoveredColor: Color
        @Binding var selfHovered: Bool
        @Binding var backwardHovered: Bool
        @Binding var enabled: Bool
        @State var showPopover: Bool
        public func body(content: Content) -> some View {
            return content.overlay(alignment: .topTrailing) {
                ZStack{
                    HStack(spacing: 0){
                        ZStack{
                            Image(systemName: enabled ? enabledGlyph : disabledGlyph)
                                .symbolRenderingMode(.palette)
                                .font(.custom("San Francisco", size: 20))
                                .foregroundStyle(.white, (enabled ? enabledColor : disabledColor))
                                .shadow(radius: 2)
                                .onHover(perform: { Bool in
                                    selfHovered = Bool
                                })
                                .onTapGesture(perform: {
                                    action()
                                })
                        }
                        .padding(.all)
                    }
                    .onHover(perform: { Bool in
                        backwardHovered = Bool
                    })
                    .background {
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.ultraThickMaterial)
                                .opacity(0.5)
                                .animation(SettingsMonitor.secondaryAnimation, value: selfHovered)
                                .padding(.all)
                        }
                        .glow(color: (selfHovered) ? hoveredColor : .clear, anim: selfHovered)
                    }
                }
                .popover(isPresented: $popoverIsPresented) {
                    popover
                }
            }
        }
    }
}

public extension View {
    func overlayButton(
    popover: AnyView = AnyView(EmptyView()),
    popoverIsPresented: Binding<Bool>,
    action: @escaping () -> (),
    enabledGlyph: String,
    disabledGlyph: String,
    enabledColor: Color,
    disabledColor: Color,
    hoveredColor: Color,
    selfHovered: Binding<Bool>,
    backwardHovered: Binding<Bool>,
    enabled: Binding<Bool>,
    showPopover: Bool
    ) -> some View {
        self.modifier(CustomViews.OverlayButton(popover: popover, popoverIsPresented: popoverIsPresented ,action: action, enabledGlyph: enabledGlyph, disabledGlyph: disabledGlyph, enabledColor: enabledColor, disabledColor: disabledColor, hoveredColor: hoveredColor, selfHovered: selfHovered, backwardHovered: backwardHovered, enabled: enabled, showPopover: showPopover))
    }
}

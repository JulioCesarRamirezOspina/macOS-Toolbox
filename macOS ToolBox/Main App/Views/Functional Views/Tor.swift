//
//  Tor.swift
//  MultiTool
//
//  Created by Олег Сазонов on 06.06.2022.
//

import SwiftUI
import Combine

struct TorView: View {
    //MARK: - State Vars
    @Environment(\.locale) var locale
    @Environment(\.colorScheme) private var onLaunchColorScheme
    @State private var isConnected = false
    @State private var isFirstRun = true
    @State private var statusString: String?
    @State private var buttonText: String?
    @State private var showPasswordSettings = false
    @State private var pipe: Pipe?
    @State private var q = DispatchQueue.main
    @State private var isRun = false
    @State private var pid = ""
    @State private var connectivity = TorNetworking.Connectivity()
    @State private var tor: TorNetworking.Tor?
    @State private var winFrame: CGSize = .zero
    @State private var isDisabled = false
    @State private var lines = [String()]
    @State private var offsetLength = 0
    @State private var offsetRead = false
    @State private var connectedState = 0
    @State private var spinCircle = false
    //MARK: - Funcs
    public func stop() {
        isDisabled = true
        spinCircle = false
        offsetRead = false
        statusString = StringLocalizer("disconnected.string")
        buttonText = StringLocalizer("connect.string")
        isRun = false
        connectivity.disconnect()
        tor = nil
        lines.removeAll()
        NSLog("disconnected")
        isConnected = connectivity.status()
        delay(after: 3) {
            isDisabled = false
        }
        connectedState = 0
    }
    func start() {
        lines.removeAll()
        isDisabled = true
        isRun = true
        tor = TorNetworking.Tor()
        connectivity.connect()
        let torPipe = tor!.pipe
        tor!.run()
        delay(after: 5) {
            isDisabled = false
        }
        let handler = torPipe.fileHandleForReading
        handler.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8) {
                let fucko = line
                let prepend = line.replacingOccurrences(of: "[notice]", with: "\n")
                let append = prepend.split(separator: "\n")
                if fucko.contains("%"){
                    let percentageValueUltra = fucko.replacingCharacters(in: (fucko.firstIndex(of: "%") ?? fucko.startIndex)...(fucko.firstIndex(of: "\n") ?? fucko.endIndex), with: "")
                    let percentageValueSub = percentageValueUltra.replacingCharacters(in: percentageValueUltra.startIndex..<(percentageValueUltra.index(percentageValueUltra.firstIndex(of: "%") ?? percentageValueUltra.endIndex, offsetBy: -3)), with: "")
                    let percentageValue = percentageValueSub.replacingOccurrences(of: " ", with: "")
                    connectedState = Int(percentageValue) ?? .zero
                }
                if line.first != nil {
                    lines.append(String(append[1]).dropFirst() + "")
                }
                if line.contains("Bootstrapped 100% (done): Done") {
                    statusString = StringLocalizer("connected.string")
                    buttonText = StringLocalizer("disconnect.string")
                    isDisabled = false
                } else {
                    statusString = StringLocalizer("pending.string")
                    buttonText = String(connectedState) + "%"
                    isDisabled = true
                }
            } else {
                lines.removeAll()
            }
        }
        NSLog("connected")
        isConnected = connectivity.status()
    }
    
    private var startStopButton: some View {
        VStack{
            Button {
                if isConnected {
                    stop()
                } else {
                    start()
                }
            } label: {
                Text(buttonText ?? StringLocalizer("pending.string"))
            }
            .keyboardShortcut(.defaultAction).disabled(isDisabled)
            .buttonStyle(Stylers.ColoredButtonStyle(glyph: "point.3.filled.connected.trianglepath.dotted", disabled: isDisabled, enabled: isConnected, color: .blue, backgroundIsNotFill: true))
        }.padding(.all)
    }
    
    //MARK: - Main View
    private var mainView: some View {
        VStack{
            Image(systemName: !(connectedState == 100) ? "network" : "network.badge.shield.half.filled")
                .font(.custom("San Francisco", size: 140))
                .foregroundStyle(RadialGradient(
                    colors: [.green, .blue],
                    center: .center,
                    startRadius: CGFloat(0),
                    endRadius: CGFloat(connectedState * 2)))
                .shadow(color: .black, radius: 7, x: 0, y: 5)
                .padding(.all)
            
            if isConnected && lines != [String()] {
                ScrollViewReader { scrollView in
                    ScrollView(.vertical) {
                        VStack(alignment: .leading){
                            Spacer()
                            ForEach(lines, id: \.self) { l in
                                if l != "" {
                                    Text(l).lineLimit(nil).id(l).padding(.bottom)
                                }
                            }
                        }
                        .frame(minHeight: winFrame.height, alignment: .center)
                        .onChange(of: lines.last, perform: { l in
                            scrollView.scrollTo(l)
                        })
                        .animation(.easeInOut(duration: 0.5), value: lines)
                        .padding(.all)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 15).foregroundStyle(.ultraThinMaterial).shadow(radius: 5)
                    }
                }
            } else if isConnected && lines == [String()] {
                ZStack{
                    RoundedRectangle(cornerRadius: 15).foregroundStyle(.ultraThinMaterial).shadow(radius: 5)
                    CustomViews.AnimatedTextView(Input: "alreadyConnected.string", Font: .title, FontWeight: .bold, TimeToStopAnimation: SettingsMonitor.secAnimDur)
                }.padding(.all)
            }
            Spacer()
            startStopButton
        }
    }
    
    
    func generateView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.winFrame = geometry.size }
        return VStack{
            mainView.onAppear {
                isConnected = connectivity.status()
                if !isConnected {
                    statusString = StringLocalizer("disconnected.string")
                    buttonText = StringLocalizer("connect.string")
                } else {
                    statusString = StringLocalizer("connected.string")
                    buttonText = StringLocalizer("disconnect.string")
                }
            }
        }
        .environment(\.locale, locale)
        .frame(width: geometry.size.width)
    }
    //MARK: - APP Body View
    var body: some View {
        GroupBox {
            VStack {
                GeometryReader { (g) in
                    generateView(g)
                }
            }
        } label: {
            CustomViews.AnimatedTextView(Input: "torView.string", TimeToStopAnimation: SettingsMonitor.secAnimDur)
        }
        .groupBoxStyle(Stylers.CustomGBStyle())
        .animation(SettingsMonitor.secondaryAnimation, value: isRun)
        .animation(SettingsMonitor.secondaryAnimation, value: isConnected)
        .animation(SettingsMonitor.secondaryAnimation, value: connectedState)
        .animation(SettingsMonitor.secondaryAnimation, value: isDisabled)
    }
}

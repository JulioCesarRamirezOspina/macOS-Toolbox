//
//  Docker.swift
//  MultiTool
//
//  Created by Олег Сазонов on 04.07.2022.
//

import Foundation
import SwiftUI
import xCore

struct DockManagerView: View {
    @State private var singleApp: Bool = DockManager().SingleAppMode
    @State private var animSpeed: Int = DockManager().AnimationSpeed
    @State private var animDelay: Int = DockManager().AnimationDelay
    @State private var autohide: Bool = DockManager().Autohide
    @State private var animType = DockManager().AnimationType
    @State private var DockOrientation = DockManager().DockOrientation
    @State private var magnification = DockManager().Magnification
    @State private var DA = DockManager().DiskArbitration
    @State private var hiddenAppsMode = DockManager().HiddenAppsMode
    @State private var showPopover1 = false
    @State private var showPopover2 = false
    @State private var showPopover3 = false
    @State private var showPopover4 = false
    @State private var animSettings = false
    
    private func AnimationType() -> some View {
        GeometryReader { g in
            HStack{
                Button {
                    animType = .suck
                } label: {
                    Text("suckAnim.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "chevron.down", enabled: animType == .suck, width: g.size.width / 3 - 10, color: .green))
                Button {
                    animType = .genie
                } label: {
                    Text("genieAnim.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "water.waves.and.arrow.down", enabled: animType == .genie, width: g.size.width / 3 - 10 ,color: .green))
                Button {
                    animType = .scale
                } label: {
                    Text("scaleAnim.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "arrow.down.right.and.arrow.up.left", enabled: animType == .scale, width: g.size.width / 3 - 10, color: .green))
            }
            
        }.frame(height: 100, alignment: .center).padding(.all)
    }
    
    private func AnimationSpeed() -> some View {
        GeometryReader { g in
            HStack{
                Button {
                    animSpeed = 0
                } label: {
                    Text("off.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "stop.circle.fill", enabled: animSpeed == 0, width: g.size.width / 3 - 10, color: .blue, render: .hierarchical))
                Button {
                    animSpeed = 50
                } label: {
                    Text("norm.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "play.circle.fill", enabled: animSpeed == 50, width: g.size.width / 3 - 10, color: .blue, render: .hierarchical))
                Button {
                    animSpeed = 100
                } label: {
                    Text("slow.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "infinity.circle.fill", enabled: animSpeed == 100, width: g.size.width / 3 - 10, color: .blue, render: .hierarchical))
            }
        }.frame(height: 100, alignment: .center).padding(.all)
    }
    
    private func AnimationDelay() -> some View {
        GeometryReader { g in
            HStack{
                Button {
                    animDelay = 0
                } label: {
                    Text("off.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyphs: ["figure.wave.circle", "circle.slash"], enabled: animDelay == 0, width: g.size.width / 3 - 10, color: .blue))
                Button {
                    animDelay = 50
                } label: {
                    Text("norm.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyphs: ["figure.wave.circle", "circle.dotted"], enabled: animDelay == 50, width: g.size.width / 3 - 10, color: .blue))
                Button {
                    animDelay = 100
                } label: {
                    Text("slow.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyphs: ["figure.walk.circle", "circle.dashed"], enabled: animDelay == 100, width: g.size.width / 3 - 10, color: .blue))
            }
        }.frame(height: 100, alignment: .center).padding(.all)    }
    
    private func AnimSettings() -> some View {
        VStack{
            ScrollView(.vertical, showsIndicators: true) {
                Group {
                    GroupBox {
                        AnimationDelay()
                    } label: {
                        Text("animDelay.string").padding(.all)
                    }
//                    Text("\n").font(.largeTitle).fontWeight(.bold)
                    GroupBox {
                        AnimationSpeed()
                    } label: {
                        Text("animSpeed.string").padding(.all)
                    }
//                    Text("\n").font(.largeTitle).fontWeight(.bold)
                    GroupBox {
                        AnimationType()
                    } label: {
                        Text("animType.string").padding(.all)
                    }
                }.groupBoxStyle(Stylers.CustomGBStyle())
            }
        }
    }
    
    private func AnimSettingsButton() -> some View {
        GeometryReader { g in
            Button {
                animSettings.toggle()
            } label: {
                Text(!autohide ? "enableAutohide.reason" : animSettings ? "goBack.button" : "anim.settings")
            }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "livephoto.play", disabled: !autohide, enabled: animSettings, width: g.size.width - 10, color: animSettings ? .cyan : .blue))
                .disabled(!autohide)
        }.frame(height: 100).padding(.all)
    }
    
    private func MainButtons() -> some View {
        GeometryReader { g in
            HStack{
                Button {
                    singleApp.toggle()
                } label: {
                    Text("singleAppMode.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "1.square", enabled: singleApp, width: g.size.width / 5 - 10, color: .blue))
                Button {
                    autohide.toggle()
                } label: {
                    Text("dockAutohide.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "dock.arrow.down.rectangle", enabled: autohide, width: g.size.width / 5 - 10, color: .green))
                
                Button {
                    magnification.toggle()
                } label: {
                    Text("dockMagnification.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "rectangle.expand.vertical", enabled: magnification, width: g.size.width / 5 - 10, color: .purple))
                
                Button {
                    hiddenAppsMode.toggle()
                } label: {
                    Text("hiddenGrayedOut.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "app.dashed", enabled: hiddenAppsMode, width: g.size.width / 5 - 10, color: Color(nsColor: NSColor(#colorLiteral(red: 0.3179988265, green: 0.3179988265, blue: 0.3179988265, alpha: 1)))))
                
                Button {
                    DockManager().dockDefaults()
                    //                    DockManager().restartDock()
                    animSpeed = DockManager().AnimationSpeed
                    animDelay = DockManager().AnimationDelay
                    autohide = DockManager().Autohide
                    animType = DockManager().AnimationType
                    DockOrientation = DockManager().DockOrientation
                    singleApp = DockManager().SingleAppMode
                    magnification = DockManager().Magnification
                    hiddenAppsMode = DockManager().HiddenAppsMode
                } label: {
                    Text("defaults.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "menubar.dock.rectangle.badge.record", width: g.size.width / 5 - 10, color: .red))
            }
        }.frame(height: 100).padding(.all)
    }
    
    private func OrientationButtons() -> some View {
        GeometryReader { g in
            HStack {
                Button {
                    DockOrientation = .left
                } label: {
                    Text("left.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "arrow.left.to.line",enabled: DockOrientation == .left ,width: g.size.width / 3 - 10 ,color: .blue))
                Button {
                    DockOrientation = .bottom
                } label: {
                    Text("bottom.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "arrow.down.to.line",enabled: DockOrientation == .bottom ,width: g.size.width / 3 - 10 ,color: .blue))
                Button {
                    DockOrientation = .right
                } label: {
                    Text("right.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "arrow.right.to.line",enabled: DockOrientation == .right ,width: g.size.width / 3 - 10 ,color: .blue))
            }
        }.frame(height: 100).padding(.all)
    }
    
    private func AdditionalButtons() -> some View {
        GeometryReader { g in
            HStack {
                Button {
                    DockManager().addSpacer(.wide)
                    DockManager().restartDock()
                } label: {
                    Text(singleApp ? "disableSA.reason" : "wideSpacer.string")
                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right", disabled: singleApp, width: g.size.width / 3 - 10, color: .green))
                    .disabled(singleApp)
                Button {
                    if SettingsMonitor.passwordSaved {
                        DA.toggle()
                        showPopover4.toggle()
                    } else {
                        showPopover3.toggle()
                    }
                } label: {
                    Text("diskNotification.string")
                }
                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "externaldrive.badge.checkmark", disabled: !SettingsMonitor.passwordSaved, enabled: DA, width: g.size.width / 3 - 10, color: .blue))
                .disabled(!SettingsMonitor.passwordSaved)
                .onTapGesture {
                    if !SettingsMonitor.passwordSaved {
                        showPopover3.toggle()
                    }
                }
                .sheet(isPresented: $showPopover3) {
                    CustomViews.NoPasswordView(true, toggle: $showPopover3)
                }
                .sheet(isPresented: $showPopover4) {
                    VStack{
                        Text("reboot.reason").font(.largeTitle).fontWeight(.heavy).padding(.all)
                        CustomViews.AppLogo().padding(.all)
                        HStack{
                            Button {
                                showPopover4.toggle()
                            } label: {
                                Text("ok.button")
                            }.padding(.all).keyboardShortcut(.defaultAction)
                            Spacer()
                            Button {
                                Shell.Parcer.sudo("/sbin/reboot", [""], password: SettingsMonitor.password)
                            } label: {
                                Text("rebootNow.string")
                            }.disabled(!SettingsMonitor.passwordSaved)
                        }.padding(.all)
                    }
                }
                
                Button {
                    DockManager().addSpacer(.narrow)
                    DockManager().restartDock()
                } label: {
                    Text(singleApp ? "disableSA.reason" : "narrowSpacer.string")
                }.buttonStyle(Stylers.ColoredButtonStyle(glyph: "arrowtriangle.right.and.line.vertical.and.arrowtriangle.left", disabled: singleApp, width: g.size.width / 3 - 10, color: .green))
                    .disabled(singleApp)
            }
        }.frame(height: 100).padding(.all)
    }
    
    private func BackgroundView() -> some View {
        VStack(alignment: DockOrientation == .bottom ? .center : DockOrientation == .left ? .leading : .trailing){
//            Spacer()
            HStack {
                if DockOrientation == .right {
                    Spacer()
                }
                ZStack{
                    CustomViews.ImageView(imageName: "dock.rectangle", opacity: 0.8, blurRadius: 1, defaultGradientColors: [.blue, .gray])
                        .rotationEffect(Angle(degrees: DockOrientation == .bottom ? 0 : DockOrientation == .left ? 90 : -90))
                        .padding(.all)
                    if autohide {
                        if animType == .suck{
                            CustomViews.ImageView(imageName: "chevron.down", opacity: 0.8, blurRadius: 1, defaultGradientColors: [.blue, .gray])
                                .rotationEffect(Angle(degrees: DockOrientation == .bottom ? 0 : DockOrientation == .left ? 90 : -90))
                                .padding(.all)
                                .scaleEffect(0.3)
                        } else if animType == .genie{
                            CustomViews.ImageView(imageName: "water.waves.and.arrow.down", opacity: 0.8, blurRadius: 1, defaultGradientColors: [.blue, .gray])
                                .rotationEffect(Angle(degrees: DockOrientation == .bottom ? 0 : DockOrientation == .left ? 90 : -90))
                                .padding(.all)
                                .scaleEffect(0.3)
                        } else if animType == .scale{
                            CustomViews.ImageView(imageName: "arrow.down.right.and.arrow.up.left", opacity: 0.8, blurRadius: 1, defaultGradientColors: [.blue, .gray])
                                .rotationEffect(Angle(degrees: DockOrientation == .bottom ? 0 : DockOrientation == .left ? 90 : -90))
                                .padding(.all)
                                .scaleEffect(0.3)
                        }
                    }
                }
                if DockOrientation == .left{
                    Spacer()
                }
            }
        }
    }
    
    var body: some View {
        GroupBox {
            ScrollView(.vertical, showsIndicators: true) {
                VStack{
                    if !animSettings {
                        Group {
                            GroupBox {
                                MainButtons()
                            } label: {
                                Text("dockKey.string").padding(.all)
                            }
                            GroupBox{
                                OrientationButtons()
                            } label: {
                                Text("dockOrientation.string").padding(.all)
                            }
                            GroupBox {
                                AdditionalButtons()
                            } label: {
                                Text("addons.string").padding(.all)
                            }
                        }.groupBoxStyle(Stylers.CustomGBStyle())
                    } else {
                        AnimSettings()
                    }
                    GroupBox {
                        AnimSettingsButton()
                    } label: {
                        Text("anim.settings").padding(.all)
                    }.groupBoxStyle(Stylers.CustomGBStyle())
                    Spacer()
                }
            }
        } label: {
            CustomViews.AnimatedTextView(Input: "Dock", TimeToStopAnimation: SettingsMonitor.secAnimDur)
        }
        .background(content: {
            BackgroundView()
        })
        .groupBoxStyle(Stylers.CustomGBStyle())
        .onChange(of: animDelay, perform: { newValue in
            DockManager().AnimationDelay = newValue
            DockManager().restartDock()
        })
        .onChange(of: animSpeed, perform: { newValue in
            DockManager().AnimationSpeed = newValue
            DockManager().restartDock()
        })
        .onChange(of: animType, perform: { newValue in
            DockManager().AnimationType = newValue
            DockManager().restartDock()
        })
        .onChange(of: DockOrientation, perform: { newValue in
            DockManager().DockOrientation = newValue
            DockManager().restartDock()
        })
        .onChange(of: autohide, perform: { newValue in
            DockManager().AnimationDelay = 0
            DockManager().AnimationSpeed = 0
            DockManager().Autohide = newValue
            DockManager().restartDock()
        })
        .onChange(of: singleApp, perform: { newValue in
            DockManager().SingleAppMode = newValue
            DockManager().restartDock()
        })
        .onChange(of: magnification, perform: { newValue in
            DockManager().Magnification = newValue
            DockManager().restartDock()
        })
        .onChange(of: DA, perform: { newValue in
            DockManager().DiskArbitration = newValue
        })
        .onChange(of: hiddenAppsMode, perform: { newValue in
            DockManager().HiddenAppsMode = newValue
            DockManager().restartDock()
        })
        .onAppear {
            animSpeed = DockManager().AnimationSpeed
            animDelay = DockManager().AnimationDelay
            autohide = DockManager().Autohide
            animType = DockManager().AnimationType
            DockOrientation = DockManager().DockOrientation
            singleApp = DockManager().SingleAppMode
            magnification = DockManager().Magnification
            hiddenAppsMode = DockManager().HiddenAppsMode
            DA = DockManager().DiskArbitration
        }
        .animation(SettingsMonitor.secondaryAnimation, value: DockOrientation)
        .animation(SettingsMonitor.secondaryAnimation, value: animSettings)
    }
}

struct previewDockManager: PreviewProvider {
    static var previews: some View {
        DockManagerView().frame(width: 700, height: 500, alignment: .center)
    }
}

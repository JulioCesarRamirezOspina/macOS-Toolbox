//
//  Packer.swift
//  MultiTool
//
//  Created by Олег Сазонов on 19.06.2022.
//

import Foundation
import SwiftUI
import xCore

struct PackerView: View {
    @State private var filename =  StringLocalizer("default.text")
    @State private var pathToFile = ""
    @State private var pathOfFInstall = StringLocalizer("future.text")
    @State private var savePath = StringLocalizer("save.text")
    @State private var showFileChooser = false
    @State private var appPickerDisabled = true
    @State private var savePickerDisabled = true
    @State private var isActive = false
    @State private var runDisabled = true
    @State private var pathPickerDisabled = false
    @State private var defaultPathButtDisabled = false
    @State private var password = SettingsMonitor.password
    @State private var devID = SettingsMonitor.devID
    @State private var signP = SettingsMonitor.passwordSaved && SettingsMonitor.devID != "" ? true : false
    @State private var dummy = false
    private var FutureInstallDirPicker: some View {
        return Button(pathOfFInstall) {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.directoryURL = URL(fileURLWithPath: "/Applications")
            if panel.runModal() == .OK {
                self.pathOfFInstall = panel.url?.path ?? "<none>"
            }
            self.defaultPathButtDisabled = false
            appPickerDisabled = false
        }.padding().fixedSize(horizontal: true, vertical: false)
    }
    
    private var DefaultPathPicker: some View {
        return Button("default.button") {
            self.pathOfFInstall = "/Applications"
            appPickerDisabled = false
            self.defaultPathButtDisabled = true
        }.disabled(defaultPathButtDisabled).padding().fixedSize(horizontal: true, vertical: false)
            .keyboardShortcut(.defaultAction)
    }
    
    private var AppToPackPicker: some View {
        return Button(filename) {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.allowedContentTypes = [.application, .applicationBundle]
            panel.directoryURL = URL(fileURLWithPath: "/Applications")
            if panel.runModal() == .OK {
                self.filename = panel.url?.lastPathComponent ?? "<none>"
                self.pathToFile = panel.url?.path ?? "<none>"
            }
            savePickerDisabled = false
        }.disabled(appPickerDisabled).padding()
            .keyboardShortcut(!(filename != StringLocalizer("default.text")) ? .defaultAction : .cancelAction)
    }
    
    private var SavePackDirPicker: some View {
        return Button {
            let panel = NSOpenPanel()
            let homeFolder = FileManager.default.homeDirectoryForCurrentUser
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.directoryURL = homeFolder
            if panel.runModal() == .OK {
                self.savePath = panel.url?.path ?? "<none>"
            }
            runDisabled = false
        } label: {
            Text(savePath)
        }.disabled(savePickerDisabled).padding()
            .keyboardShortcut(!(savePath != StringLocalizer("save.text")) ? .defaultAction : .cancelAction)
    }
    
    private var StartPacking: some View {
        return Button(action: {
            Packer.run(pathOfFInstall, pathToFile, savePath, filename, password)
            if signP && devID != "" {
                Packer.SignPackage(savePath, filename, devID: devID, password)
            }
            Packer.openFileLocation(savePath)
            self.isActive = true
            filename =  StringLocalizer("default.text")
            pathToFile = ""
            pathOfFInstall = StringLocalizer("future.text")
            savePath = StringLocalizer("save.text")
            showFileChooser = false
            appPickerDisabled = true
            savePickerDisabled = true
            runDisabled = true
            pathPickerDisabled = false
            defaultPathButtDisabled = false
        }) {
            Text("start.button")
        }
        .disabled(runDisabled).padding()
        .keyboardShortcut(.defaultAction)
    }
    
    private func Texts(_ textToShow: String) -> some View {
        return Text(textToShow).fontWeight(.light).padding()
    }
    
    private var startOver: some View {
        Button {
            filename =  StringLocalizer("default.text")
            pathToFile = ""
            pathOfFInstall = StringLocalizer("future.text")
            savePath = StringLocalizer("save.text")
            showFileChooser = false
            appPickerDisabled = true
            savePickerDisabled = true
            isActive = false
            runDisabled = true
            pathPickerDisabled = false
            defaultPathButtDisabled = false
        } label: {
            Text(StringLocalizer("startover.string"))
        }.disabled(appPickerDisabled)
            .keyboardShortcut(.delete)
    }
    
    var body: some View {
        if SettingsMonitor.passwordSaved {
            GroupBox {
                Spacer()
                GeometryReader { g in
                    VStack {
                        Spacer()
                        HStack{
                            FutureInstallDirPicker
                                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "square.on.square.dashed",
                                                                        enabled: true,
                                                                        alwaysShowTitle: false,
                                                                        width: g.size.width / 2 - 20,
                                                                        color: .cyan,
                                                                        hideBackground: false,
                                                                        backgroundIsNotFill: false,
                                                                        blurBackground: true,
                                                                        render: .palette))
                            Spacer()
                            DefaultPathPicker
                                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "square",
                                                                        disabled: defaultPathButtDisabled,
                                                                        enabled: !defaultPathButtDisabled,
                                                                        alwaysShowTitle: false,
                                                                        width: g.size.width / 2 - 20,
                                                                        color: .cyan,
                                                                        hideBackground: false,
                                                                        backgroundIsNotFill: false,
                                                                        blurBackground: true,
                                                                        render: .palette))
                        }
                        Divider()
                        AppToPackPicker
                            .buttonStyle(Stylers.ColoredButtonStyle(glyph: "square.grid.3x3.square",
                                                                    disabled: appPickerDisabled,
                                                                    enabled: !appPickerDisabled,
                                                                    alwaysShowTitle: false,
                                                                    color: .blue,
                                                                    hideBackground: false,
                                                                    backgroundIsNotFill: false,
                                                                    blurBackground: true,
                                                                    render: .palette))
                        SavePackDirPicker
                            .buttonStyle(Stylers.ColoredButtonStyle(glyph: "questionmark.square",
                                                                    disabled: savePickerDisabled,
                                                                    enabled: !savePickerDisabled,
                                                                    alwaysShowTitle: false,
                                                                    color: .blue,
                                                                    hideBackground: false,
                                                                    backgroundIsNotFill: false,
                                                                    blurBackground: true,
                                                                    render: .palette))
                        Divider()
                        HStack{
                            StartPacking
                                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "square.and.arrow.down",
                                                                        disabled: runDisabled,
                                                                        enabled: !runDisabled,
                                                                        alwaysShowTitle: false,
                                                                        width: g.size.width / 2 - 20,
                                                                        color: .green,
                                                                        hideBackground: false,
                                                                        backgroundIsNotFill: false,
                                                                        blurBackground: true,
                                                                        render: .palette))
                            Spacer()
                            startOver
                                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "arrow.uturn.left.square",
                                                                        disabled: appPickerDisabled,
                                                                        enabled: !appPickerDisabled,
                                                                        alwaysShowTitle: false,
                                                                        width: g.size.width / 2 - 20,
                                                                        color: .green,
                                                                        hideBackground: false,
                                                                        backgroundIsNotFill: false,
                                                                        blurBackground: true,
                                                                        render: .palette))
                        }
                        Spacer()
                    }
                }
            } label: {
                CustomViews.AnimatedTextView(Input: "packer.title", TimeToStopAnimation: SettingsMonitor.secAnimDur)
            }
            .groupBoxStyle(Stylers.CustomGBStyle())
            .background(content: {
                CustomViews.ImageView(imageName: "doc.zipper")
            })
            .onAppear {
                devID = SettingsMonitor.devID
                password = SettingsMonitor.password
                signP = SettingsMonitor.passwordSaved && SettingsMonitor.devID != "" ? true : false
            }
            .animation(SettingsMonitor.secondaryAnimation, value: pathOfFInstall)
            .animation(SettingsMonitor.secondaryAnimation, value: filename)
            .animation(SettingsMonitor.secondaryAnimation, value: savePath)
        } else {
            CustomViews.NoPasswordView(false, toggle: $dummy)
        }
    }
}

struct PackerPreview: PreviewProvider {
    static var previews: some View {
        PackerView()
    }
}

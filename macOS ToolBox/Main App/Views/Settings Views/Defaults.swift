//
//  Defaults.swift
//  MultiTool
//
//  Created by Олег Сазонов on 01.07.2022.
//

import Foundation
import SwiftUI

struct Defaults: View {
    @State private var secondButtonColor: Color = .clear
    @State private var firstButtonColor: Color = .clear
    @State private var mainButtonColor: Color = .clear
    var body: some View {
        GroupBox {
            Group {
                CustomViews.AnimatedTextView(Input: StringLocalizer("warning.details.string"), Font: .title, FontWeight: .bold)
            }
            VStack{
                Group {
                    GeometryReader { gp in
                        Button {
                            SettingsMonitor().defaults()
                            AppDelegate().applicationWillTerminate(.init(name: NSApplication.willTerminateNotification, object: .none, userInfo: .none))
                            func relaunch(afterDelay seconds: TimeInterval = 0.5) -> Never {
                                Shell.Parcer.OneExecutable.withNoOutput(args: ["sleep \(seconds); open \"\(Bundle.main.bundlePath)\""])
                                NSApp.terminate(self)
                                exit(EXIT_SUCCESS)
                            }
                            relaunch()
                        } label: {
                            CustomViews.AnimatedTextView(Input: "all.default", Font: .title2, FontWeight: .bold).padding(.all)
                        }
                        .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, width: gp.size.width, height: gp.size.height, color: .red))
                    }
                }.padding(.all)
            }
        } label: {
            CustomViews.AnimatedTextView(Input: StringLocalizer("WARNING.STRING"),Font: .largeTitle, FontWeight: .heavy)
        }
        .groupBoxStyle(Stylers.CustomGBStyle())
        .background(content: {
            Image(systemName: "exclamationmark.triangle")
                .font(.custom("San Francisco", size: 140))
                .fontWeight(.light)
                .foregroundStyle(RadialGradient(colors: [.white, .yellow, .white], center: .center, startRadius: 0, endRadius: 140))
                .opacity(0.5).blur(radius: 2)
                .shadow(radius: 15)
        })
        .animation(.easeInOut(duration: 1), value: DispatchTime.now())
    }
}

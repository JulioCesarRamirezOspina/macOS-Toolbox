//
//  Main View.swift
//  MultiTool
//
//  Created by Олег Сазонов on 06.06.2022.
//

import SwiftUI
import Combine
import xCore

//MARK: - Main View
struct MainView: View {
	private func toggleSidebar() {
		NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
	}
	@State var loadingViewIsHidden = false
	@State var width: CGFloat?
	@State var height: CGFloat?
	@State var timeIsHidden = false
	@State var buttonCondition = 0
	@State private var collapsed = false
	@State var isRun = false
	@State var colorScheme: ColorScheme? = Theme.colorScheme
	
	//MARK: - Animated Weclome screen
	private func welcomeScreen(_ timeToStop: Double? = 0) -> some View {
		return VStack{
			Spacer()
			ZStack{
			}.background {}
				.onHover { t in
					if collapsed {
						toggleSidebar()
					}
				}
			Spacer()
            SystemStatus.Switcher(toggleViews: $isMore, withButton: true)
		}
	}
    
    let inMenuBar = SettingsMonitor.isInMenuBar
    
    let inMenuBarViews: [ViewForGenerator] = [
        ViewForGenerator(
            view: AnyView(CamperView()),
            label: "Camper", typeOf: .link
        ),
        ViewForGenerator(
            view: AnyView(TorView()),
            label: "Tor VPN",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(TouchIDView()),
            label: "TouchID",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(LaunchpadManagerView()),
            label: "Launchpad",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(DockManagerView()),
            label: "Dock",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(SleepManagerView()),
            label: "sleepManager.string",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(RAMDiskView()),
            label: "RAM + RAM Disk",
            typeOf: ViewType.link
        )
    ]
    
    let plainAppViews: [ViewForGenerator] = [
        ViewForGenerator(
            view: AnyView(CamperView()),
            label: "Camper", typeOf: .link
        ),
        ViewForGenerator(
            view: AnyView(TorView()),
            label: "Tor VPN",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(BetaSeedView()),
            label: "macOS Beta",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(TouchIDView()),
            label: "TouchID",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(PackerView()),
            label: "packer.name",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(LaunchpadManagerView()),
            label: "Launchpad",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(DockManagerView()),
            label: "Dock",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(SleepManagerView()),
            label: "sleepManager.string",
            typeOf: ViewType.link
        ),
        ViewForGenerator(
            view: AnyView(RAMDiskView()),
            label: "RAM + RAM Disk",
            typeOf: ViewType.link
        )
    ]
	
	//MARK: - Views for Navigation Generator

	@State var view: ViewForGenerator.ID = UUID()
	
	@State var mainTitle = StringLocalizer("developerTeam")
	
	@State var isMore = false
	
	//MARK: - Main View
	var body: some View {
		GeometryReader { g in
			VStack(alignment: .center){
				HStack {
                    NavigationSplitView(sidebar: {
                        VStack{
                            NavigationLink {
                                welcomeScreen(SettingsMonitor.mainAnimDur)
                            } label: {
                                VStack{
                                    HStack{
                                        Spacer()
                                        Text(mainTitle)
                                            .animation(SettingsMonitor.secondaryAnimation, value: mainTitle)
                                            .font(.largeTitle)
                                            .foregroundColor(.primary)
                                            .monospacedDigit()
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.all)
                            .onHover(perform: { t in
                                switch t {
                                case true: mainTitle = StringLocalizer("overview.string")
                                case false: mainTitle = StringLocalizer("developerTeam")
                                }
                            })
                            .buttonStyle(.borderless)
                            .focusable(false)
                            Divider()
                            GeometryReader { pr in
                                ScrollView(.vertical, showsIndicators: true) {
                                    NavigationLinkGenerator(Views: inMenuBar ? inMenuBarViews : plainAppViews)
                                }
                                .frame(width: pr.size.width)
                            }
                            TimeAndQuit(colorScheme: $colorScheme)
                                .background(SplitViewAccessor(isCollapsed: $collapsed))
                                .listStyle(.sidebar)
                                .focusable(false)
                        }
                        .border(.separator.opacity(SettingsMonitor.isInMenuBar ? 1 : 0))
                    }, detail: {
                        welcomeScreen(SettingsMonitor.mainAnimDur)
                            .onHover { t in
                                if t {
                                    if collapsed {
                                        toggleSidebar()
                                    }
                                }
                            }
                    })
                    .toolbar(.hidden, for: .windowToolbar)
				}
			}
			.onAppear {
				delay(after: SettingsMonitor.mainAnimDur / 10) {
					isRun = true
				}
				width = g.size.width / 5
				height = g.size.height
				if collapsed {
					delay(after: SettingsMonitor.mainAnimDur) {
							toggleSidebar()
					}
				}
			}
			.onHover { t in
				if t {
					if collapsed {
						toggleSidebar()
					}
				}
			}
		}
		.preferredColorScheme(colorScheme)
		.animation(SettingsMonitor.secondaryAnimation, value: colorScheme)
		.animation(SettingsMonitor.secondaryAnimation, value: collapsed)
	}
}

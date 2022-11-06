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
	//	private var initCS: ColorScheme? {
	//		get {
	//			@Environment(\.colorScheme) var ics
	//			return ics
	//		}
	//	}
	
	//MARK: - Animated Weclome screen
	private func welcomeScreen(_ timeToStop: Double? = 0) -> some View {
		return VStack{
			Spacer()
			ZStack{
				//				if isRun {
				//					CustomViews.AnimatedTextView(Input: "welcome.string", TimeToStopAnimation: timeToStop).padding(.all)
				//						.blur(radius: !collapsed ? 0 : 15)
				//						.opacity(!collapsed ? 1 : 0)
				//						.animation(.easeInOut(duration: timeToStop!), value: DispatchTime.now())
				//						.padding(.all)
				//				} else {
				//					Spacer()
				//				}
			}.background {}
			//				VStack{
			//					if isRun {
			//						CustomViews.AppLogo()
			//							.blur(radius: !collapsed ? 0 : 15)
			//							.opacity(!collapsed ? 1 : 0)
			//							.animation(.easeInOut(duration: timeToStop!), value: DispatchTime.now())
			//							.padding(.top)
			//						if !collapsed{
			//							VStack{
			//								Text(" ").font(.largeTitle)
			//								Text(" ").font(.largeTitle)
			//								Text(" ").font(.largeTitle)
			//								Text(" ").font(.largeTitle)
			//								Text(" ").font(.largeTitle)
			//								Text(" ").font(.largeTitle)
			//								Text(" ").font(.largeTitle)
			//							}.padding(.all)
			//						}
			//					}
			//				}
			//			}
				.onHover { t in
					if collapsed {
						toggleSidebar()
					}
				}
			Spacer()
			SystemStatus.Switcher(toggleViews: $isMore, withButton: true)
//			Button(isMore ? "goBack.button" : "more.string") {
//				isMore.toggle()
//			}
            if isMore {
                Button("goBack.button") {
                    isMore.toggle()
                }
                .buttonStyle(Stylers.ColoredButtonStyle(alwaysShowTitle: true, width: 150, height: 50, color: .blue))
                .padding(.all)
            }
		}
	}
	
	//MARK: - Views for Navigation Generator
	let Views: [ViewForGenerator] = [
		
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
	@State var view: ViewForGenerator.ID = UUID()
	
	@State var mainTitle = StringLocalizer("developerTeam")
	
	@State var isMore = false
	
	private func NV() -> some View {
		NavigationSplitView(sidebar: {
			NavigationLink {
				welcomeScreen(SettingsMonitor.mainAnimDur)
			} label: {
				VStack{
					HStack{
						Spacer()
						Text(mainTitle)
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
			Divider()
			ScrollView(.vertical, showsIndicators: true) {
				NavigationLinkGenerator(Views: Views)
			}
			TimeAndQuit(colorScheme: $colorScheme)
				.background(SplitViewAccessor(isCollapsed: $collapsed))
				.frame(width: width, alignment: .center)
				.listStyle(.sidebar)
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
	
	//MARK: - Main View
	var body: some View {
		GeometryReader { g in
			VStack(alignment: .center){
				HStack {
					NV()
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
		.animation(SettingsMonitor.secondaryAnimation, value: mainTitle)
	}
}

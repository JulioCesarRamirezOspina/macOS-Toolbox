//
//  TimeView.swift
//  MultiTool
//
//  Created by Олег Сазонов on 06.06.2022.
//

import Foundation
import SwiftUI
import xCore

struct TimeView: View {
    @Environment(\.locale) var locale
    @State var timeNow = Date().formatted(date: .omitted, time: .standard)
    @State var textStyle: Font.Weight? = .regular
    @State var font: Font? = .body
    @State var uptime = macOS_Subsystem.uptime()
    @State var hover = false
    var body: some View {
        VStack{
            Group {
                if !hover {
                    VStack(alignment: .center) {
                        Text(timeNow)
                        //            Text(Date(), style: .time)
                        Text(Date(), style: .date)
                        Text("\(uptime.days), \(uptime.hrs.description.count == 1 ? "0\(uptime.hrs)" : "\(uptime.hrs)"):\(uptime.mins.description.count == 1 ? "0\(uptime.mins)" : "\(uptime.mins)"):\(uptime.secs.description.count == 1 ? "0\(uptime.secs)" : "\(uptime.secs)")")
                        
                    }
                } else {
                    VStack{
                        Text("clicktoquit.string")
                    }
                }
                
            }
            .fontWeight(textStyle)
            .font(font)
            .monospacedDigit()
        }
        .animation(SettingsMonitor.secondaryAnimation, value: hover)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { t in
                let dateTime = Date()
                timeNow = dateTime.formatted(date: .omitted, time: .standard)
                uptime = macOS_Subsystem.uptime()
            }
        }
        .onHover(perform: { t in
            hover = t
        })
        .environment(\.locale, locale)
    }
}

struct TimePreview: PreviewProvider {
    static var previews: some View {
        TimeView(textStyle: .bold, font: .body)
    }
}

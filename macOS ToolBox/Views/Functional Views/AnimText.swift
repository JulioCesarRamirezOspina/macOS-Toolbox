//
//  AnimText.swift
//  MultiTool
//
//  Created by Олег Сазонов on 11.06.2022.
//

import Foundation
import SwiftUI
import SuperStuff

struct AnimatedTextView: View {
    @Environment(\.locale) var locale
    @State private var pend = ""
    @State var input: String? = "no.input"
    @State private var dark = false
    @State private var frequency: Double = 0
    @State private var stop = false
    @State var font: Font? = .largeTitle
    @State var fontWeight: Font.Weight? = .bold
    @State var timeToStopAnimation: Double? = Observer().mainAnimDur
    @State private var running = false
    
    func displayTextOld() {
        running = true
        let pString = input!
        let arr = Array(pString)
        var index = 0
        let count = arr.count
        var wordCount = 0
        frequency = timeToStopAnimation!/Double(count)
        if timeToStopAnimation == 0 {
            frequency = 0
        }
        Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { t in
            if pend.last == " " {wordCount += 1}
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
    }
    
    func displayText() {
        running = true
        let pString = input!
        let arr = Array(pString)
        var index = 0
        let count = arr.count
        var wordCount = 0
        frequency = timeToStopAnimation!/Double(count)
        if timeToStopAnimation != 0 {
            Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { t in
                if pend.last == " " {wordCount += 1}
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
    
    var body: some View {
        VStack(alignment: .center){
            HStack{
                Text(!running ? "\(pend) " : (dark ? "\(pend) " : "\(pend)_")).monospacedDigit()
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

struct AnimTextPreview: PreviewProvider {
    static var previews: some View {
        AnimatedTextView()
            .frame(width: 500, height: 500, alignment: .center)
    }
}

//
//  LaunchpadView.swift
//  MultiTool
//
//  Created by Олег Сазонов on 24.06.2022.
//

import Foundation
import SwiftUI
import xCore

struct LaunchpadManagerView: View {
    @State private var x: Float = 7
    @State private var y: Float = 5
    @State private var defaultX = Float()
    @State private var defaultY = Float()
    @State private var xConf: Float = LaunchpadManager().getCoord(.x)
    @State private var yConf: Float = LaunchpadManager().getCoord(.y)
    @State private var showTable = false
    @State private var maxRows = Float(LaunchpadManager().getCoord(.x))
    @State private var maxColumns = Float(LaunchpadManager().getCoord(.y))
    @State private var xEdit = false
    @State private var yEdit = false
    
    private func tableSubView(_ color: Color = .primary, x: Int, y: Int) -> some View {
        ZStack{
            HStack(alignment: .center, spacing: 5){
                Text(x.description).rotationEffect(.degrees(-45)).foregroundColor(color)
                Text("|").foregroundColor(color)
                Text(y.description).rotationEffect(.degrees(-45)).foregroundColor(color)
            }.rotationEffect(.degrees(45))
            Image(systemName: "app.dashed").font(.custom("San Francisco", size: 50)).foregroundColor(color).fontWeight(.ultraLight)
        }
        .backgroundStyle(.ultraThickMaterial)
        .onHover { t in
            if t {
                self.x = Float(x)
                self.y = Float(y)
            }
        }
        .onTapGesture {
            xConf = Float(x)
            yConf = Float(y)
            LaunchpadManager().setCoord(.x, xConf)
            LaunchpadManager().setCoord(.y, yConf)
            LaunchpadManager().reset()
            DockManager().restartDock()
            maxRows = xConf
            maxColumns = yConf
            defaultX = xConf
            defaultY = yConf
        }
        .onLongPressGesture {
            xConf = Float(7)
            yConf = Float(5)
            LaunchpadManager().setCoord(.x, xConf)
            LaunchpadManager().setCoord(.y, yConf)
            LaunchpadManager().reset()
            DockManager().restartDock()
            maxRows = xConf
            maxColumns = yConf
            defaultX = xConf
            defaultY = yConf
        }
    }
    
    private var TableView: some View {
        HStack{
            ForEach(2..<(Int(maxRows) + 1), id: \.self) {x in
                VStack{
                    ForEach(2..<(Int(maxColumns) + 1), id: \.self) {y in
                        switch (Float(x), Float(y)) {
                            //                        case (defaultX, defaultY):
                            //                            tableSubView(.green, x: x, y: y)
                            //                        case (maxRows, maxColumns):
                            //                            tableSubView(.blue, x: x, y: y)
                        default:
                            tableSubView(x: x, y: y)
                        }
                    }
                }
            }
        }.padding(.all)
    }
    
    private var resetLaunchpad: some View {
        HStack {
            Spacer()
            Button {
                LaunchpadManager().setCoord(.x, 7)
                LaunchpadManager().setCoord(.y, 5)
                LaunchpadManager().reset()
                DockManager().restartDock()
                yConf = 5
                xConf = 7
            } label: {
                Text(StringLocalizer("reset.string"))
            }.disabled((yConf == 5 && xConf == 7))
            Spacer()
        }.padding(.all)
    }
    
    private var rows: some View {
        Slider(value: $maxRows, in: 2...16, step: 1) {
            Text(StringLocalizer("columns.string")).fontWeight(.bold).foregroundColor(xEdit ? .white : maxRows == defaultX ? .green : .primary)
            HStack{
                Text(Int(maxRows).description).fontWeight(xEdit ? .bold : .regular).foregroundColor(xEdit ? .white : .primary).monospacedDigit()
                Image(systemName: "arrow.left").fontWeight(xEdit ? .bold : .regular).foregroundColor(xEdit && xConf != maxRows ? .white : .clear).monospacedDigit()
                Text("\(Int(xConf).description)").fontWeight(xEdit ? .bold : .regular).foregroundColor(xEdit && xConf != maxRows ? .white : .clear).monospacedDigit()
            }
        } minimumValueLabel: {
            Text("2")
        } maximumValueLabel: {
            Text("16")
        } onEditingChanged: { t in
            if !t {
                if xConf != maxRows {
                    LaunchpadManager().setCoord(.x, maxRows)
                    LaunchpadManager().reset()
                    DockManager().restartDock()
                    xConf = LaunchpadManager().getCoord(.x)
                    yConf = LaunchpadManager().getCoord(.y)
                    defaultY = yConf
                    defaultX = xConf
                    xEdit = false
                }
            }
            if t {
                xEdit = true
            } else {
                xEdit = false
            }
        }
        .tint(maxRows == defaultX ? .green : .primary)
    }
    
    private var columns: some View {
        Slider(value: $maxColumns, in: 2...10, step: 1) {
            Text(StringLocalizer("rows.string")).fontWeight(.bold).foregroundColor(yEdit ? .white : maxColumns == defaultY ? .green : .primary)
            HStack{
                Text(Int(maxColumns).description).fontWeight(yEdit ? .bold : .regular).foregroundColor(yEdit ? .white : .primary).monospacedDigit()
                Image(systemName: "arrow.left").fontWeight(yEdit ? .bold : .regular).foregroundColor(yEdit && yConf != maxColumns ? .white : .clear).monospacedDigit()
                Text("\(Int(yConf).description)").fontWeight(yEdit ? .bold : .regular).foregroundColor(yEdit && yConf != maxColumns ? .white : .clear).monospacedDigit()
            }
        } minimumValueLabel: {
            Text("2")
        } maximumValueLabel: {
            Text("10")
        } onEditingChanged: { t in
            if !t {
                if yConf != maxColumns {
                    LaunchpadManager().setCoord(.y, maxColumns)
                    LaunchpadManager().reset()
                    DockManager().restartDock()
                    xConf = LaunchpadManager().getCoord(.x)
                    yConf = LaunchpadManager().getCoord(.y)
                    defaultY = yConf
                    defaultX = xConf
                    yEdit = false
                }
            }
            if t {
                yEdit = true
            } else {
                yEdit = false
            }
        }
        .tint(maxRows == defaultX ? .green : .primary)
    }
    
    private func ColumnsView(width: CGFloat, height: CGFloat) -> some View {
        ZStack{
            if yEdit {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.blue)
                    .blur(radius: 10)
            }
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.ultraThinMaterial)
                .shadow(radius: 10)
            columns
                .padding(.all)
        }
        .frame(width: width / 1.5, height: height / 20, alignment: .center)
        .padding(.all)
    }
    
    private func RowsView(width: CGFloat, height: CGFloat) -> some View {
        ZStack{
            if xEdit {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.blue)
                    .blur(radius: 5)
            }
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.ultraThinMaterial)
                .shadow(radius: 10)
            rows
                .padding(.all)
        }
        .frame(width: width / 1.5, height: height / 20, alignment: .center)
        .padding(.all)
    }
    
    private var MainTabView: some View {
        GeometryReader { geo2 in
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(radius: 10)
                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        TableView
                    }
                }
            }.frame(width: geo2.size.width, height: geo2.size.height, alignment: .center)
        }.padding(.all)
    }
    
    var body: some View {
        GroupBox {
            GeometryReader { geometry in
                VStack{
                    HStack{
                        Spacer()
                        Group {
                            ColumnsView(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(-90), anchor: .center).frame(width: geometry.size.width / 20, height: geometry.size.height / 1.5, alignment: .center).padding(.all)
                        }
                        Divider()
                        Group {
                            VStack {
                                RowsView(width: geometry.size.width, height: geometry.size.height).padding(.all)
                                Divider()
                                MainTabView
                            }
                        }
                        Divider()
                        
                    }
                    Spacer()
                }
                
            }
        } label: {
            CustomViews.AnimatedTextView(Input: "Launchpad", TimeToStopAnimation: SettingsMonitor.secAnimDur)
        }
        .groupBoxStyle(Stylers.CustomGBStyle())
        .animation(SettingsMonitor.secondaryAnimation, value: maxRows)
        .animation(SettingsMonitor.secondaryAnimation, value: maxColumns)
        .animation(SettingsMonitor.secondaryAnimation, value: defaultX)
        .animation(SettingsMonitor.secondaryAnimation, value: defaultY)
        .animation(SettingsMonitor.secondaryAnimation, value: x)
        .animation(SettingsMonitor.secondaryAnimation, value: y)
        .animation(SettingsMonitor.secondaryAnimation, value: xEdit)
        .animation(SettingsMonitor.secondaryAnimation, value: yEdit)
        .onAppear {
            defaultX = LaunchpadManager().getCoord(.x)
            defaultY = LaunchpadManager().getCoord(.y)
            maxRows = Float(LaunchpadManager().getCoord(.x))
            maxColumns = Float(LaunchpadManager().getCoord(.y))
            delay(after: SettingsMonitor.secAnimDur) {
                showTable = true
            }
        }
    }
}

struct LaunchpadManagerPreview: PreviewProvider {
    static var previews: some View {
        LaunchpadManagerView().frame(width: 1000, height: 800, alignment: .center)
    }
}

//
//  FileSearch.swift
//  xCore
//
//  Created by Олег Сазонов on 17.11.2022.
//

import Foundation
import SwiftUI

//MARK: - Virtuals
public class Virtuals: xCore {
    public override init() {}
    //MARK: - Constants
    private static let vmList = ["utm", "pvm", "vbox"]

    //MARK: - Vars
    private static var alreadyCheck = false
    
    private static var allFiles: [VMPropertiesList] {
        get {
            var retval: [VMPropertiesList] = Array()
            for each in vmList {
                retval += files(fileExtension: each)
            }
            return retval
        }
    }
    
    public static var anyExist: Bool {
        get {
            if !alreadyCheck {
                func check(ext: String) -> Bool {
                    if files(fileExtension: ext).isEmpty {
                        return false
                    } else {
                        return true
                    }
                }
                var retval = false
                for each in vmList {
                    if check(ext: each) {
                        alreadyCheck = true
                        retval = true
                        break
                    } else {
                        alreadyCheck = false
                        retval = false
                        break
                    }
                }
                return retval
            } else {
                return alreadyCheck
            }
        }
    }
    //MARK: - Funcs
    private static func files(fileExtension: String) -> [VMPropertiesList] {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", "mdfind .\(fileExtension) | grep .\(fileExtension)"]
        
        func getDates(url: URL) -> (creation: String, access: String) {
            do {
                let access = try url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date()
                let creation = try url.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date()
                let retval = (creation: creation.formatted(), access: access.formatted())
                return retval
            } catch let error {
                NSLog(error.localizedDescription)
                return ("--.--.----", "--.--.----")
            }
        }
        
        do {
            var retval: [VMPropertiesList] = []
            try process.run()
            if let out = String(data: try pipe.fileHandleForReading.readToEnd() ?? Data(), encoding: .utf8) {
                for line in out.byLines {
                    let url = URL(filePath: String(line))
                    let components = url.pathComponents
                    let namePrep = components.last!
                    let name = String(namePrep.split(separator: ".")[0])
                    let ext = String(namePrep.split(separator: ".").last ?? "")
                    let dates = getDates(url: url)
                    let creationDate = dates.creation
                    let lastAccessDate = dates.access
                    if ext == fileExtension {
                        retval.append(.init(name: name, path: url, fileExtension: fileExtension, creationDate: creationDate, lastAccessDate: lastAccessDate))
                    }
                }
                return retval
            } else {
                return []
            }
        } catch let error {
            NSLog(error.localizedDescription)
            return []
        }
    }
    //MARK: - Main Struct
    public struct FileSearch: View {
        public init () {}
        // MARK: - Funcs
        let shadowOffset: CGFloat = 3
        let shadowRadius: CGFloat = 5
        @Environment(\.colorScheme) var cs
        private func generateForEach(filesList: [VMPropertiesList], width: CGFloat) -> some View {
            return ForEach(filesList.sorted(by: <)) { file in
                ZStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ultraThinMaterial.shadow(.inner(radius: 15)))
                            .frame(width: width)
                        if file.fileExtension == "utm" {
                            CustomViews.UTMLogo()
                        } else {
                            HStack{
                                Image(systemName: "line.diagonal")
                                    .rotationEffect(.degrees(-45), anchor: .center)
                                    .font(.custom("San Francisco", size: 140))
                                    .fontWeight(.light)
                                    .frame(width: 20, height: 140, alignment: .center)
                                Image(systemName: "line.diagonal")
                                    .rotationEffect(.degrees(-45), anchor: .center)
                                    .font(.custom("San Francisco", size: 140))
                                    .fontWeight(.light)
                                    .frame(width: 20, height: 140, alignment: .center)
                            }
                            .foregroundStyle(RadialGradient(colors: [.blue, .gray, .white], center: .center, startRadius: 0, endRadius: 140))
                            .opacity(0.5).blur(radius: 2)
                            .shadow(radius: 15)
                            .padding(.all)
                        }
                    }
                    VStack{
                        HStack{
                            Text(file.name)
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .foregroundStyle(.primary.shadow(.drop(radius: shadowRadius, x: shadowOffset, y: shadowOffset)))
                                .padding(.all)
                            Spacer()
                                Button {
                                    NSWorkspace().open(file.path)
                                } label: {
                                    Text("launch.button").foregroundColor(.primary)
                                }
                                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "bolt",
                                                                        alwaysShowTitle: false,
                                                                        color: file.fileExtension == "utm" ? .blue : .red,
                                                                        glow: true))
                        }
                        HStack{
                            VStack(alignment: .trailing){
                                HStack{
                                    Text("creationDate")
                                        .foregroundStyle(.secondary.shadow(.drop(radius: shadowRadius, x: shadowOffset, y: shadowOffset)))
                                    TextDivider(height: 10, foregroundColor: SettingsMonitor.textColor(cs))
                                    Text(file.creationDate)
                                        .foregroundStyle(.secondary.shadow(.drop(radius: shadowRadius, x: shadowOffset, y: shadowOffset)))
                                    Spacer()
                                }
                                HStack{
                                    Text("lastAccessDate")
                                        .foregroundStyle(.secondary.shadow(.drop(radius: shadowRadius, x: shadowOffset, y: shadowOffset)))
                                    TextDivider(height: 10, foregroundColor: SettingsMonitor.textColor(cs))
                                    Text(file.lastAccessDate)
                                        .foregroundStyle(.secondary.shadow(.drop(radius: shadowRadius, x: shadowOffset, y: shadowOffset)))
                                    Spacer()
                                }
                            }.padding(.all)
                            Spacer()
                                Button {
                                    NSWorkspace.shared.activateFileViewerSelecting([file.path])
                                } label: {
                                    Text("finder.text").foregroundColor(.primary)
                                }
                                .buttonStyle(Stylers.ColoredButtonStyle(glyph: "magnifyingglass",
                                                                        alwaysShowTitle: false,
                                                                        color: .secondary,
                                                                        glow: true))
                        }
                    }.padding(.all)
                }
            }.frame(width: width)
        }
        //MARK: - Body
        public var body: some View {
            HStack {
                GeometryReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        generateForEach(filesList: allFiles, width: proxy.size.width)
                    }
                }
            }
        }
        
        public func onlyForEachView(width: CGFloat) -> some View {
            generateForEach(filesList: allFiles, width: width)
        }
    }
}

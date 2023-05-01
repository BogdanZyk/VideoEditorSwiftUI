//
//  TextBox.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 28.04.2023.
//

import Foundation
import SwiftUI


struct TextBox: Identifiable{
    
    var id: UUID = UUID()
    var text: String = ""
    var position: CGPoint = .zero
    var fontSize: CGFloat = 20
    var lastFontSize: CGFloat = .zero
    var bgColor: Color = .white
    var fontColor: Color = .black
    var timeRange: ClosedRange<Double> = 0...10
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    
    
    static let texts: [TextBox] =
    
    [
    
        .init(text: "Test1", position: .init(x: 400, y: 400), fontSize: 38, bgColor: .red, fontColor: .white, timeRange: 0...2),
        .init(text: "Test2", position: .init(x: 350, y: 300), fontSize: 38, bgColor: .secondary, fontColor: .white, timeRange: 2...6),
        .init(text: "Test3", position: .init(x: 300, y: 550), fontSize: 38, bgColor: .black, fontColor: .red, timeRange: 3...6),
        .init(text: "Test4", position: .init(x: 350, y: 500), fontSize: 38, bgColor: .black, fontColor: .blue, timeRange: 5...6),
        .init(text: "Test5", position: .init(x: 300, y: 400), fontSize: 38, bgColor: .black, fontColor: .white, timeRange: 1...6),
    ]
    
    static let simple = TextBox(text: "Test", position: .init(x: 200, y: 400), fontSize: 38, bgColor: .black, fontColor: .white, timeRange: 1...3)
}

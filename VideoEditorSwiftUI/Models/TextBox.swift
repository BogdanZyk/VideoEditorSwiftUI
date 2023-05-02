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
    var fontSize: CGFloat = 20
    var lastFontSize: CGFloat = .zero
    var bgColor: Color = .white
    var fontColor: Color = .black
    var timeRange: ClosedRange<Double> = 0...3
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    
    
}


extension TextBox: Equatable{}


extension TextBox{
    static let texts: [TextBox] =
    
    [
    
        .init(text: "Test1", fontSize: 38, bgColor: .red, fontColor: .white, timeRange: 0...2),
        .init(text: "Test2", fontSize: 38, bgColor: .secondary, fontColor: .white, timeRange: 2...6),
        .init(text: "Test3", fontSize: 38, bgColor: .black, fontColor: .red, timeRange: 3...6),
        .init(text: "Test4", fontSize: 38, bgColor: .black, fontColor: .blue, timeRange: 5...6),
        .init(text: "Test5", fontSize: 38, bgColor: .black, fontColor: .white, timeRange: 1...6),
    ]
    
    static let simple = TextBox(text: "Test", fontSize: 38, bgColor: .black, fontColor: .white, timeRange: 1...3)
}

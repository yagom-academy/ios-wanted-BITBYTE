//
//  CustomKeyBoardViewModel.swift
//  CustomKeyboard
//
//  Created by 김기림 on 2022/07/14.
//

import Foundation
import UIKit

struct CustomKeyBoardViewModel {
    private let engine: KeyBoardEngine
    
    init(engine: KeyBoardEngine) {
        self.engine = engine
    }
    
    func addWord(inputUniCode: Int, to beforeText: String?) -> String {
        let inputChar = String(UnicodeScalar(inputUniCode)!)
        guard let beforeText = beforeText else { return "" }
        let lastCharUnicode = getLastCharUnicode(from: beforeText)
        if beforeText == "" {
            return inputChar
        }
        let beforeTextExceptLastChar = getStringExceptLastChar(from: beforeText)
        let lastChar = engine.addWord(inputUniCode: inputUniCode, lastUniCode: lastCharUnicode)
        return beforeTextExceptLastChar + lastChar
    }
    
    func addSpace(inputUniCode: Int, to beforeText: String?) -> String {
        let space = String(UnicodeScalar(inputUniCode)!)
        guard let beforeText = beforeText else { return "" }
        return beforeText + space
    }
    
    func removeWord(from beforeText: String?) -> String {
        //TODO: 지우기버튼 구현
        guard let beforeText = beforeText else { return "" }
        if beforeText == "" {
            return ""
        }
        let lastCharUnicode = getLastCharUnicode(from: beforeText)
        let beforeTextExceptLastChar = getStringExceptLastChar(from: beforeText)
        let lastChar = engine.removeWord(lastUniCode: lastCharUnicode)
        
        return beforeTextExceptLastChar + lastChar
    }
    
    // 맨마지막 단어 유니코드 추출
    private func getLastCharUnicode(from text: String) -> Int {
        guard text != "" else { return 0 }
        let lastChar = String(text.last!)
        return Int(UnicodeScalar(lastChar)!.value)
    }
    
    // 맨마지막 단어를 뺀 문자열 반환
    private func getStringExceptLastChar(from text: String) -> String {
        let i = text.index(text.endIndex, offsetBy: -1)
        return String(text[text.startIndex..<i])
    }
}

//
//  String+.swift
//  CustomKeyboard
//
//  Created by yc on 2022/07/12.
//

import Foundation

extension String {
    var toIdentifierPath: String {
        var ret = self
        ret = ret.replacingOccurrences(of: "https://", with: "")
        ret = ret.replacingOccurrences(of: "http://", with: "")
        ret = ret.replacingOccurrences(of: "/", with: "_")
        return ret
    }
    
    var toDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "y-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.date(from: self)
    }
    
    mutating func appendUnicode(_ code: UInt32?) {
        guard let code = code,
              let unicode = UnicodeScalar(code) else { return }
        append(String(unicode))
    }
}

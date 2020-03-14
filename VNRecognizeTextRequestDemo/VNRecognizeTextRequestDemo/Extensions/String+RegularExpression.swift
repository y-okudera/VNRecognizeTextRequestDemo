//
//  String+RegularExpression.swift
//  VNRecognizeTextRequestDemo
//
//  Created by Yuki Okudera on 2020/03/13.
//  Copyright © 2020 Yuki Okudera. All rights reserved.
//

import Foundation

infix operator =~

private func =~(lhs: String, rhs: String) -> Bool {
    
    do {
        let regex = try NSRegularExpression(pattern: rhs)
        let range = NSRange(location: 0, length: lhs.count)
        let numberOfMatches = regex.numberOfMatches(in: lhs, range: range)
        return numberOfMatches > 0
    } catch {
        return false
    }
}

extension String {
    
    /// クレジットカード番号かどうか
    ///
    /// 数字のみ14~16桁の場合、true
    func isCreditNumber() -> Bool {
        let replacedText = self.replacingOccurrences(of: " ", with: "")
        return replacedText =~ #"[0-9]{14,16}"#
    }
}

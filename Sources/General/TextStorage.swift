//
//  TextStorage.swift
//  Notas
//
//  Created by Archy on 2020/11/22.
//
//  Copyright (c) 2019 Archy Van <archy.fanjingqi@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

class TextStorage: NSTextStorage {
    var textView: Notas!
    
    var currentAttributedString: NSMutableAttributedString = NSMutableAttributedString()
    
    var isChangeCharacters: Bool = false

    override var string: String {
        return currentAttributedString.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return currentAttributedString.attributes(at: location, effectiveRange: range)
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        guard currentAttributedString.string.length() > range.location else {
            return
        }
        
        beginEditing()
        
        currentAttributedString.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        
        endEditing()
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        
        var prefixItemLength = 0
        var prefixItemText: NSString = ""

        if NotasUtil.isNewline(str) {
            let previousInfo = NotasUtil.previousInfo(self.string, location: range.location)
            let firstHalf = previousInfo.0

            switch NotasUtil.paragraphListType(firstHalf) {
            case .orderedList:
                guard var number = Int(firstHalf.components(separatedBy: ".")[0]) else { break }

                number += 1
                prefixItemText = "\(number). " as NSString
                prefixItemLength = "\(number). ".length()
                break
            case .unorderedList:
                let prefixItem = firstHalf.components(separatedBy: " ")[0]
                prefixItemText = "\(prefixItem) " as NSString

                prefixItemLength = prefixItemText.length
            default:
                break
            }
        }
        
        beginEditing()
        
        let finalStr: NSString = "\(str)" as NSString
        
        currentAttributedString.replaceCharacters(in: range, with: String(finalStr))
        
        edited(.editedCharacters, range: range, changeInLength: (finalStr.length - range.length))
        
        endEditing()
        
        if prefixItemLength > 0 {
            appendRange(NSMakeRange(range.location + str.length(), 0), with: String(prefixItemText), selectedRangeLocationMove: prefixItemLength)
        }
    }
    
    override func processEditing() {
        if isChangeCharacters && editedRange.length > 0 {
            isChangeCharacters = false
        }
        super.processEditing()
    }
    
    
    func currentParagraphType(with location: Int) -> NotasParagraphType {
        if self.textView.text == "" {
            return .normal
        }
        
        let paragraphRange = NotasUtil.paragraphRange(of: self.string, location: location)
        let paragraph = NSString(string: self.string).substring(with: paragraphRange)
        
        return NotasUtil.paragraphListType(paragraph)
    }
    
    func appendRange(_ replaceRnage: NSRange, with str: String, selectedRangeLocationMove: Int) {
        safeReplaceCharacters(in: replaceRnage, with: str)
        textView.selectedRange = NSMakeRange(textView.selectedRange.location + selectedRangeLocationMove, 0)
    }
    
    func replaceRange(_ range: NSRange, withAttributedString attributedStr: NSAttributedString, oldAttributedString: NSAttributedString, selectedRangeLocationMove: Int) {
        
        let targetSelectedRange = NSMakeRange(textView.selectedRange.location + selectedRangeLocationMove, textView.selectedRange.length)
        safeReplaceCharacters(in: range, with: attributedStr)
        textView.selectedRange = targetSelectedRange
    }
}

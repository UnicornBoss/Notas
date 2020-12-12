//
//  NSAttributedString+SafeReplace.swift
//  Notas
//
//  Created by Archy on 2020/11/22.
//
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

import Foundation

extension NSMutableAttributedString {
    
    func safeReplaceCharacters(in range: NSRange, with str: String) {
        if isSafeRange(range) {
            replaceCharacters(in: range, with: str)
        }
    }
    
    func safeReplaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
        if isSafeRange(range) {
            replaceCharacters(in: range, with: attrString)
        }
    }
    
    func safeAddAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSRange) {
        if isSafeRange(range) {
            addAttributes(attrs, range: range)
        }
    }
}

extension NSAttributedString {
    
    func safeAttribute(_ attrName: String, at index: Int, effectiveRange range: NSRangePointer?, defaultValue: Any?) -> Any? {
        var attributeValue: Any? = nil
        
        if index >= 0 && index < string.length() {
            attributeValue = attribute(NSAttributedString.Key(attrName), at: index, effectiveRange: range) as Any?
        }
        
        return attributeValue == nil ? defaultValue : attributeValue
    }
    
    func isSafeRange(_ range: NSRange) -> Bool {
        if range.location < 0 || range.location == NSNotFound {
            return false
        }
        
        if range.length < 0 || range.length == NSNotFound {
            return false
        }
        
        let maxIndex = range.location + range.length
        if maxIndex <= string.length() {
            return true
        } else {
            return false
        }
    }
}

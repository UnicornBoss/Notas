//
//  NotasUtil.swift
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

public class NotasUtil: NSObject {
    static let unorderedListRegularExpression = try! NSRegularExpression(pattern: "^[-*••∙●] ", options: .caseInsensitive)
    static let orderedListRegularExpression = try! NSRegularExpression(pattern: "^\\d*\\. ", options: .caseInsensitive)
    static let orderedListAfterItemsRegularExpression = try! NSRegularExpression(pattern: "\\n\\d*\\. ", options: .caseInsensitive)

    class func keyboardWindow() -> UIWindow? {
        var window: UIWindow?
        
        UIApplication.shared.windows.forEach {
            if String(describing: type(of: $0)) == "UITextEffectsWindow" {
                window = $0
                return
            }
        }
        
        return window
    }
    
    class func isNewline(_ text: String) -> Bool {
        if text == "\n" {
            return true
        } else {
            return false
        }
    }
    
    class func isBackspace(_ text: String) -> Bool {
        if text == "" {
            return true
        } else {
            return false
        }
    }
    
    class func isSelectedText(with textView: UITextView) -> Bool {
        let length = textView.selectedRange.length
        return length > 0
    }
    
    class func isBoldFont(_ font: UIFont, boldFontName: String) -> Bool {
        if font.fontName == boldFontName {
            return true
        }
        
        let keywords = ["bold", "medium"]
        
        return isSpecialFont(font, keywords: keywords)
    }
    
    class func isItalicFont(_ font: UIFont, italicFontName: String) -> Bool {
        if font.fontName == italicFontName {
            return true
        }

        let keywords = ["italic"]

        return isSpecialFont(font, keywords: keywords)
    }
    
    class func isSpecialFont(_ font: UIFont, keywords: [String]) -> Bool {
        let fontName = NSString(string: font.fontName)
        
        for keyword in keywords {
            if fontName.range(of: keyword, options: .caseInsensitive).location != NSNotFound {
                return true
            }
        }
        
        return false
    }
    
    class func isListParagraph(_ text: String) -> Bool {
        let textRange = NSMakeRange(0, text.length())
        
        let isOrderedList = orderedListRegularExpression.matches(in: text, options: [], range: textRange).count > 0
        let isUnorderedList = unorderedListRegularExpression.matches(in: text, options: [], range: textRange).count > 0
        
        return isOrderedList || isUnorderedList
    }
    
    class func paragraphListType(_ text: String) -> NotasParagraphType {
        let textRange = NSMakeRange(0, text.length())
        
        let isOrderedList = orderedListRegularExpression.matches(in: text, options: [], range: textRange).count > 0
        if isOrderedList { return .orderedList }
        
        let isUnorderedList = unorderedListRegularExpression.matches(in: text, options: [], range: textRange).count > 0
        if isUnorderedList { return .unorderedList }
        
        return .normal
    }
    
    class func currentParagraph(of string: String, location: Int) -> String {
        return NSString(string: string).substring(with: paragraphRange(of: string, location: location))
    }
    
    class func paragraphRange(of string: String, location: Int) -> NSRange {
        let startLocation = previousInfo(string, location: location).1
        let endLocation = nextInfo(string, location: location).1
        
        return NSMakeRange(startLocation, endLocation - startLocation)
    }

    class func previousInfo(_ string: String, location: Int) -> (String, Int) {
        let nsstring = NSString(string: string)
        let previousContent = nsstring.substring(to: location)

        var startLocation: Int = 0
        var currentLine: String = ""
        
        let previousLines = previousContent.components(separatedBy: "\n")
        if previousLines.count > 0 {
            currentLine = previousLines.last ?? ""
            
            startLocation = previousContent.length() - currentLine.length()
        }
        return (currentLine, startLocation)
    }
    
    class func nextInfo(_ string: String, location: Int) -> (String, Int) {
        let nsstring = NSString(string: string)
        let nextContent = nsstring.substring(from: location) as NSString
        
        var endLocation: Int = 0
        var currentLine: String = ""
        
        let nextLines = nextContent.components(separatedBy: "\n")
        if nextLines.count > 0 {
            currentLine = nextLines.first ?? ""
            
            endLocation = location + currentLine.length()
        }
        return (currentLine, endLocation)
    }
}

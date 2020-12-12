//
//  TextView.swift
//  Notas
//
//  Created by Archy on 2020/11/22.
//

import UIKit

open class Notas: UITextView {
    
    var storage: TextStorage!
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        let notnullContainer = (textContainer == nil) ? NSTextContainer() : textContainer!
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(notnullContainer)
        
        let textStorage = TextStorage()
        textStorage.addLayoutManager(layoutManager)
        
        super.init(frame: frame, textContainer: notnullContainer)
        
        textStorage.textView = self
        storage = textStorage
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Override
    
    // Returns a rectangle to draw the caret at a specified insertion point.
    open override func caretRect(for position: UITextPosition) -> CGRect {
        var originalRect = super.caretRect(for: position)
        originalRect.size.height = (font == nil ? 16: font!.lineHeight) + 2
        return originalRect
    }
        
    open func convertToList(isOrdered: Bool, listPrefix: String) {
        
        var targetText: NSString!
        var targetRange: NSRange!
        
        let currentPreviousInfo = NotasUtil.previousInfo(self.text, location: selectedRange.location)
        let currentFirstStart = currentPreviousInfo.1
        
        if selectedRange.length == 0 {
            targetText = NotasUtil.currentParagraph(of: text, location: selectedRange.location) as NSString
            targetRange = NSRange(location: currentFirstStart, length: targetText.length)
        } else {
            var currentSecondEnd = selectedRange.location + selectedRange.length
            currentSecondEnd = NotasUtil.nextInfo(text, location: currentSecondEnd).1
            targetRange = NSRange(location: currentFirstStart, length: currentSecondEnd - currentFirstStart)
            targetText = (text as NSString).substring(with: targetRange) as NSString
        }
        
        let currentLineRange = NSRange(location: 0, length: targetText.length)
        
        let isOrderedList = NotasUtil.orderedListRegularExpression.matches(in: String(targetText), options: [], range: currentLineRange).count > 0
        let isUnorderedList = NotasUtil.unorderedListRegularExpression.matches(in: String(targetText), options: [], range: currentLineRange).count > 0
        
        let isTransformToList = (isOrdered && !isOrderedList) || (!isOrdered && !isUnorderedList)
        
        var numberedIndex = 1
        var replacedContents: [NSString] = []
        
        targetText.enumerateLines { (line, stop) in
            var currentLine: NSString = line as NSString
            
            if NotasUtil.isListParagraph(line) {
                currentLine = currentLine.substring(from: currentLine.range(of: " ").location + 1) as NSString
            }
            
            if isTransformToList {
                if isOrdered {
                    currentLine = NSString(string: "\(numberedIndex). ").appending(String(currentLine)) as NSString
                    numberedIndex += 1
                } else {
                    currentLine = NSString(string: listPrefix).appending(String(currentLine)) as NSString
                }
            }
            
            replacedContents.append(currentLine)
        }
        
        var replacedContent = NSArray(array: replacedContents).componentsJoined(by: "\n")
        
        if targetText.length == 0 && replacedContent.length() == 0 {
            replacedContent = listPrefix
        }
        
        storage.replaceRange(targetRange, withAttributedString: NSAttributedString(string: replacedContent), oldAttributedString: NSAttributedString(string: String(targetText)), selectedRangeLocationMove: replacedContent.length() - targetText.length)
    }
    
    open func convertToNormal() {
        
        var targetText: NSString!
        var targetRange: NSRange!
        
        let currentPreviousInfo = NotasUtil.previousInfo(self.text, location: selectedRange.location)
        let currentFirstStart = currentPreviousInfo.1

        if selectedRange.length == 0 {
            targetText = NotasUtil.currentParagraph(of: text, location: selectedRange.location) as NSString
            targetRange = NSRange(location: currentFirstStart, length: targetText.length)
        } else {
            var currentSecondEnd = selectedRange.location + selectedRange.length
            currentSecondEnd = NotasUtil.nextInfo(text, location: currentSecondEnd).1
            targetRange = NSRange(location: currentFirstStart, length: currentSecondEnd - currentFirstStart)
            targetText = (text as NSString).substring(with: targetRange) as NSString
        }
        
        var replacedContents: [NSString] = []

        targetText.enumerateLines { (line, stop) in
            var currentLine: NSString = line as NSString
            
            if NotasUtil.isListParagraph(line) {
                currentLine = currentLine.substring(from: currentLine.range(of: " ").location + 1) as NSString
            }
            
            replacedContents.append(currentLine)
        }
        
        let replacedContent = NSArray(array: replacedContents).componentsJoined(by: "\n")
        
        storage.replaceRange(targetRange, withAttributedString: NSAttributedString(string: replacedContent), oldAttributedString: NSAttributedString(string: String(targetText)), selectedRangeLocationMove: replacedContent.length() - targetText.length)
    }
}


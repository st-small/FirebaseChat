//
//  String+Extension.swift
//  FirebaseChat
//
//  Created by Stanly Shiyanovskiy on 14.10.17.
//  Copyright © 2017 Stanly Shiyanovskiy. All rights reserved.
//

import Foundation

extension String {
    
    func checkPhoneNumber(_ textFieldString: String, in range: NSRange, replacement string: String) -> (Bool, String) {
        
        let temp = "+38"
        
        let validationSet = NSCharacterSet.decimalDigits.inverted
        let components = string.components(separatedBy: validationSet)
        
        guard components.count == 1 else { return (false, temp) }
        
        guard var newString = (textFieldString as NSString?)?.replacingCharacters(in: range, with: string) else { return (false, temp) }
        
        let validComponents = newString.components(separatedBy: validationSet)
        newString = validComponents.joined(separator: "")
        
        let areaMaxLength = 5
        let numberMaxLength = 7
        
        if newString.count > (areaMaxLength + numberMaxLength + 8) {
            return (false, temp)
        }
        
        var resultString = ""
        let areaLength = min(newString.count, areaMaxLength)
        
        if areaLength > 0 {
            let start = newString.index(newString.startIndex, offsetBy: 2)
            let end = newString.index(newString.startIndex, offsetBy: areaLength)
            resultString = "\(newString[start..<end])"
            
        }
        
        if newString.count > areaLength {
            let numberLength = min((newString.count - areaMaxLength), numberMaxLength)
            
            let start = newString.index(newString.startIndex, offsetBy: areaLength)
            let end = newString.index(newString.startIndex, offsetBy: areaLength + numberLength)
            let number = "\(newString[start..<end])"
            
            resultString = "\(resultString)\(number)"
        }
        
        resultString.insert(contentsOf: "+38", at: String.Index.init(encodedOffset: 0))
        
        if newString.count > 2 {
            resultString.insert(contentsOf: " (", at: String.Index.init(encodedOffset: 3))
            if newString.count > 5 {
                resultString.insert(contentsOf: ") ", at: String.Index.init(encodedOffset: 8))
                if newString.count > 8 {
                    resultString.insert("-", at: String.Index.init(encodedOffset: 13))
                    if newString.count > 10 {
                        resultString.insert("-", at: String.Index.init(encodedOffset: 16))
                    }
                }
            }
        }
        
        return (false, resultString)
    }
}

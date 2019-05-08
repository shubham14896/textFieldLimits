//
//  ViewController.swift
//  TextField
//
//  Created by Shubham Gupta on 02/05/19.
//  Copyright © 2019 Shubham Gupta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel:  UILabel!
    @IBOutlet weak var txtField:    UITextField!
    @IBOutlet weak var maximumNoLabel: UILabel!
    
    let maximumNumber: Float = 99999.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        txtField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        maximumNoLabel.text = "Maximum Number : \(maximumNumber)"
        errorLabel.isHidden = true
        txtField.text = "0"
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        errorLabel.text = "End"
        
        guard let text = textField.text else {
            return
        }
        
        // Case for matching number with maximum number
        if let textFieldTextToFloat = Float(text), textFieldTextToFloat > maximumNumber {
           errorLabel.text = "Entered value is greater than \(maximumNumber)"
        } else {
           errorLabel.text = "Approved."
        }
    
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        textField.text = ""
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        errorLabel.text = "Changing"
        
        removeCommaFromTextField()
        
        // Case for backspace
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                print("Backspace was pressed.")
                addCommaToTextField()
                return true
            }
        }
        
        guard let text = textField.text else {
            addCommaToTextField()
            return false
        }
        
        // Check for multiple dots
        var dotCount = 0
        for char in text {
            if char == "." {
                dotCount += 1
            }
        }
        
        if dotCount == 1 && string == "." {
            addCommaToTextField()
            return false
        }
        
        let textToFloatDigit = Int(Float(text) ?? 0).digitCount
        // Check for maximum count
        if  textToFloatDigit == Int(maximumNumber).digitCount && string != "." && !text.contains(".") {
            errorLabel.text = "Only \(Int(maximumNumber).digitCount) digits before ."
            addCommaToTextField()
            return false
        }
        
        // Check for value after . must be 2 digits only
        if text.contains(".") {
            
            let numberOfDecimalDigits: Int
            
            if let dotIndex = text.firstIndex(of: ".") {
                numberOfDecimalDigits = text.distance(from: dotIndex, to: text.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }
            
            if numberOfDecimalDigits > 1 {
                print("Only two digits after .")
                errorLabel.text = "Only two digits after ."
                addCommaToTextField()
                return false
            }
            
        }
        
        // Check for first digit i.e 0 or .
        if textField.text?.count == 0 && (string == "0" || string == ".") {
            errorLabel.text = "First place cannot be . or 0."
            addCommaToTextField()
            return false
        }
 
        addCommaToTextField()
        
        return true
    
    }

    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func addCommaToTextField() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            
            guard let text = self.txtField.text else { return }
            
            let chunkedString = text.components(separatedBy: ".")
            
            if chunkedString.count >= 1 {
                let intValue = Int(chunkedString[0])
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                let formattedNumber = numberFormatter.string(from: NSNumber(value:intValue ?? 0))
                self.txtField.text = formattedNumber
            }
            
            if chunkedString.count == 2 {
                
                guard let text = self.txtField.text else { return }
                
                self.txtField.text = "\(text)" + ".\(chunkedString[1])"
            }
            
        }
    }
    
    func removeCommaFromTextField() {
        txtField.text = txtField.text?.replacingOccurrences(of: ",", with: "", options: String.CompareOptions.literal, range: nil)
    }

    
}


public extension Int {
    
    var digitCount: Int {
        get {
            return numberOfDigits(in: self)
        }
    }
    
    private func numberOfDigits(in number: Int) -> Int {
        if number < 10 && number > 0 || number > -10 && number < 0 || number == 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
}

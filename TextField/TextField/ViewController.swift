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
    
    let customArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0"]
    
    let maximumNumber: Float = 2500.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        txtField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        maximumNoLabel.text = "Maximum Number : \(maximumNumber)"
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
        print("Begin")
        errorLabel.text = "Begin"
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        errorLabel.text = "Changing"
        
        // Case for backspace
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                print("Backspace was pressed.")
                return true
            }
        }
        
        guard let text = textField.text else {
            return true
        }
        
        let textToFloatDigit = Int(Float(text) ?? 0).digitCount
        // Check for maximum count
        if  textToFloatDigit == Int(maximumNumber).digitCount && string != "." && !text.contains(".") {
            errorLabel.text = "Only \(Int(maximumNumber).digitCount) digits before ."
            return false
        }
        
        // Check for value after . must be 2 digits only
        if text.contains(".") && customArray.contains(string) {
            
            let numberOfDecimalDigits: Int
            if let dotIndex = text.firstIndex(of: ".") {
                numberOfDecimalDigits = text.distance(from: dotIndex, to: text.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }
            
            if numberOfDecimalDigits <= 1 {
                return true
            } else {
                print("Only two digits after .")
                errorLabel.text = "Only two digits after ."
                return false
            }
        }
        
        
        // Check for first digit i.e 0 or .
        if textField.text?.count == 0 && (string == "0" || string == ".") {
            errorLabel.text = "First place cannot be . or 0."
            return false
        }
        
        // Case for only numbers
        if customArray.contains(string) {
            return true
        } else {
            print("Not Allowed")
            errorLabel.text = "Only number & . allowed."
            return false
        }
    }

    
    @objc func hideKeyboard() {
        view.endEditing(true)
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

//
//  AboutMeViewController.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/9/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import UIKit
import os.log

class AboutMeViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    //MARK: Properties
    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var successfulSaveLabel: UILabel!
    var genders = [String]()
    var genderPicker = UIPickerView()
    var aboutMe = AboutMe(firstName: "", lastName: "", gender: "", age: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genders = ["Male", "Female", "Not Specified"]
        
        // Configure Save Button
        saveButton.isEnabled = false
        
        // Hide Successful Save Label
        successfulSaveLabel.isHidden = true
        
        // Register text field delegates
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        genderTextField.delegate = self
        ageTextField.delegate = self
        
        // Register the view controller as an observer of the text fields
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: Notification.Name.UITextFieldTextDidChange, object: nil)
        
        // Load any saved data
        if let savedAboutMe = loadAboutMe() {
            aboutMe = savedAboutMe
            firstNameTextField.text = aboutMe?.firstName
            lastNameTextField.text = aboutMe?.lastName
            genderTextField.text = aboutMe?.gender
            ageTextField.text = aboutMe?.age
            saveButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            genderTextField.becomeFirstResponder()
        case genderTextField:
            ageTextField.becomeFirstResponder()
        default:
            ageTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case genderTextField:
            createGenderPicker(genderTextField)
            break
        default:
            break
        }
    }
    
    //MARK: UIPickerVIew
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let str = genders[row]
        return NSAttributedString(string: str, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
    }
    
    //MARK: Actions
    @IBAction func saveForm(_ sender: Any) {
        aboutMe = AboutMe(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, gender: genderTextField.text!, age: ageTextField.text!)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(aboutMe!, toFile: AboutMe.ArchiveURL.path)
        if isSuccessfulSave {
            successfulSaveLabel.isHidden = false
            os_log("About me successfully saved", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save about me...", log: OSLog.default, type: .debug)
        }
        
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        genderPicker.resignFirstResponder()
        genderTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
    }
    
    
    //MARK: Private Methods
    @objc private func textDidChange(_ notification: Notification) {
        // Update save button
        saveButton.isEnabled = validate()
        
        // Hide the successful label if it is up and save is disabled
        if (!saveButton.isEnabled) {
            successfulSaveLabel.isHidden = true
        }
    }
    
    func createGenderPicker(_ textField : UITextField){
        
        // UIPickerView
        genderPicker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.backgroundColor = UIColor.lightGray
        genderTextField.inputView = genderPicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AboutMeViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(AboutMeViewController.cancelClick))
        doneButton.tintColor = UIColor.init(red: 3/255, green: 121/255, blue: 0/255, alpha: 1.0)
        cancelButton.tintColor = UIColor.init(red: 3/255, green: 121/255, blue: 0/255, alpha: 1.0)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        genderTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        genderTextField.text = genders[genderPicker.selectedRow(inComponent: 0)]
        genderTextField.resignFirstResponder()
    }
    @objc func cancelClick() {
        genderTextField.text = ""
        genderTextField.resignFirstResponder()
    }
    
    func validate() -> Bool {
        for textField in textFields {
            // Validate Text Field
            if textField.text == nil || (textField.text?.isEmpty)! {
                return false
            }
        }
        
        return true
    }
    
    func loadAboutMe() -> AboutMe? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: AboutMe.ArchiveURL.path) as? AboutMe
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ScoresViewController.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/2/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import UIKit
import os.log

class ScoresViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreSlider: UISlider!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let datePicker = UIDatePicker()
    var coursePicker = UIPickerView()
    var courses = [Course]()
    var score: Score?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        courseNameTextField.delegate = self
        
        if let savedCourses = loadCourses() {
            courses += savedCourses
        }
        
        if let score = score {
            // format date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            navigationItem.title = dateFormatter.string(from: score.date)
            courseNameTextField.text = score.courseName
            scoreLabel.text = String(score.score)
            scoreSlider.value = Float(score.score)
            dateTextField.text = dateFormatter.string(from: score.date)
        }
        else {
            // load default values for score slider
            scoreLabel.text = "72"
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Configure the destination view controller only when the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let courseName = courseNameTextField.text ?? ""
        let scoreValue = Int(scoreSlider.value)
        let date = datePicker.date
        
        // Set the score to be passed to the ScoreTableViewController after the unwind segue
        score = Score(score: scoreValue, courseName: courseName, date: date)
    }
    
    //MARK: UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return courses[row].courseName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        courseNameTextField.text = courses[row].courseName
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let str = courses[row].courseName
        return NSAttributedString(string: str, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
    }
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        createCoursePicker(courseNameTextField)
    }
    
    //MARK: Private Methods
    func createDatePicker() {
        // format for picker
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = UIColor.lightGray
        //datePicker.tintColor = UIColor.white
        datePicker.setValue(UIColor.white, forKey: "textColor")
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // bar button item
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedForDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelPressedForDatePicker))
        doneButton.tintColor = UIColor.init(red: 3/255, green: 121/255, blue: 0/255, alpha: 1.0)
        cancelButton.tintColor = UIColor.init(red: 3/255, green: 121/255, blue: 0/255, alpha: 1.0)
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        dateTextField.inputAccessoryView = toolbar
        
        // assigning date picker to text field
        dateTextField.inputView = datePicker
    }
    
    @objc func donePressedForDatePicker() {
        // format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelPressedForDatePicker() {
        self.view.endEditing(true)
    }
    
    func createCoursePicker(_ textField : UITextField){
        
        // UIPickerView
        coursePicker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        coursePicker.delegate = self
        coursePicker.dataSource = self
        coursePicker.backgroundColor = UIColor.lightGray
        courseNameTextField.inputView = coursePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ScoresViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ScoresViewController.cancelClick))
        doneButton.tintColor = UIColor.init(red: 3/255, green: 121/255, blue: 0/255, alpha: 1.0)
        cancelButton.tintColor = UIColor.init(red: 3/255, green: 121/255, blue: 0/255, alpha: 1.0)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        courseNameTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        courseNameTextField.text = courses[coursePicker.selectedRow(inComponent: 0)].courseName
        courseNameTextField.resignFirstResponder()
    }
    @objc func cancelClick() {
        courseNameTextField.text = ""
        courseNameTextField.resignFirstResponder()
    }
    
    func loadCourses() -> [Course]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Course.ArchiveURL.path) as? [Course]
    }
    
    //MARK: Actions
    @IBAction func scoreSlider(_ sender: UISlider) {
        scoreLabel.text = String(Int(sender.value))
    }
    
}

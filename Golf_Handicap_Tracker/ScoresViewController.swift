//
//  ScoresViewController.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/2/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import UIKit
import os.log

class ScoresViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreSlider: UISlider!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet var myView: UIView!
    
    let datePicker = UIDatePicker()
    var coursePicker = UIPickerView()
    var preselectedCourse = "";
    var preselectedCourseIdentifier = "";
    var courses = [Course]()
    var score: Score?
    var scoreIdentifier = ""
    var courseIdentifier = ""
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the date picker
        createDatePicker()
        
        // Register delegates so input can be recognized
        courseNameTextField.delegate = self
        dateTextField.delegate = self
        imagePicker.delegate = self
        
        // Load in saved courses that can be used in the course picker
        if let savedCourses = loadCourses() {
            courses += savedCourses
        }
        
        // If adding a score from a course, populate the course name with the course that was selected
        if (!preselectedCourse.isEmpty) {
            courseNameTextField.text = preselectedCourse
        }
        
        // If adding a score from a course, populate the identifier with the course that was selected
        if (!preselectedCourseIdentifier.isEmpty) {
            courseIdentifier = preselectedCourseIdentifier
        }
        
        // Populate the score if we have an existing score
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
            datePicker.date = score.date
            photoImageView.image = score.scorecardPhoto
            scoreIdentifier = score.scoreIdentifier
            courseIdentifier = score.courseIdentifier
        }
        else {
            // load default values for score slider
            scoreLabel.text = "72"
            scoreIdentifier = UUID().uuidString
        }
        
        // Configure Save Button to display at the correct time
        let text1 = courseNameTextField.text ?? ""
        let text2 = dateTextField.text ?? ""
        saveButton.isEnabled = !text1.isEmpty && !text2.isEmpty
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
        let photo = photoImageView.image
        var holes = [Hole]()
        for i in 1...18 {
            holes.append(Hole(holeNumber: i, holeStrokes: 0)!)
        }
        
        // Set the score to be passed to the ScoreTableViewController after the unwind segue
        score = Score(score: scoreValue, courseName: courseName, date: date, scorecardPhoto: photo, scoreIdentifier: self.scoreIdentifier, courseIdentifier: self.courseIdentifier, holes: holes)
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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let str = courses[row].courseName
        return NSAttributedString(string: str, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
    }
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        createCoursePicker(courseNameTextField)
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user cancelled
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image
        photoImageView.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
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
    
    // Done was pressed on the date picker, populate the text on the date field and hide the toolbar
    @objc func donePressedForDatePicker() {
        // format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    // Cancel was pressed on the date picker and hide the tool bar
    @objc func cancelPressedForDatePicker() {
        self.view.endEditing(true)
    }
    
    // Puts the available courses into a picker that is then placed inside a toolbar
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
    
    // Done was pressed on the course picker, populate the text field and hide the toolbar
    @objc func doneClick() {
        if (courses.count > 0) {
            courseNameTextField.text = courses[coursePicker.selectedRow(inComponent: 0)].courseName
            courseIdentifier = courses[coursePicker.selectedRow(inComponent: 0)].courseIdentifier
        }
        courseNameTextField.resignFirstResponder()
    }
    
    // Cancel was clicked on the course picker, remove the text from the course name text field and hide the tool bar
    @objc func cancelClick() {
        courseNameTextField.text = ""
        courseNameTextField.resignFirstResponder()
    }
    
    // Load in the list of saved courses to be used in the course picker
    func loadCourses() -> [Course]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Course.ArchiveURL.path) as? [Course]
    }
    
    // Check to see if we have selected both a course and date and then enable the save button
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case courseNameTextField:
            let text1 = courseNameTextField.text ?? ""
            let text2 = dateTextField.text ?? ""
            saveButton.isEnabled = !text1.isEmpty && !text2.isEmpty
        case dateTextField:
            let text1 = courseNameTextField.text ?? ""
            let text2 = dateTextField.text ?? ""
            saveButton.isEnabled = !text1.isEmpty && !text2.isEmpty
        default:
            saveButton.isEnabled = false
        }
        
        if saveButton.isEnabled {
            navigationItem.title = dateTextField.text ?? ""
        }
    }
    
    //MARK: Actions
    @IBAction func scoreSlider(_ sender: UISlider) {
        scoreLabel.text = String(Int(sender.value))
    }
    
    @IBAction func selectScorecardImage(_ sender: Any) {
        // Hide the keyboard
        /*courseNameTextField.resignFirstResponder()
         dateTextField.resignFirstResponder()
         
         // UIImagePickerController is a view controller that lets a user pick media from their photo library
         let imagePickerController = UIImagePickerController()
         
         // Make sure ViewController is notified when the user picks an image
         imagePickerController.delegate = self
         
         present(imagePickerController, animated: true, completion: nil)*/
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            // Opens the camera
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
            {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else
            {
                self.noCamera()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            // Opens the photo gallery
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = myView
            //alert.popoverPresentationController?.sourceRect = myView.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
}


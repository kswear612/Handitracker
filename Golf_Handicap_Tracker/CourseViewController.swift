//
//  CourseViewController.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 12/27/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import UIKit
import os.log

class CourseViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var courseRatingSlider: UISlider!
    @IBOutlet weak var courseSlopeSlider: UISlider!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var courseRatingLabel: UILabel!
    @IBOutlet weak var courseSlopeLabel: UILabel!
    @IBOutlet weak var nineHoleSwitch: UISwitch!
    
    
    var course: Course?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field's user input through delegate callbacks
        courseNameTextField.delegate = self
        
        // Set up views if editing an existing course
        if let course = course {
            navigationItem.title = course.courseName
            courseNameTextField.text = course.courseName
            photoImageView.image = course.photo
            courseRatingSlider.value = Float(course.courseRating)
            courseRatingLabel.text = String(courseRatingSlider.value)
            courseSlopeSlider.value = Float(course.courseSlope)
            courseSlopeLabel.text = String(Int(courseSlopeSlider.value))
            nineHoleSwitch.isOn = course.isNineHoleCourse
        }
        
        // Enable the Save button only if the text field has a valid course name
        //updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing
        //saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   // This method lets you configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Configure the destination view controller only when the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let courseName = courseNameTextField.text ?? ""
        let photo = photoImageView.image
        //let courseRating = Double(courseRatingSlider.value)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        let courseRating = numberFormatter.string(for: courseRatingSlider.value)!
        
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        let courseSlope = numberFormatter.string(for: courseSlopeSlider.value)!
        let isNineHoleCourse = nineHoleSwitch.isOn
        
        // Set the meal to be passed to CourseTableViewController after the unwind segue
        course = Course(courseName: courseName, photo: photo, courseRating: Double(courseRating)!, courseSlope: Int(courseSlope)!, isNineHoleCourse: isNineHoleCourse)
    }
    
    //MARK: Actions
    @IBAction func selectCourseImage(_ sender: Any) {
        // Hide the keyboard
        courseNameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        
        // Make sure ViewController is notified when the user picks an image
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func courseRatingSlider(_ sender: UISlider) {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        
        courseRatingLabel.text = numberFormatter.string(for: sender.value)!
    }
    
    @IBAction func courseSlopeSlider(_ sender: UISlider) {
        courseSlopeLabel.text = String(Int(sender.value))
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty
        let text = courseNameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}

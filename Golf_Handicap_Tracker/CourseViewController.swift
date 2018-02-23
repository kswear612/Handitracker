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
    var courseIdentifier = ""
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field and image picker user input through delegate callbacks
        courseNameTextField.delegate = self
        imagePicker.delegate = self
        
        // Register the view controller as an observer of the text fields so we can enable the save button at the right time
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: Notification.Name.UITextFieldTextDidChange, object: nil)
        
        // Populate data if we have an existing course
        if let course = course {
            navigationItem.title = course.courseName
            courseNameTextField.text = course.courseName
            photoImageView.image = course.photo
            courseRatingSlider.value = Float(course.courseRating)
            courseRatingLabel.text = String(courseRatingSlider.value)
            courseSlopeSlider.value = Float(course.courseSlope)
            courseSlopeLabel.text = String(Int(courseSlopeSlider.value))
            nineHoleSwitch.isOn = course.isNineHoleCourse
            courseIdentifier = course.courseIdentifier
        }
        else {
            courseIdentifier = UUID().uuidString
        }
        
        // Enable the Save button only if the text field has a valid course name
        let text = courseNameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
        
        // Create gesture recognizer that will dismiss the keyboard if the user taps outside the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
        
        // Set the course to be passed to CourseTableViewController after the unwind segue
        course = Course(courseName: courseName, photo: photo, courseRating: Double(courseRating)!, courseSlope: Int(courseSlope)!, isNineHoleCourse: isNineHoleCourse, courseIdentifier: self.courseIdentifier)
    }
    
    //MARK: Actions
    @IBAction func selectCourseImage(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
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
            // Opens the gallery
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
            alert.popoverPresentationController?.sourceView = sender as? UIView
            alert.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
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
    @objc private func textDidChange(_ notification: Notification) {
        // Update save button
        let text = courseNameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
        
        if saveButton.isEnabled {
            navigationItem.title = text
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

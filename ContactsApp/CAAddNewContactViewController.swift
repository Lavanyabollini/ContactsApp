//
//  CAAddNewContactViewController.swift
//  ContactsApp
//
//  Created by Lavanya on 02/07/18.
//  Copyright © 2018 Lavanya. All rights reserved.
//

import UIKit
import CoreData

class CAAddNewContactViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
   
    
    var contactDetails: [NSManagedObject] = []

    @IBOutlet weak var contactDetailScrollView: UIScrollView!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var addContactButton: UIButton!
    var tap : UITapGestureRecognizer?
    var picker:UIPickerView = UIPickerView()
    var countryCodeArray = [String]()

    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    //View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
           firstnameTextField.becomeFirstResponder()
       title = "Add Contact"
        getContryCodeList()
        picker.delegate = self
        picker.dataSource = self
        contactImageView.layer.cornerRadius = contactImageView.frame.size.height / 2

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // add observer to notify when the keyboard opens
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // add observer to notify when the keyboard close
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
       
    }
    
    func getContryCodeList(){
//        var url = NSURL(string: "https://restcountries.eu/rest/v1/all")
//
//        let task = URLSession.sharedSession.dataTaskWithURL(url as! URL) {(data, response, error) in
//            print(NSString(data: data, encoding: NSUTF8StringEncoding))
//        }
//
//        task.resume()
        
        guard let url = URL(string: "https://restcountries.eu/rest/v1/all") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                //here dataResponse received from a network request
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
//                print(jsonResponse) //Response result
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    return
                }
//                print(jsonArray)
                for codes in jsonArray{
                    print(codes["alpha2Code"] as? String ?? "")
                    self.countryCodeArray.append((codes["alpha2Code"] as? String)!)
                }
               
                //Now get title value
                guard let title = jsonArray[0]["alpha2Code"] as? String else { return }
                print(title) // delectus aut autem
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }

    @IBAction func addImage(_ sender: Any) {
        self.editImage()
    }
    
    func editImage() {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction.init(title: "Camera", style: .default) {[unowned self] (_) in
            self.showImagePicker(sourceType: .camera)
        }
        let galleryAction = UIAlertAction.init(title: "Gallery", style: .default) {[unowned self] (_) in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        if sourceType == .photoLibrary {
            CameraHandler.checkPhotoLibraryPermission { (isAccessible) in
                if isAccessible {
                    self.present(imagePicker, animated: true, completion: nil)
                }else{
                    //Gallery not accessible, dispplay alert to user
                    self.showTextAlertMessage(title: "ContactsApp does not have access to your photos. To enable access, tap settings and turn on Photos.", message: "", with: "Cancel", action2Title: "Settings", and: {
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: nil)
                        }
                    })
                }
            }
        } else {
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            contactImageView.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addNewContact(_ sender: Any) {
        guard let appDelegate =
            UIApplication.shared.delegate as? CAAppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "ContactDetails",
                                       in: managedContext)!
        
        let contactInfo = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        contactInfo.setValue(firstnameTextField.text, forKeyPath: "firstName")
        contactInfo.setValue(lastNameTextField.text, forKeyPath: "lastName")
        contactInfo.setValue(emailTextField.text, forKeyPath: "emailId")
        contactInfo.setValue(Int(phoneNumberTextField.text!), forKeyPath: "phoneNumber")
        contactInfo.setValue(countryTextField.text, forKeyPath: "countryCode")
        
        // 4
        do {
            try managedContext.save()
            contactDetails.append(contactInfo)
            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func showTextAlertMessage(title: String, message: String,with action1Title: String, action2Title: String,and block: @escaping(() -> ()))  {
        let alertcontroller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction.init(title: action1Title, style: .default, handler: nil)
        let action2 = UIAlertAction.init(title: action2Title, style: .default) { (_) in
            block()
        }
        alertcontroller.addAction(action1)
        alertcontroller.addAction(action2)
        present(alertcontroller, animated: true, completion: nil)
    }
    
    //MARK:- UITextfield Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 4{
        self.showDatePicker(textField: textField,datePickerMode:.date)
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField == firstnameTextField{
            firstnameTextField.resignFirstResponder()
            lastNameTextField.becomeFirstResponder()
        }else if textField == lastNameTextField{
            lastNameTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        }else if textField == emailTextField{
            emailTextField.resignFirstResponder()
            phoneNumberTextField.becomeFirstResponder()
        }else if textField == phoneNumberTextField{
            phoneNumberTextField.resignFirstResponder()
        }
        return true
    }
    func showDatePicker(textField: UITextField, datePickerMode:UIDatePickerMode){
       
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancelPicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        // add toolbar to textField
        textField.inputAccessoryView = toolbar
        // add datepicker to textField
        textField.inputView = picker
        
    }
    @objc func donePicker(){
   
        //dismiss date picker dialog
        countryTextField.resignFirstResponder()
    }
    
    @objc func cancelPicker(){
        //cancel button dismiss datepicker dialog
        countryTextField.resignFirstResponder()
    }
    
    //MARK:_ UIPickerview delegates
//    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
//        return 1
//    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryCodeArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryCodeArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.countryTextField.text = countryCodeArray[row]
    }
}
extension CAAddNewContactViewController {
    // MARK: Keyboard
    @objc func keyboardWillHide(_ sender: Notification) {
        // remove the gesture to activate tableview selection
        if tap != nil {
            contactDetailScrollView.removeGestureRecognizer(tap!)
            tap = nil
        }
        contactDetailScrollView.contentInset = UIEdgeInsets.zero
        contactDetailScrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        contactDetailScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.height)
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        // add tap gesture to hide keyboard when tap anywhere on the screen
        if tap == nil {
            tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapHideKeyboard(_:)))
            tap!.delegate = self
            contactDetailScrollView.addGestureRecognizer(tap!)
        }
        let userInfo: Dictionary = sender.userInfo! as Dictionary
        let keyBoardInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let keyBoardSize =  keyBoardInfo?.size
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: (keyBoardSize?.height)!, right: 0)
        //set the content size  to scrollview to scroll
        contactDetailScrollView.contentInset = contentInsets
        contactDetailScrollView.scrollIndicatorInsets = contentInsets
        
        var viewRect = self.view.frame
        viewRect.size.height -= keyBoardSize?.height ?? 0
        if !viewRect.contains(self.addContactButton.frame.origin){
            self.contactDetailScrollView.scrollRectToVisible(self.addContactButton.frame, animated: true)
        }
    }
    
    // Handle Tap Guesture used to open the links or Images in other page or controller
    @objc func handleTapHideKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

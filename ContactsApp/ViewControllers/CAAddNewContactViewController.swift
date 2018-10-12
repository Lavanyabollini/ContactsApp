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
    var contactInfo = ContactDetails()
    var isContactInfoExist:Bool = false
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    //View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        firstnameTextField.becomeFirstResponder()
        //Navigation title
        title = "Add Contact"
        //method to get countrycode list
        getContryCodeList()
        picker.delegate = self
        picker.dataSource = self
        if isContactInfoExist{
            addContactButton.setTitle("Update Contact", for: .normal)
            displayContactDetails()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // add observer to notify when the keyboard opens
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // add observer to notify when the keyboard close
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //API for fetching country code
    func getContryCodeList(){
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
    func displayContactDetails(){
        
        if let imageData = contactInfo.value(forKeyPath: "contactImage") as? NSData{
            if let image = UIImage(data:imageData as Data) {
                contactImageView.image =  image
            }
        }else{
            contactImageView.image = UIImage(named:"contactImage")
        }
        firstnameTextField.text =  contactInfo.value(forKeyPath: "firstName") as? String
        lastNameTextField.text =  contactInfo.value(forKeyPath: "lastName") as? String
        emailTextField.text = contactInfo.value(forKeyPath: "emailId")as? String
         phoneNumberTextField.text  = contactInfo.value(forKeyPath: "phoneNumber") as? String
        countryTextField.text = contactInfo.value(forKeyPath: "countryCode")as? String
        
    }
    //MARK:_ IBAction
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
    //MARK:- UIImagepicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            contactImageView.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func addNewContact(_ sender: Any) {
        if !((firstnameTextField.text?.isEmpty)! || (lastNameTextField.text?.isEmpty)!||(emailTextField.text?.isEmpty)! || (phoneNumberTextField.text?.isEmpty)!||(countryTextField.text?.isEmpty)!){
            if self.isValidEmail(testStr: emailTextField.text!) == true{
                if (phoneNumberTextField.text!.isPhoneNumber == true) && (phoneNumberTextField.text!.count == 10){
                    if addContactButton.title(for: .normal) == "Add contact"{
                    self.storeContactDetailsInCoredata()
                    }else{
                        updateContactDetails()
                    }
                }else{
                    self.showTextAlertMessage(title:"ContactsApp", message: "Please enter valid Phone number", with: "Cancel", action2Title: "Ok") {
                        self.phoneNumberTextField.becomeFirstResponder()
                    }
                }
            }else{
                self.showTextAlertMessage(title:"ContactsApp", message: "Please enter valid email Id", with: "Cancel", action2Title: "Ok") {
                    self.emailTextField.becomeFirstResponder()
                }
            }
        }else{
            self.showTextAlertMessage(title: "ContactsApp", message: "Please enter all the fields", with: "Cancel", action2Title: "OK") {
            }
            
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    //    func validatePhoneNumber(value: String) -> Bool {
    //      //  let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
    //        let PHONE_REGEX = "\\A[0-9]{8}\\z"
    //
    //        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
    //        let result =  phoneTest.evaluate(with: value)
    //        return result
    //    }
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
    
    
    func storeContactDetailsInCoredata(){
        
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "ContactDetails",
                                       in: SharedManager.sharedInstance.managedObjectContext())!
        
         let contactInfo = NSManagedObject(entity: entity,
                                      insertInto: SharedManager.sharedInstance.managedObjectContext()) as! ContactDetails
        
        // 3
        contactInfo.setValue(firstnameTextField.text, forKeyPath: "firstName")
        contactInfo.setValue(lastNameTextField.text, forKeyPath: "lastName")
        contactInfo.setValue(emailTextField.text, forKeyPath: "emailId")
        contactInfo.setValue(phoneNumberTextField.text!, forKeyPath: "phoneNumber")
        contactInfo.setValue(countryTextField.text, forKeyPath: "countryCode")
        let imageData =  NSData(data: UIImageJPEGRepresentation(contactImageView.image!, 1.0)!)
        contactInfo.setValue(imageData, forKeyPath: "contactImage")
    
        
        // 4
        do {
            try SharedManager.sharedInstance.managedObjectContext().save()
            contactDetails.append(contactInfo)
            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateContactDetails(){
        contactInfo.firstName = firstnameTextField.text
        contactInfo.lastName = lastNameTextField.text
        contactInfo.emailId = emailTextField.text
        let imageData =  NSData(data: UIImageJPEGRepresentation(contactImageView.image!, 1.0)!)
        contactInfo.contactImage = imageData as Data
        contactInfo.countryCode = countryTextField.text
        contactInfo.phoneNumber = phoneNumberTextField.text
        do {
            try SharedManager.sharedInstance.managedObjectContext().save()
            contactDetails.append(contactInfo)
            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
//        self.navigationController?.popViewController(animated: true)
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
            if self.isValidEmail(testStr: emailTextField.text!) == true{
                emailTextField.resignFirstResponder()
                phoneNumberTextField.becomeFirstResponder()
            }else{
                self.showTextAlertMessage(title:"ContactsApp", message: "Please enter valid email Id", with: "Cancel", action2Title: "Ok") {
                    self.emailTextField.becomeFirstResponder()
                }
            }
        }else if textField == phoneNumberTextField{
            if phoneNumberTextField.text!.isPhoneNumber == true{
                phoneNumberTextField.resignFirstResponder()
            }else{
                self.showTextAlertMessage(title:"ContactsApp", message: "Please enter valid Phone number", with: "Cancel", action2Title: "Ok") {
                    self.phoneNumberTextField.becomeFirstResponder()
                }
            }
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 4{
            return false
        }
        if textField.tag == 3 {
            if textField.text!.count > 9{
                if string == ""{
                    return true
                }else{
                    return false
                }
            }
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

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}

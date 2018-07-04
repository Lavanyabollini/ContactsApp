//
//  CameraHandler.swift
//  theappspace.com
//
//  Created by Dejan Atanasov on 26/06/2017.
//  Copyright © 2017 Dejan Atanasov. All rights reserved.
//

import Foundation
import UIKit
import Photos


class CameraHandler: NSObject{
    static let shared = CameraHandler()
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var imagePickedBlock: ((UIImage) -> Void)?
    var cancelBlock: (() -> Void)?


    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func photoLibrary()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            CameraHandler.checkPhotoLibraryPermission { (isAccessible) in
                if isAccessible {
                    self.currentVC.present(myPickerController, animated: true, completion: nil)
                }else{
                    //Gallery not accessible, dispplay alert to user
//                    self.currentVC.showTextAlertMessage(title: "ACCESS_PHOTOS".localized(), message: "", with: "Cancel", action2Title: "Settings", and: {
//                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
//                            return
//                        }
//                        if UIApplication.shared.canOpenURL(settingsUrl) {
//                            UIApplication.shared.open(settingsUrl, completionHandler: nil)
//                        }
//                    })
                }
            }
        }
    }
    
    func cancel() {
        cancelBlock!()
    }
    
    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert:UIAlertAction!) -> Void in
            self.cancel()
            
        }))
        vc.present(actionSheet, animated: true, completion: nil)
    }
  
    func showTextAlertMessage(title: String, message: String,with action1Title: String, action2Title: String,and block: @escaping(() -> ()))  {
        let alertcontroller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction.init(title: action1Title, style: .default, handler: nil)
        let action2 = UIAlertAction.init(title: action2Title, style: .default) { (_) in
            block()
        }
        alertcontroller.addAction(action1)
        alertcontroller.addAction(action2)
        currentVC.present(alertcontroller, animated: true, completion: nil)
        
}

}
extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
        self.cancel()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickedBlock?(image)
        }else{
            print("Something went wrong")
        }
        currentVC.dismiss(animated: true, completion: nil)
    }
    
}

extension CameraHandler {
    
    static func checkPhotoLibraryPermission( isAccessible: @escaping ((Bool)->())) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            isAccessible(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    isAccessible(true)
                }else{
                    isAccessible(false)
                }
            })
        case .restricted,.denied:
            isAccessible(false)
        }
    }
}

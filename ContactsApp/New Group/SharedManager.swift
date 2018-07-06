//
//  SharedManager.swift
//  ContactsApp
//
//  Created by Lavanya on 06/07/18.
//  Copyright © 2018 Lavanya. All rights reserved.
//

import UIKit
import CoreData

class SharedManager: NSObject {
    
    
    // MARK: - Shared Instance
    
    static let sharedInstance: SharedManager = {
        let instance = SharedManager()
        // setup code
        return instance
    }()
    
    // MARK: - Initialization Method
    
    override init() {
        super.init()
    }
    
    func managedObjectContext()-> NSManagedObjectContext{
        let appDelegate = (UIApplication.shared.delegate as! CAAppDelegate)
        let managedContext = appDelegate.persistentContainer.viewContext
        return managedContext
    }
}



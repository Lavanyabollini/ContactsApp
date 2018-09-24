//
//  CAContactsViewController.swift
//  ContactsApp
//
//  Created by Lavanya on 02/07/18.
//  Copyright © 2018 Lavanya. All rights reserved.
//

import UIKit
import CoreData

class CAContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var contactsListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var contactArray = [ContactDetails](){
        didSet{
            self.contactsListTableView.reloadData()
            self.contactsListTableView.scrollsToTop = true
        }
        
    }
    var contactInformation = [ContactDetails]()

    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      self.fetchDataFromStorage()
    }
    
    func fetchDataFromStorage(){
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "ContactDetails")
        
        do {
            contactInformation = try SharedManager.sharedInstance.managedObjectContext().fetch(fetchRequest) as! [ContactDetails]
            contactArray = contactInformation
            self.contactsListTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK:- UItableview datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:CAContactsListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! CAContactsListTableViewCell
        let personDetails = contactArray[indexPath.row]
        cell.contactName.text =  personDetails.value(forKeyPath: "firstName") as? String
        if let imageData = personDetails.value(forKeyPath: "contactImage") as? NSData{
            if let image = UIImage(data:imageData as Data) {
                 cell.contactImage.image =  image
            }
        }else{
            cell.contactImage.image = UIImage(named:"contactImage")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CAContactsListTableViewCell
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let fetchRequest =
                NSFetchRequest<NSFetchRequestResult>(entityName: "ContactDetails")
//            fetchRequest.predicate = NSPredicate(format: "firstName = %@", "firstName")
            fetchRequest.predicate = //Predicate.init(format: "firstName == \(firstName)")
                NSPredicate(format: "firstName == %@", cell.contactName.text!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest )


//            var details = [ContactDetails]()

            do {
//                details = try SharedManager.sharedInstance.managedObjectContext().fetch(fetchRequest) as! [ContactDetails]
//                for object in details {
//                    SharedManager.sharedInstance.managedObjectContext().delete(object)
//                }
//                try SharedManager.sharedInstance.managedObjectContext().save()
                try SharedManager.sharedInstance.managedObjectContext().execute(deleteRequest)
                try SharedManager.sharedInstance.managedObjectContext().save()
              //  self.contactsListTableView.beginUpdates()
//                self.contactsListTableView.deleteRows(at: [indexPath], with: .automatic)
//                self.contactsListTableView.reloadData()
                self.fetchDataFromStorage()

             //   self.contactsListTableView.endUpdates()
            } catch _ {
                // error handling
                 fatalError("Could not fetch")
            }
            //Reload tableView
            
        }
    }
    //MARK:- IBAction methods
    @IBAction func addContact(_ sender: Any) {
    
    }
    
    //MARK: - SearchBar Delegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            contactArray = contactInformation.filter({ (eachName) -> Bool in
                return (eachName.firstName?.lowercased().contains(searchText.lowercased()))!
            })
        }
        else{
            contactArray = contactInformation
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = false
    }
}


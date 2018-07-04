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
        
        guard let appDelegate =
            UIApplication.shared.delegate as? CAAppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "ContactDetails")

        do {
            contactInformation = try managedContext.fetch(fetchRequest) as! [ContactDetails]
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
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
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


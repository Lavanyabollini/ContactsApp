//
//  CAContactsViewController.swift
//  ContactsApp
//
//  Created by Lavanya on 02/07/18.
//  Copyright © 2018 Lavanya. All rights reserved.
//

import UIKit

class CAContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var contactsListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var contactArray = [String]()
    var names: [String] = []

    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK:- UItableview datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:CAContactsListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! CAContactsListTableViewCell
        cell.contactName.text = names[indexPath.row]
        
        return cell
    }

    //MARK:- IBAction methods
    @IBAction func addContact(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
                                        [unowned self] action in
                                        
                                        guard let textField = alert.textFields?.first,
                                            let nameToSave = textField.text else {
                                                return
                                        }
                                        
                                        self.names.append(nameToSave)
                                        self.contactsListTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
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
//        if searchText != "" {
//            names = contactArray.filter({ (eachName) -> Bool in
//                return (eachName.fileDescription?.lowercased().contains(searchText.lowercased()))!
//            })
//        }
//        else{
//            names = contactArray
//        }
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


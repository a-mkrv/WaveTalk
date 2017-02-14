//
//  ContactListViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 05.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ContactListViewController: UITableViewController, UISearchResultsUpdating {

    var searchController: UISearchController!
    var searchContacts = [Contact]()
    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       
        checkUserIsLoggedIn()
        
        fetchUser()
    }

    
    
    //FIXME: App will crash if class properties don't exactly match up with the firebase dictionary keys
    //FIXME: Change logic of contacts - Now crashes after trying go to detail
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (FIRDataSnapshot) in
    
            if let dictionary = FIRDataSnapshot.value as? [String : Any] {
                let user = Contact()
                print(dictionary)
                user.setValuesForKeys(dictionary)
                self.contacts.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let tableHeaderView = tableView.tableHeaderView {
            tableView.bringSubview(toFront: tableHeaderView)
        }
    }
    
    
    func checkUserIsLoggedIn() {
        if  FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {
                (FIRDataSnapshot) in
                
                print(FIRDataSnapshot)
                
            }, withCancel: nil)
        }
    }
    
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print("LogoutError ", logoutError)
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginBoard")
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    // Scrolling table
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }

    
    // The number of contacts for displaying
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // if the search is active, display the results
        // otherwise all the available contacts
        if searchController.isActive {
            return searchContacts.count
        } else {
            return contacts.count
        }
    }

    
    // Filling cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let contact = (searchController.isActive) ? searchContacts[indexPath.row] : contacts[indexPath.row]
        let CellID = "CellContact"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as! ContactViewCell
        
        //cell.avatarImage?.image = UIImage(named: contact.photoImage!)
        //cell.avatarImage.layer.cornerRadius = 30.0
        //cell.avatarImage.clipsToBounds = true
        cell.usernameLabel?.text = contact.username
        //cell.phonenumberLabel?.text = contact.phoneNumber
        
        return cell
    }
    
    // Able to edit the cell during search
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
    
    
    // Click on the cell - contact selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contactInfo = UIAlertController(title: nil, message: "Что вы хотите сделать?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let callActionHandler = { (action: UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Сервис недоступен", message: "Повторите позже. Недоступно.", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
        
        let callAction = UIAlertAction(title: "Call " + contacts[indexPath.row].phoneNumber!, style: .default, handler: callActionHandler)
        
        
        contactInfo.addAction(cancelAction)
        contactInfo.addAction(callAction)
        
        tableView.deselectRow(at: indexPath, animated: true)
        //self.present(contactInfo, animated: true, completion: nil)
    }
    

    // Styling cell - swipe left [Share, Delete]
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Share contact
        let shareAction = UITableViewRowAction(style: .default, title: "Share", handler: { (action, indexPath) -> Void in
            let defaultText = "Just checking in at + " + self.contacts[indexPath.row].username!
            let activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            
            self.present(activityController, animated: true, completion: nil)
        })
        
        // Delete contact
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) -> Void in
                self.contacts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        shareAction.backgroundColor = UIColor.blue
        deleteAction.backgroundColor = UIColor.gray
        
        return [deleteAction, shareAction]
    }
    
    
    // Opening details of the selected contact
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         if segue.identifier == "showContactDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ContactDetailsViewController
                destinationController.contact = (searchController.isActive) ? searchContacts[indexPath.row] : contacts[indexPath.row]
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = false
    }
    
    
    // Update the table after filtering contacts
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            filterSearchContact(searchText: searchText)
            tableView.reloadData()
        }
    }
    
    
    // Filter to search the contacts
    func filterSearchContact(searchText: String) {
        
        searchContacts = contacts.filter({ (contact: Contact) -> Bool in
            let nameMatch = contact.username?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let phoneMatch = contact.phoneNumber?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            
            return nameMatch != nil || phoneMatch != nil
        })
    }

    
    @IBAction func addContactToList(_ sender: Any) {
        

    }
    // Receive Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

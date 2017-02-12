//
//  ContactListViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 05.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class ContactListViewController: UITableViewController, UISearchResultsUpdating {

    var searchController: UISearchController!
    var searchContacts: [Contact] = []
    var contacts: [Contact] = [
        Contact(userName: "Anton",    lastMessage: "Hello..",    lastPresenceTime: "...",  phoneNumber: "11-11-11", photoImage: "11"),
        Contact(userName: "Ivan",     lastMessage: "Ok, fine!", lastPresenceTime: "...",   phoneNumber: "22-22-22", photoImage: "22"),
        Contact(userName: "Diana",    lastMessage: "Goodbye!",  lastPresenceTime: "...",   phoneNumber: "33-33-33", photoImage: "33"),
        Contact(userName: "Oleg",     lastMessage: "This is the best iOS App", lastPresenceTime: "...", phoneNumber: "44-44-44", photoImage: "44"),
        Contact(userName: "Matvey",   lastMessage: "I will be tomorrow", lastPresenceTime: "...", phoneNumber: "55-55-55", photoImage: "55"),
        Contact(userName: "Sanek",    lastMessage: "Hm...",       lastPresenceTime: "...",  phoneNumber: "66-66-66", photoImage: "66"),
        Contact(userName: "Darya",    lastMessage: "I Love You!", lastPresenceTime: "...",  phoneNumber: "77-77-77", photoImage: "77"),
        Contact(userName: "Nikolay",    lastMessage: "NNGU - VMK", lastPresenceTime: "...",  phoneNumber: "88-88-88", photoImage: "44"),
        Contact(userName: "Mama",    lastMessage: "Wow! Look!", lastPresenceTime: "...",  phoneNumber: "99-99-99", photoImage: "11")
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       // let rightAddBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "+", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.didReceiveMemoryWarning))
        //self.navigationItem.setRightBarButton(rightAddBarButtonItem, animated: true)
        //self.tableView.contentInset = UIEdgeInsetsMake(-32, 0, 0, 0)
        //tableView.setContentOffset(CGPoint.zero, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let tableHeaderView = tableView.tableHeaderView {
            tableView.bringSubview(toFront: tableHeaderView)
        }
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
        
        cell.avatarImage?.image = UIImage(named: contact.photoImage)
        cell.avatarImage.layer.cornerRadius = 30.0
        cell.avatarImage.clipsToBounds = true
        cell.usernameLabel?.text = contact.userName
        cell.phonenumberLabel?.text = contact.phoneNumber
        
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
        
        let callAction = UIAlertAction(title: "Call " + contacts[indexPath.row].phoneNumber, style: .default, handler: callActionHandler)
        
        
        contactInfo.addAction(cancelAction)
        contactInfo.addAction(callAction)
        
        tableView.deselectRow(at: indexPath, animated: true)
        //self.present(contactInfo, animated: true, completion: nil)
    }
    

    // Styling cell - swipe left [Share, Delete]
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Share contact
        let shareAction = UITableViewRowAction(style: .default, title: "Share", handler: { (action, indexPath) -> Void in
            let defaultText = "Just checking in at + " + self.contacts[indexPath.row].userName
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
            let nameMatch = contact.userName.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let phoneMatch = contact.phoneNumber.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            
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

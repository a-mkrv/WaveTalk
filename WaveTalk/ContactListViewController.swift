//
//  ContactListViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 05.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseDatabase

class ContactListViewController: UITableViewController, UISearchResultsUpdating, FindUsersProtocol {
    
    var myProfile = Contact()
    var userName: String?
    var searchController: UISearchController!
    var searchContacts = [Contact]()
    var contacts = [Contact]()
    var log = Logger()
    
    var clientSocket = TCPSocket()
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarVC = self.tabBarController  as! MainUserTabViewController
        clientSocket = tabBarVC.clientSocket
        myProfile = tabBarVC.myProfile
        
        clientSocket.connect()
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        checkUserIsLoggedIn()
    }
    
    
    
    //FIXME: App will crash if class properties don't exactly match up with the firebase dictionary keys
    //FIXME: Change logic of contacts - Now crashes after trying go to detail
    
    func fetchUser(personDates: Bool) {
        
        if (personDates)
        {
            if let response = sendRequest(using: clientSocket) {
                
                var bodyOfResponse: String = ""
                let head = response.getHeadOfResponse(with: &bodyOfResponse)
                
                switch(head) {
                case "FLST":
                    parseResponseData(response: bodyOfResponse)
                    break
                case "NOFL":
                    log.debug(msg: "Friend List is empty" as AnyObject)
                default:
                    log.error(msg: "Auth Error - Bad response" as AnyObject)
                }
            } else {
                log.error(msg: "Auth Error - Bad request" as AnyObject)
            }
        }
    }
    
    
    /// Parse response from server - Users / Keys / Messages. Adding through Client::AddUserChat(...)
    func parseResponseData(response: String) {
        let res = response
        let dataList = res.components(separatedBy: " //s ")
        let keyList = dataList[0].components(separatedBy: " /s ")
        let userList = dataList[1].components(separatedBy: " /s ")
        let presenceStatus = dataList[2].components(separatedBy: " /s ")
        var split: [String]
        
        var userData: [String] = ["", "", "", "", ""]
        // 0 - userName, 
        // 1 - email/phone,
        // 2 - onlineStatus, 
        // 3 - pubKey, 
        // 4 - LiveStatus
        
        for i in 0 ..< userList.count {
            split = keyList[i].components(separatedBy: " _ ")
            userData[0] = split[0] // Set username
            userData[3] = split[1] // Set public key
            
            split = userList[i].components(separatedBy: " _ ")
            // split[1] - sex of person
        
            split = presenceStatus[i].components(separatedBy: " _ ")
            userData[2] = split[1] // Set Online presence status
            userData[1] = split[2] // Set Phone / Email
            userData[4] = split[0] // Set Live status
            
            addUserToContactList(name: userData[0], emailPhone: userData[1], prTime: userData[2], pubFriendKey: userData[3], liveStatus: userData[4])
        }
    }
    
    func addUserToContactList(name: String, emailPhone: String, prTime: String, pubFriendKey: String, liveStatus: String) {
        
        let user = Contact()
        user.username = name
        user.phoneNumber_or_Email = emailPhone
        user.pubKey = pubFriendKey
        user.lastPresenceTime = prTime
        user.status = liveStatus
        
        self.contacts.append(user)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    private func sendRequest(using client: TCPSocket) -> String? {
        if userName != nil {
            
            switch client.client.send(string: "LOAD" + userName!) {
            case .success:
                return client.readResponse()
            case .failure(let error):
                log.error(msg: error as AnyObject)
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let tableHeaderView = tableView.tableHeaderView {
            tableView.bringSubview(toFront: tableHeaderView)
        }
    }
    
    
    func checkUserIsLoggedIn() {
        let signIn = userDefaults.object(forKey: "myUserName") as? String
        
        if signIn == "userIsEmpty" {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            userName = signIn!
            myProfile.username = userName
            
            fetchUser(personDates: true)
        }
        
        //        if  FIRAuth.auth()?.currentUser?.uid == nil {
        //            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        //        } else {
        //            fetchUser()
        //        }
    }
    
    
    func handleLogout() {
        //        do {
        //            try FIRAuth.auth()?.signOut()
        //        } catch let logoutError {
        //            print("LogoutError ", logoutError)
        //        }
        clientSocket.disconnect()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "welcomePage")
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
        
        cell.avatarImage?.image = UIImage(named: "55")
        cell.avatarImage.layer.cornerRadius = 30.0
        cell.avatarImage.clipsToBounds = true
        cell.usernameLabel?.text = contact.username
        cell.phonenumberLabel?.text = contact.phoneNumber_or_Email
        
        
        if let profileImageURL = contact.profileImageURL {
            cell.avatarImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
        }
        
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
        
        let callAction = UIAlertAction(title: "Call " + contacts[indexPath.row].phoneNumber_or_Email!, style: .default, handler: callActionHandler)
        
        
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
        } else if segue.identifier == "addContact" {

            let destinationController = segue.destination as! AddContactViewController
            destinationController.delegate = self
            destinationController.searchSocket = clientSocket
            destinationController.myUserName = userName!
            
            for users in contacts {
                destinationController.existContacts.append(users.username!)
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
            let phoneMatch = contact.phoneNumber_or_Email?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            
            return nameMatch != nil || phoneMatch != nil
        })
    }
    
    
    func addNewContact(contact: Contact) {
        contacts.append(contact)
        self.tableView.reloadData()
    }
    
    
    @IBAction func addContactToList(_ sender: Any) {
        
        
    }
    // Receive Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}





// Use Firebase
//
//        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String : Any] {
//                let user = Contact()
//                user.id = snapshot.key
//
//                user.setValuesForKeys(dictionary)
//                self.contacts.append(user)
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }, withCancel: nil)

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

class ContactListViewController: UITableViewController, UISearchResultsUpdating, UserListProtocol {
    
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
        contacts = tabBarVC.contacts
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        checkUserIsLoggedIn()
        tabBarVC.startReadingQueue(for: clientSocket.client)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = false
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
        var dataList = res.components(separatedBy: " /s ")
        dataList.remove(at: dataList.endIndex - 1)
        
        for i in dataList {
            let user = Contact()
            let dataSet = i.components(separatedBy: " _ ")
            
            user.username = dataSet[0]
            //dataList[1] = //sex of person
            user.pubKey = dataSet[2]
            (dataSet[3] == "YES") ? (user.notifications = true) : (user.notifications = false)
            user.lastPresenceTime = dataSet[4]
            user.phoneNumber_or_Email = dataSet[5]
            user.status = dataSet[6]
            
            self.contacts.append(user)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        
        if signIn == "userIsEmpty" || signIn == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            if let myPrivateKey = userDefaults.object(forKey: "PrivateKeyRSA") as? String {
                myProfile.privateKey = myPrivateKey
            }
            
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
                (self.tabBarController  as! MainUserTabViewController).finishReadingQueue()
                let destinationController = segue.destination as! ContactDetailsViewController
                destinationController.myUserName = userName!
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
    
    
    func updateNotificationState(username: String, state: Bool) {
        for user in contacts {
            if user.username == username {
                user.notifications = state
                break
            }
        }
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

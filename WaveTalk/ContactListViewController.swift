//
//  ContactListViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 05.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class ContactListViewController: UITableViewController {

    var contacts: [Contact] = [
        Contact(userName: "Anton",    lastMessage: "Hello..",    lastPresenceTime: "...",  phoneNumber: "11-11-11", photoImage: "1"),
        Contact(userName: "Ivan",     lastMessage: "Ok, fine!", lastPresenceTime: "...",   phoneNumber: "22-22-22", photoImage: "2"),
        Contact(userName: "Diana",    lastMessage: "Goodbye!",  lastPresenceTime: "...",   phoneNumber: "33-33-33", photoImage: "3"),
        Contact(userName: "Oleg",     lastMessage: "This is the best iOS App", lastPresenceTime: "...", phoneNumber: "44-44-44", photoImage: "4"),
        Contact(userName: "Matvey",   lastMessage: "I will be tomorrow", lastPresenceTime: "...", phoneNumber: "55-55-55", photoImage: "5"),
        Contact(userName: "Sanek",    lastMessage: "Hm...",       lastPresenceTime: "...",  phoneNumber: "66-66-66", photoImage: "6"),
        Contact(userName: "Darya",    lastMessage: "I Love You!", lastPresenceTime: "...",  phoneNumber: "77-77-77", photoImage: "7"),
        Contact(userName: "Nikolay",    lastMessage: "NNGU - VMK", lastPresenceTime: "...",  phoneNumber: "88-88-88", photoImage: "1"),
        Contact(userName: "Mama",    lastMessage: "Wow! Look!", lastPresenceTime: "...",  phoneNumber: "99-99-99", photoImage: "2")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset.top = UIApplication.shared.statusBarFrame.height
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    //override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
    //    return 0
    //}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellID = "CellContact"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as! ContactViewCell
        
        cell.avatarImage?.image = UIImage(named: contacts[indexPath.row].photoImage)
        cell.avatarImage.layer.cornerRadius = 30.0
        cell.avatarImage.clipsToBounds = true
        cell.usernameLabel?.text = contacts[indexPath.row].userName
        cell.presenceLabel?.text = contacts[indexPath.row].lastPresenceTime
        
        return cell
    }
    
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
        
        //self.present(contactInfo, animated: true, completion: nil)
    }
    
    //override var prefersStatusBarHidden: Bool {
    //    return true
    //}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Social
        
        let shareAction = UITableViewRowAction(style: .default, title: "Share", handler: { (action, indexPath) -> Void in
            let defaultText = "Just checking in at + " + self.contacts[indexPath.row].userName
            let activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            
            self.present(activityController, animated: true, completion: nil)
        })
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) -> Void in
                self.contacts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        shareAction.backgroundColor = UIColor.blue
        deleteAction.backgroundColor = UIColor.gray
        
        return [deleteAction, shareAction]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails"
        {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ContactDetailsViewController
                destinationController.contact = contacts[indexPath.row]
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    // Override to support editing the table view.
    //override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //if editingStyle == .delete {
        //    Contacts.remove(at: indexPath.row)
        //
        //    tableView.deleteRows(at: [indexPath], with: .fade)
        //}
        
    //}
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

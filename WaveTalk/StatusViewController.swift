//
//  StatusViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 29.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class StatusViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var statusTableView: UITableView!
    @IBOutlet weak var ownStatusInput: UITextField!
    
    let statusList = ["Available", "Away", "Busy", "Can not talk, Chat Only", "Do Not Disturb", "Offline"]
    var selectedIndex: NSIndexPath?
    var curStatus = ""
    var delegate: ProfileSettingsProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ownStatusInput.delegate = self
        
        let rightAddBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.saveStatus))
        self.navigationItem.setRightBarButton(rightAddBarButtonItem, animated: true)
        
        for (index, el) in statusList.enumerated() {
            if el == curStatus {
                selectedIndex = IndexPath(row: index, section: 0) as NSIndexPath?
                break
            }
        }
        
        if selectedIndex == nil {
            ownStatusInput.text = curStatus
        }
        
        ownStatusInput.setBorderBottom()
        statusTableView.delegate = self
        statusTableView.dataSource = self
    }
    
    
    func saveStatus(sender:UIButton) {
        delegate?.setStatus(newValue: ownStatusInput.text!)
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func changeStatus(_ sender: Any) {
        for (index, el) in statusList.enumerated() {
            if el == ownStatusInput.text {
                selectedIndex = IndexPath(row: index, section: 0) as NSIndexPath?
                break
            } else {
                selectedIndex = nil
            }
        }
        
        statusTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath) as! StatusViewCell
        cell.statusLabel.text = statusList[indexPath.row]
        
        if (selectedIndex == (indexPath as NSIndexPath)) {
            cell.imageState.setImage(UIImage(named: "check.png"),for:UIControlState.normal)
        } else {
            cell.imageState.setImage(UIImage(named: "uncheck.png"),for:UIControlState.normal)
        }
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath as NSIndexPath?
        ownStatusInput.text = statusList[indexPath.row]

        tableView.reloadData()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ownStatusInput.resignFirstResponder()
        
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

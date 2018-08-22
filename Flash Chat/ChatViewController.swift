//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                        UITextFieldDelegate{
    
    //instance variables
    var messages=[Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.dataSource=self
        messageTableView.delegate=self
        messageTextfield.delegate=self
        
        //gesture
        let tapGesture=UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        // Register MessageCell.xib file:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: CustomMessageCell.REUSE_ID)
        configureTableView()
        
        retrieveMessages()
       
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell=tableView.dequeueReusableCell(withIdentifier: CustomMessageCell.REUSE_ID, for: indexPath) as!
            CustomMessageCell
        
        let msgObj=messages[indexPath.row]
        
        cell.messageBody.text=msgObj.messageBody
        var sender=msgObj.sender
        sender=String(sender.split(separator: "@")[0])
        cell.senderUsername.text=sender
        //setup color
        if Auth.auth().currentUser?.email==msgObj.sender {
            //this is you!
            cell.senderUsername.textColor=UIColor.flatWhite()
            cell.messageBackground.backgroundColor=UIColor.flatLime()
        }else{
            cell.messageLeadFromAvatar.constant = -cell.avatarImageView.frame.width+5
            cell.messageTrailToSuperView.constant=32
            
        }
        return cell
    }
    
    func configureTableView(){
        messageTableView.rowHeight=UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight=120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //animate change height of message textfield
        UIView.animate(withDuration: 0.5){
            //set height not to hide the key board
            self.heightConstraint.constant=308
            self.view.layoutIfNeeded()
        }
    }
    //Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField){
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant=50
            self.view.layoutIfNeeded()
        }
    }

    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        //Send the message to Firebase and save it in our database
        messageTextfield.isEnabled=false
        sendButton.isEnabled=false
        
        let messageRef=Database.database().reference().child("Messages")
        
        let messageDict = ["Sender":Auth.auth().currentUser?.email,
                           "MessageBody":messageTextfield.text!]
        //insert new message
        messageRef.childByAutoId().setValue(messageDict){
            (error,reference) in
            if error != nil {
                print(error!)
            }else{
                print("msg sended!")
                //enable user to send msg after finish sent
                self.messageTextfield.isEnabled=true
                self.messageTextfield.text=""
                self.sendButton.isEnabled=true
            }
        }
        
    }
    
    //MARK: the retrieveMessages method here:
    func retrieveMessages(){
        let msgRef=Database.database().reference().child("Messages")
        
        //listening for add child event
        msgRef.observe(.childAdded) { (snapshot) in
            let value = snapshot.value as! Dictionary<String,String>
            
            let msg=value["MessageBody"]!
            let sender=value["Sender"]!
            let message=Message(msg: msg, sender: sender)
            //add message to UI
            self.messages.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
            
            print(msg,sender)
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do{
            try Auth.auth().signOut()
        }catch {
            print("error in sign out")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil else{
            print("No view controller to pop off")
            return
        }
    }

}

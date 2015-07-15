//
//  ConversationTableViewController.swift
//  messages
//
//  Created by lyonwj on 7/15/15.
//  Copyright (c) 2015 lyonwj. All rights reserved.
//

import UIKit

class ConversationTableViewController: UITableViewController {
    
    var messages: [Message] = [Message]()
    var otherUser: String? {
        didSet {
            self.loadConversation()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadConversation()
        
        // use NSTimer to poll for new messages
        let timer = NSTimer(fireDate: NSDate(), interval: 2, target: self, selector: "handleTimer", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    func handleTimer() {
        
        // get messages for user and update UI if we have any new messages
        MessagesAPIClient.getConversation(self.otherUser!, completion: { (messageArray, error) -> Void in
            if let messages = messageArray {
                if messages.count != self.messages.count {
                    self.messages = messages
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func loadConversation() {
        if let otherUser = self.otherUser{
        MessagesAPIClient.getConversation(otherUser, completion: { (messageArray, error) -> Void in
            if let messages = messageArray {
                self.messages = messages
                self.tableView.reloadData()
            }
        })
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! UITableViewCell

        let message: Message = messages[indexPath.row]
        cell.detailTextLabel?.text = message.content
        cell.textLabel?.text = message.sender

        return cell
    }
    
    @IBAction func composeNewMessage(sender: UIBarButtonItem) {
        
        var alert = UIAlertController(title: "Compose New Message", message: "Enter message content below", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Message content here"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            
            MessagesAPIClient.postNewMessage(UserSession.user, receiver: self.otherUser!, content: textField.text, completion: { (_, _) -> Void in
                self.loadConversation()
            })
            
        }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

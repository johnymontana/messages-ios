//
//  ThreadsTableViewController.swift
//  messages
//
//  Created by lyonwj on 7/15/15.
//  Copyright (c) 2015 lyonwj. All rights reserved.
//

import UIKit

class ThreadsTableViewController: UITableViewController {
    
    var threads: [Thread] = [Thread]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadThreads()
        
        // use NSTimer to poll for new Threads
        let timer = NSTimer(fireDate: NSDate(), interval: 2, target: self, selector: "handleTimer", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)

    }
    
    func handleTimer() {
        // get Threads and update UI if we have any new Threads
        MessagesAPIClient.getThreads { (threadArray, error) -> Void in
            if let threads = threadArray {
                if threads.count != self.threads.count {
                    self.threads = threads
                    self.tableView.reloadData()
                        self.showNewThreadAlert()
                } else {
                    for (i, e: Thread) in enumerate(threads) {
                        if (e.count != self.threads[i].count) {
                            self.threads = threads
                            self.tableView.reloadData()
                            if e.user != UserSession.user {
                                self.showNewMessageAlert(e.user)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showNewMessageAlert(user: String) {
        
        var alert = UIAlertController(title: "New Message!", message: "New message in conversation with \(user)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showNewThreadAlert() {
        
        var alert = UIAlertController(title: "New Thread!", message: "You have a message from a new user", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadThreads()
    }

    func loadThreads() {
        MessagesAPIClient.getThreads { (threadArray, error) -> Void in
            if let threads = threadArray {
                self.threads = threads
                println("set threads \(threads.count)")
                self.tableView.reloadData()
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("threadCell", forIndexPath: indexPath) as! UITableViewCell

        let thread = threads[indexPath.row]
        
        cell.textLabel!.text = thread.user
        cell.detailTextLabel!.text = "Messages: \(thread.count)"
        

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showConversation", sender: self.threads[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // FIXME: better error handling here and check for segue id
        let dvc = segue.destinationViewController as? ConversationTableViewController
        if let thread = sender as? Thread {
            dvc!.otherUser = thread.user
        }
    }

    @IBAction func newThread(sender: UIBarButtonItem) {
        var alert = UIAlertController(title: "Compose New Message", message: "Enter message content below", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Enter user name here"
        })
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Message content here"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let userTextField = alert.textFields![0] as! UITextField
            let messageTextField = alert.textFields![1] as! UITextField
            
            MessagesAPIClient.postNewMessage(UserSession.user, receiver: userTextField.text, content: messageTextField.text, completion: { (_, _) -> Void in
                self.loadThreads()
            })
            
        }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)

        
    }
    

}

//
//  Message.swift
//  messages
//
//  Created by lyonwj on 7/14/15.
//  Copyright (c) 2015 lyonwj. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Message {
    let content: String
    let sender: String
    let receiver: String
    
    public init(json:JSON) {
        content = json["content"].stringValue
        sender = json["sender"].stringValue
        receiver = json["sender"].stringValue
    }
    
    class func parseMessages(json: JSON) -> Array<Message> {
        var messages: Array<Message> = [Message]()
        
        if let jsonArray: Array<JSON> = json["messages"].array {
            for item in jsonArray {
                messages.append(Message(json:item))
            }
        }
        
        return messages
    }
}

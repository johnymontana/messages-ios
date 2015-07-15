//
//  Thread.swift
//  messages
//
//  Created by lyonwj on 7/14/15.
//  Copyright (c) 2015 lyonwj. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Thread {
    let user: String
    let count: Int
    
    public init(json: JSON) {
        user = json["username"].stringValue
        count = json["count"].int!
    }
    
    class func parseThreads(json:JSON) -> Array<Thread> {
        var threads: Array<Thread> = [Thread]()
        
        if let jsonArray: Array<JSON> = json["threads"].array {
            for item in jsonArray {
                threads.append(Thread(json:item))
            }
        }
        
        return threads
    }
}

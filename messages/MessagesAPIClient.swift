//
//  MessagesAPIClient.swift
//  messages
//
//  Created by lyonwj on 7/14/15.
//  Copyright (c) 2015 lyonwj. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// all API constants here
struct APIConstants {
    static let baseURL = "http://messages-api.herokuapp.com/"
    static let APIUsername = "yo"
    static let APIPasswd = "dawg"
}

let plainString = "\(APIConstants.APIUsername):\(APIConstants.APIPasswd)"
let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))


enum APIRouter: URLRequestConvertible {
    case NewMessage(String, String, String)
    case GetThreads(String)
    case GetConversation(String, String)
    
    var method: Alamofire.Method {
        switch self {
        case .NewMessage:
            return .POST
        case .GetThreads:
            return .GET
        case .GetConversation:
            return .GET
        default:
            return .GET
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]) = {
            switch self {
            case .NewMessage(let sender, let receiver, let content):
                var params = [
                    "sender": sender,
                    "receiver": receiver,
                    "content": content
                ]
                return ("message", params)
            case .GetThreads(let user):
                var params = [String: AnyObject]()
                return ("\(user)/conversations", params)
            case .GetConversation(let user, let otherUser):
                var params = [String: AnyObject]()
                return ("\(user)/conversations/\(otherUser)", params)
                
            }
        }()
        
        let URL = NSURL(string: APIConstants.baseURL)
        let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        URLRequest.HTTPMethod = method.rawValue
        
        
        var encoding: ParameterEncoding {
            switch self {
            case .NewMessage:
                return .JSON
            case .GetThreads:
                return .URL
            case .GetConversation:
                return .URL
            default:
                return .URL
            }

            
        }
        
        //let encoding: ParameterEncoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(URLRequest, parameters: parameters).0
    }
}

public class MessagesAPIClient {
    
    // post a new message for the current user
    public class func postNewMessage(sender: String, receiver: String, content: String, completion: (Bool?, NSError?) -> Void) {
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Basic " + base64String!]
        Alamofire.request(APIRouter.NewMessage(sender, receiver, content)).responseJSON{ (request, response, json, error) -> Void in
            //println(json)
            if json != nil {
                completion(true, nil)
                // FIXME: error handling here
            }
        }
    }
    
    // get all threads for the current user
    public class func getThreads(completion: ([Thread]?, NSError?) -> Void) {
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Basic " + base64String!]
        Alamofire.request(APIRouter.GetThreads(UserSession.user)).responseJSON{(request, response, json, error) -> Void in
            //println(json)
            if json != nil {
                let json: JSON = JSON(json!)
                completion(Thread.parseThreads(json), nil)
            }
        }
        
        
    }
    
    // get a specific thread for a pair of users
    public class func getConversation(otherUser: String, completion: ([Message]?, NSError?) -> Void) {
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Basic " + base64String!]
        Alamofire.request(APIRouter.GetConversation(UserSession.user, otherUser)).responseJSON{
            (request, response, json, error) -> Void in
            //println(json)
            if json != nil {
                let json: JSON = JSON(json!)
                completion(Message.parseMessages(json), nil)
            }
        }
        
    }
}


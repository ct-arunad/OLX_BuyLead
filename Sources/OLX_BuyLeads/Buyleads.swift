//
//  Buyleads.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 25/03/25.
//

import Foundation
import CoreData

@objc public protocol HostAppToSDKDelegate {
    func receiveDataFromSDKToFramework(accesstoken : String, userid : String,refreshtoken : String)
    func navigateToHostApp(item: [String:Any])
}
public class MyPodManager {
    public static var userinfo = [String:Any]()
    public static var access_token = ""
    public static var user_id = ""
    public static var refresh_token = ""

    public static var delegate: HostAppToSDKDelegate?
    public static func requestDataFromHost(accesstoken : String, userid : String,refreshtoken : String) {
      //  self.userinfo = userinfo
        self.access_token = accesstoken
        self.user_id = userid
        self.refresh_token = refreshtoken
        delegate?.receiveDataFromSDKToFramework(accesstoken: accesstoken, userid: userid,refreshtoken: refreshtoken)
    }
    public static func navigatetoHost(userinfo : [String:Any]) {
        delegate?.navigateToHostApp(item: userinfo)
    }
}




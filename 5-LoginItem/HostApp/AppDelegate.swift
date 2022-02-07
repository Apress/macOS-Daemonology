//
//  AppDelegate.swift
//  HostApp
//
//  Created by Alkenso (Vladimir Vashurkin) on 14.05.2021.
//

import Cocoa
import ServiceManagement


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let teamID = String(cString: DAEDevelopmentTeam)
        let identifier = "\(teamID).com.daemonology.DemoLoginItem"
        let success = SMLoginItemSetEnabled(identifier as CFString, true)
        guard success else {
            print("SMLoginItemSetEnabled fails.")
            return
        }
        
        let connection = NSXPCConnection(machServiceName: identifier, options: [])
        connection.remoteObjectInterface = NSXPCInterface(with: DAELoginItemProtocol.self)
        connection.resume()
         
        let proxy = connection.remoteObjectProxyWithErrorHandler { error in
            print("XPC call error: \(error).")
        } as! DAELoginItemProtocol
        proxy.retrieveVersion { loginItemVersion in
            print("LoginItem version: \(loginItemVersion).")
        }
    }
}


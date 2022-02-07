//
//  AppDelegate.swift
//  DemoLoginItem
//
//  Created by Alkenso (Vladimir Vashurkin) on 14.05.2021.
//

import Cocoa


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var listener: NSXPCListener!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            fatalError("Failed to get self Bundle Identifier.")
        }
        listener = NSXPCListener(machServiceName: bundleID)
        listener.delegate = self
        listener.resume()
    }
}

extension AppDelegate: NSXPCListenerDelegate {
    func listener(
        _ listener: NSXPCListener,
        shouldAcceptNewConnection newConnection: NSXPCConnection
    ) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: DAELoginItemProtocol.self)
        newConnection.exportedObject = self // because 'self' conforms to DAELoginItemProtocol
        newConnection.resume()
        return true
    }
}

extension AppDelegate: DAELoginItemProtocol {
    func retrieveVersion(reply: @escaping (String) -> Void) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        reply(version ?? "Unknown")
    }
}

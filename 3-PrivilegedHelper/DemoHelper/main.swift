//
//  main.swift
//  com.daemonology.DemoHelper
//
//  Created by Alkenso (Vladimir Vashurkin) on 21.04.2021.
//

import Foundation


class Helper: NSObject { }

extension Helper: DAEPrivilegedOperations {
    func installPackage(_ package: URL, completion: DAEInstallPackageCompletion) {
        NSLog("Installing the package \(package)")
        completion(true)
    }
}

extension Helper: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: DAEPrivilegedOperations.self)
        newConnection.exportedObject = self
        newConnection.resume()
        return true
    }
}


let helper = Helper()
let listener = NSXPCListener(machServiceName: kPrivilegedHelperMachName)
listener.delegate = helper
listener.resume()

RunLoop.main.run()

//
//  AppDelegate.swift
//  HostApp
//
//  Created by Alkenso (Vladimir Vashurkin) on 21.04.2021.
//

import Cocoa
import ServiceManagement

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let authorization = askAuthorization() else {
            showMessage("Failed to get authorization.")
            return
        }
        
        guard blessHelper(label: kPrivilegedHelperLabel, authorization: authorization) else {
            showMessage("Failed to bless \(kPrivilegedHelperLabel).")
            return
        }
        
        let connection = NSXPCConnection(machServiceName: kPrivilegedHelperMachName, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: DAEPrivilegedOperations.self)
        
        connection.resume()
        
        let remoteProxy = connection.remoteObjectProxyWithErrorHandler { (error) in
            DispatchQueue.main.async { NSAlert(error: error).runModal() }
        }
        
        guard let privilegedOps = remoteProxy as? DAEPrivilegedOperations else {
            showMessage("Invalid connection setup.")
            return
        }
        
        privilegedOps.installPackage(URL(fileURLWithPath: "/path/to/package.pkg")) { installed in
            DispatchQueue.main.async {
                showMessage("Helper installed the package = \(installed)")
            }
        }
    }
}

private func showMessage(_ msg: Any) {
    DispatchQueue.main.async {
        let error = NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(msg)"])
        NSAlert(error: error).runModal()
    }
}

private func askAuthorization() -> AuthorizationRef? {
    var rightItems = [AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)]
    var rights = AuthorizationRights(count: UInt32(rightItems.count), items: &rightItems)

    var auth: AuthorizationRef?
    let status: OSStatus = AuthorizationCreate(&rights, nil, [.extendRights, .interactionAllowed, .preAuthorize], &auth)
    guard status == errAuthorizationSuccess else {
        NSLog("[SMJBS]: Authorization failed with status code \(status)")
        return nil
    }
    
    return auth
}

private func blessHelper(label: String, authorization: AuthorizationRef) -> Bool {
    var error: Unmanaged<CFError>?
    let blessStatus = SMJobBless(kSMDomainSystemLaunchd, label as CFString, authorization, &error)
    
    if !blessStatus {
        NSLog("[SMJBS]: Helper bless failed with error \(error!.takeUnretainedValue())")
    }
    
    return blessStatus
}

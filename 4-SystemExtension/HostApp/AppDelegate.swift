//
//  AppDelegate.swift
//  HostApp
//
//  Created by Alkenso (Vladimir Vashurkin) on 05.05.2021.
//

import Cocoa
import SwiftUI
import SystemExtensions


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var requests: [OSSystemExtensionRequest: (Error?) -> Void] = [:]
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(activate: activate, deactivate: deactivate, ping: ping)
        
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }
}

extension AppDelegate: OSSystemExtensionRequestDelegate {
    func activate(_ completion: @escaping (Error?) -> Void) {
        let request = OSSystemExtensionRequest.activationRequest(
            forExtensionWithIdentifier: kSEXTBundleID,
            queue: .main
        )
        request.delegate = self
        requests[request] = completion
        OSSystemExtensionManager.shared.submitRequest(request)
    }
    
    func deactivate(_ completion: @escaping (Error?) -> Void) {
        let request = OSSystemExtensionRequest.deactivationRequest(
            forExtensionWithIdentifier: kSEXTBundleID,
            queue: .main
        )
        request.delegate = self
        requests[request] = completion
        OSSystemExtensionManager.shared.submitRequest(request)
    }
    
    func request(
        _ request: OSSystemExtensionRequest,
        actionForReplacingExtension existing: OSSystemExtensionProperties,
        withExtension ext: OSSystemExtensionProperties
    ) -> OSSystemExtensionRequest.ReplacementAction {
        NSLog("\(#function): existing = \(existing), new = \(ext)")
        
        return .replace
    }
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        NSLog("\(#function)")
    }
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        NSLog("\(#function): result = \(result)")
        let completion = requests.removeValue(forKey: request)
        completion?(nil)
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        NSLog("\(#function): error = \(error)")
        let completion = requests.removeValue(forKey: request)
        completion?(error)
    }
}

extension AppDelegate {
    func ping(_ completion: @escaping (Result<(pid_t, String), Error>) -> Void) {
        let connection = NSXPCConnection(machServiceName: GetSEXTMachName(), options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: DAESEXTOperations.self)
        connection.resume()
        
        let proxy = connection.remoteObjectProxyWithErrorHandler { error in
            completion(.failure(error))
        } as! DAESEXTOperations
        
        proxy.ping { pid, version in
            completion(.success((pid, version)))
        }
    }
}

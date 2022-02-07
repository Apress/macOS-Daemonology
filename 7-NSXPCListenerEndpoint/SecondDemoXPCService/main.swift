//
//  main.swift
//  SecondDemoXPCService
//
//  Created by Alkenso (Vladimir Vashurkin) on 10.06.2021.
//

import Foundation
import SharedSupport


class SecureStore: NSObject, DemoXPCSecureStore {
    func retrievePassword(for email: String, reply: @escaping (String) -> Void) {
        let password = email.starts(with: "weak") ? "123" : "strongpassword!@#"
        reply(password)
    }
}

class Service: NSObject {
    private let serviceListener: NSXPCListener = .service()
    private let anonymousListener: NSXPCListener = .anonymous()
    
    func activate() {
        anonymousListener.delegate = self
        anonymousListener.resume()
        
        serviceListener.delegate = self
        //  Call to NSXPCListener.serviceListener MUST be the last thing in the program
        //  because it block forever (see documentation).
        serviceListener.resume()
    }
}

extension Service: DemoXPCSecureStoreProvider {
    func retrieveStoreEndpoint(reply: @escaping (NSXPCListenerEndpoint) -> Void) {
        reply(anonymousListener.endpoint)
    }
}

extension Service: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        if listener === serviceListener {
            newConnection.exportedObject = self
            newConnection.exportedInterface = NSXPCInterface(with: DemoXPCSecureStoreProvider.self)
        } else if listener == anonymousListener {
            newConnection.exportedObject = SecureStore()
            newConnection.exportedInterface = NSXPCInterface(with: DemoXPCSecureStore.self)
        } else {
            return false
        }
        
        newConnection.resume()
        
        return true
    }
}


let service = Service()
service.activate()

//
//  main.swift
//  DemoXPCService
//
//  Created by Alkenso (Vladimir Vashurkin) on 10.06.2021.
//

import Foundation
import SharedSupport


class Service: NSObject {
    private var secureStoreConnection: NSXPCConnection?
}

extension Service: DemoXPCService {
    func setup(storeEndpoint: NSXPCListenerEndpoint) {
        secureStoreConnection = NSXPCConnection(listenerEndpoint: storeEndpoint)
        secureStoreConnection?.remoteObjectInterface = NSXPCInterface(with: DemoXPCSecureStore.self)
        secureStoreConnection?.resume()
    }
    
    func checkPasswordWeak(email: String, reply: @escaping (Bool) -> Void) {
        guard let connection = secureStoreConnection else {
            assertionFailure("Connection must exist due to calling this method.")
            reply(true)
            return
        }
        
        let proxy = connection.remoteObjectProxyWithErrorHandler { error in
            print("XPC error occurred: \(error).")
            reply(true)
        } as! DemoXPCSecureStore
        
        
        proxy.retrievePassword(for: email) { password in
            let isWeak = password.count < 8
            reply(isWeak)
        }
    }
}

extension Service: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedObject = self
        newConnection.exportedInterface = NSXPCInterface(with: DemoXPCService.self)
        newConnection.resume()
        
        return true
    }
}


let listener = NSXPCListener.service()
let service = Service()
listener.delegate = service

listener.resume()

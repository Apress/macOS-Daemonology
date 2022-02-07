//
//  main.swift
//  SEXTDemo
//
//  Created by Alkenso (Vladimir Vashurkin) on 05.05.2021.
//

import Foundation


class Service: NSObject {
    private let listener = NSXPCListener(machServiceName: GetSEXTMachName())
    
    func activate() {
        listener.delegate = self
        listener.resume()
    }
}

extension Service: DAESEXTOperations {
    func ping(reply: @escaping DAEPingReply) {
        NSLog("SEXT ping")
        reply(getpid(), Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "<unknown>")
    }
}

extension Service: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: DAESEXTOperations.self)
        newConnection.exportedObject = self
        newConnection.resume()
        return true
    }
}


NSLog("SEXT started!")

let service = Service()
service.activate()

dispatchMain()

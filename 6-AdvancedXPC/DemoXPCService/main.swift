//
//  main.swift
//  DemoXPCService
//
//  Created by Alkenso (Vladimir Vashurkin) on 27.05.2021.
//

import Foundation
import SharedSupport


class TheService: NSObject, DemoXPCService {
    func verify(_ credentials: Credentials, at endpoints: [Endpoint], reply: @escaping ([Endpoint]) -> Void) {
        // demo will accept all endpoints with port > 1024
        print("[TheService] Verifying credentials: \(credentials).")
        
        let accepted = endpoints.filter { $0.port > 1024 }
        print("[TheService] Acceting endpoints: \(accepted).")
        
        reply(accepted)
    }
    
    func upload(resource: String, completion: @escaping () -> Void) -> Progress {
        let parts = 5
        let progress = Progress(totalUnitCount: Int64(parts))
        
        DispatchQueue.global().async {
            for _ in 0..<parts {
                sleep(1)
                progress.completedUnitCount += 1
            }
            completion()
        }
        
        return progress
    }
    
    func download(resource: String, delegate: DownloadDelegate) {
        let parts = 5
        DispatchQueue.global().async {
            delegate.downloadDidStart()
            for i in 1...parts {
                sleep(1)
                delegate.downloadDidUpdateProgress(downloaded: i, total: parts)
            }
            delegate.downloadDidFinish(error: nil)
        }
    }
}

extension TheService: NSXPCListenerDelegate {
    func listener(
        _ listener: NSXPCListener,
        shouldAcceptNewConnection newConnection: NSXPCConnection
    ) -> Bool {
        newConnection.exportedObject = self
        newConnection.exportedInterface = .demoXPCService
        newConnection.resume()
        
        return true
    }
}


let service = TheService()
let listener = NSXPCListener.service()
listener.delegate = service
listener.resume()

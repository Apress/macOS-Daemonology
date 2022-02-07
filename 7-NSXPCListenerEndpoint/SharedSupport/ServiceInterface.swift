//
//  ServiceInterface.swift
//  SharedSupport
//
//  Created by Alkenso (Vladimir Vashurkin) on 27.05.2021.
//

import Foundation


// MARK: - DemoXPCService

@objc(DAEDemoXPCService)
public protocol DemoXPCService {
    func setup(storeEndpoint: NSXPCListenerEndpoint)
    
    func checkPasswordWeak(
        email: String,
        reply: @escaping (Bool) -> Void
    )
}


// MARK: - SecondDemoXPCService

@objc(DAEDemoXPCSecureStore)
public protocol DemoXPCSecureStore {
    func retrievePassword(for email: String, reply: @escaping (String) -> Void)
}

@objc(DAEDemoXPCSecureStoreProvider)
public protocol DemoXPCSecureStoreProvider {
    func retrieveStoreEndpoint(reply: @escaping (NSXPCListenerEndpoint) -> Void)
}

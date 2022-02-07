//
//  ContentView.swift
//  HostApp
//
//  Created by Alkenso (Vladimir Vashurkin) on 27.05.2021.
//

import SwiftUI
import SharedSupport


struct ContentView: View {
    @State var email: String = ""
    @State var isPasswordWeak: String = " "
    @State var passwordCheckConnection: NSXPCConnection?
    @State var secureStoreConnection: NSXPCConnection?
    
    var body: some View {
        HStack {
            VStack {
                Button("Setup", action: setup)
                .disabled(passwordCheckConnection != nil)
                
                Button("Check") {
                    checkPassword(for: email) { isPasswordWeak = $0 }
                }
                .disabled(passwordCheckConnection == nil)
            }
            VStack {
                TextField("Email", text: $email)
                Text(isPasswordWeak)
            }
            .frame(width: 150)
            .disabled(passwordCheckConnection == nil)
        }
        .padding()
    }
    
    private func setup() {
        retrieveEndpoint { endpoint in
            setupPasswordChecker(with: endpoint)
        }
    }
    
    private func checkPassword(for email: String, reply: @escaping (String) -> Void) {
        guard let connection = passwordCheckConnection else { return }
        let proxy = connection.remoteObjectProxy as! DemoXPCService
        proxy.checkPasswordWeak(email: email) { isWeak in
            let isPasswordWeak = "Pwd is \(isWeak ? "Weak!!1" : "Strong ^^")"
            reply(isPasswordWeak)
        }
    }
    
    private func retrieveEndpoint(_ reply: @escaping (NSXPCListenerEndpoint) -> Void) {
        secureStoreConnection = .init(serviceName: "com.daemonology.SecondDemoXPCService")
        secureStoreConnection?.remoteObjectInterface = NSXPCInterface(with: DemoXPCSecureStoreProvider.self)
        secureStoreConnection?.resume()
        
        let proxy = secureStoreConnection?.remoteObjectProxyWithErrorHandler { error in
            print("XPC error: \(error).")
        } as! DemoXPCSecureStoreProvider
        proxy.retrieveStoreEndpoint(reply: reply)
    }
    
    private func setupPasswordChecker(with endpoint: NSXPCListenerEndpoint) {
        passwordCheckConnection = .init(serviceName: "com.daemonology.DemoXPCService")
        passwordCheckConnection?.remoteObjectInterface = NSXPCInterface(with: DemoXPCService.self)
        passwordCheckConnection?.resume()
        
        let proxy = passwordCheckConnection?.remoteObjectProxy as! DemoXPCService
        proxy.setup(storeEndpoint: endpoint)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

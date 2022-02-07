//
//  ContentView.swift
//  HostApp
//
//  Created by Alkenso (Vladimir Vashurkin) on 27.05.2021.
//

import SharedSupport
import SwiftUI


struct ContentView: View {
    @State private var output: [String] = []
    @State private var inProgress: Bool = false
    @State private var observation: Any?
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Button("Verify", action: verify)
                Button("Upload", action: upload)
                Button("Download", action: download)
            }
            .disabled(inProgress)
            ScrollView {
                ScrollViewReader { scrollProxy in
                    ForEach(0..<output.count, id: \.self) { i in
                        Text(output[i])
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .onChange(of: output.count) { _ in
                        scrollProxy.scrollTo(output.count - 1)
                    }
                }
            }
            .frame(width: 250, height: 80, alignment: .topLeading)
        }
        .padding()
    }
    
    private func verify() {
        output = []
        inProgress = true
        
        let proxy = connection.remoteObjectProxyWithErrorHandler { error in
            output = [error.localizedDescription]
            inProgress = false
        }
        guard let service = proxy as? DemoXPCService else {
            output = ["[Fatal] Invalid XPC object proxy type."]
            inProgress = false
            return
        }
        
        service.verify(
            Credentials(email: "test@mail.com", serialNumber: 100500),
            at: [
                Endpoint(ip: "127.0.0.1", port: 500),
                Endpoint(ip: "localhost", port: 1000),
                Endpoint(ip: "daemonology.local", port: 1500),
                Endpoint(ip: "please.local", port: 7777),
            ],
            reply: { acceptedEndpoints in
                output = acceptedEndpoints.map { "\($0.ip):\($0.port)" }
                inProgress = false
            }
        )
    }
    
    private func upload() {
        output = []
        inProgress = true
        
        let proxy = connection.remoteObjectProxyWithErrorHandler { error in
            output = [error.localizedDescription]
            inProgress = false
        }
        guard let service = proxy as? DemoXPCService else {
            output = ["[Fatal] Invalid XPC object proxy type."]
            inProgress = false
            return
        }
        
        let progress = service.upload(resource: "Daemonology.book") {
            output.append("Upload completed")
            inProgress = false
        }
        observation = progress.observe(\.completedUnitCount) { p, _ in
            output.append("\(p.completedUnitCount) of \(p.totalUnitCount)")
        }
    }
    
    private func download() {
        output = []
        inProgress = true
        
        let proxy = connection.remoteObjectProxyWithErrorHandler { error in
            output = [error.localizedDescription]
            inProgress = false
        }
        guard let service = proxy as? DemoXPCService else {
            output = ["[Fatal] Invalid XPC object proxy type."]
            inProgress = false
            return
        }
        
        let delegate = Delegate()
        delegate.progressHandler = { output.append($0) }
        delegate.completionHandler = {
            $0.flatMap{ output.append($0.localizedDescription) }
            inProgress = false
        }
        service.download(resource: "Daemonology.book", delegate: delegate)
    }
    
    private var connection: NSXPCConnection {
        let connection = NSXPCConnection(serviceName: "com.daemonology.DemoXPCService")
        connection.remoteObjectInterface = .demoXPCService
        connection.resume()
        
        return connection
    }
}

private class Delegate: NSObject, DownloadDelegate {
    var progressHandler: ((String) -> Void)?
    var completionHandler: ((Error?) -> Void)?
    
    
    func downloadDidStart() {
        progressHandler?("Download started")
    }
    
    func downloadDidUpdateProgress(downloaded: Int, total: Int) {
        progressHandler?("Downloaded \(downloaded) from \(total)")
    }
    
    func downloadDidFinish(error: NSError?) {
        progressHandler?("Download finished")
        completionHandler?(error)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

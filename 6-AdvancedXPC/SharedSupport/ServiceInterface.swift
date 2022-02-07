//
//  ServiceInterface.swift
//  SharedSupport
//
//  Created by Alkenso (Vladimir Vashurkin) on 27.05.2021.
//

import Foundation


// MARK: XPC connection interfaces

@objc(DAEDemoXPCService)
public protocol DemoXPCService {
    // Passing custom class by copy.
    func verify(
        _ credentials: Credentials,
        at endpoints: [Endpoint],
        reply: @escaping (_ allowed: [Endpoint]) -> Void)
    
    // Returning NSProgress to track the progress.
    func upload(resource: String, completion: @escaping () -> Void) -> Progress
    
    // Passing object by proxy.
    func download(resource: String, delegate: DownloadDelegate) -> Void
}


// MARK: XPC interfaces - description

public extension NSXPCInterface {
    static var demoXPCService: NSXPCInterface {
        let interface = NSXPCInterface(with: DemoXPCService.self)
        
        // Whitelist collection-nested types
        interface.setClasses(
            NSSet(array: [NSArray.self, Endpoint.self, NSString.self]) as Set,
            for: #selector(DemoXPCService.verify(_:at:reply:)),
            argumentIndex: 1,
            ofReply: false
        )
        interface.setClasses(
            NSSet(array: [NSArray.self, Endpoint.self, NSString.self]) as Set,
            for: #selector(DemoXPCService.verify(_:at:reply:)),
            argumentIndex: 0,
            ofReply: true
        )
        
        // Describe proxy object interface
        let delegate = NSXPCInterface(with: DownloadDelegate.self)
        interface.setInterface(
            delegate,
            for: #selector(DemoXPCService.download(resource:delegate:)),
            argumentIndex: 1,
            ofReply: false
        )
        
        return interface
    }
}


// MARK: XPC objects passed by-proxy

@objc(DAEDownloadDelegate)
public protocol DownloadDelegate {
    func downloadDidStart()
    func downloadDidUpdateProgress(downloaded: Int, total: Int)
    func downloadDidFinish(error: NSError?)
}


// MARK: XPC objects passed by-copy

@objc(DAECredentials)
public class Credentials: NSObject, NSSecureCoding, Codable {
    public var email: String
    public var serialNumber: Int
    
    public init(email: String, serialNumber: Int) {
        self.email = email
        self.serialNumber = serialNumber
        
        super.init()
    }
    
    // NSSecureCoding support
    public static let supportsSecureCoding: Bool = true
    
    public required init?(coder: NSCoder) {
        guard let email = coder.decodeObject(
                of: NSString.self,
                forKey: CodingKeys.email.stringValue
        ) else {
            return nil
        }
        
        self.email = email as String
        self.serialNumber = coder.decodeInteger(
            forKey: CodingKeys.serialNumber.stringValue
        )
        
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(email, forKey: CodingKeys.email.stringValue)
        coder.encode(serialNumber,
                     forKey: CodingKeys.serialNumber.stringValue)
    }
}

@objc(DAEEndpoint)
public class Endpoint: NSObject, NSSecureCoding, Codable {
    public var ip: String
    public var port: UInt16
    
    public init(ip: String, port: UInt16) {
        self.ip = ip
        self.port = port
        
        super.init()
    }
    
    // NSSecureCoding support
    public static let supportsSecureCoding: Bool = true
    
    public required init?(coder: NSCoder) {
        guard let ip = coder.decodeObject(
                of: NSString.self,
                forKey: CodingKeys.ip.stringValue)
        else { return nil }
        
        self.ip = ip as String
        self.port = UInt16(coder.decodeInteger(forKey: CodingKeys.port.stringValue))
        
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(ip, forKey: CodingKeys.ip.stringValue)
        coder.encode(port, forKey: CodingKeys.port.stringValue)
    }
}

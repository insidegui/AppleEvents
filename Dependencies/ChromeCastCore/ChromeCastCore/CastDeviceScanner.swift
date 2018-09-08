//
//  CastDeviceScanner.swift
//  ChromeCastCore
//
//  Created by Guilherme Rambo on 19/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

extension CastDevice {
    
    convenience init(service: NetService, info: [String: String]) {
        let name = info["fn"] ?? service.name
        let addr = service.addresses?.first ?? Data()
        
        self.init(id: info["id"]!, name: name, hostName: service.hostName!, address: addr, port: service.port)
    }
    
}

@objcMembers public final class CastDeviceScanner: NSObject {
    
    public static let DeviceListDidChange = Notification.Name(rawValue: "DeviceScannerDeviceListDidChangeNotification")
    
    private lazy var browser: NetServiceBrowser = {
        let b = NetServiceBrowser()
        
        b.includesPeerToPeer = true
        b.delegate = self
        
        return b
    }()
    
    public var isScanning = false
    
    fileprivate var services = [NetService]()
    
    public fileprivate(set) var devices = [CastDevice]() {
        didSet {
            NotificationCenter.default.post(name: CastDeviceScanner.DeviceListDidChange, object: self)
        }
    }
    
    public func startScanning() {
        guard !isScanning else { return }

        browser.stop()
        browser.searchForServices(ofType: "_googlecast._tcp", inDomain: "local")
        
        #if DEBUG
            NSLog("Started scanning")
        #endif
    }
    
    public func stopScanning() {
        guard isScanning else { return }
        
        browser.stop()
        
        #if DEBUG
            NSLog("Stopped scanning")
        #endif
    }
    
    deinit {
        stopScanning()
    }
    
}

extension CastDeviceScanner: NetServiceBrowserDelegate {
    
    public func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        isScanning = true
    }
    
    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        isScanning = false
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        service.resolve(withTimeout: 30.0)
        services.append(service)
        
        #if DEBUG
            NSLog("Did find service: \(service) more: \(moreComing)")
        #endif
    }
    
}

extension CastDeviceScanner: NetServiceDelegate {
    
    public func netServiceDidResolveAddress(_ sender: NetService) {
        guard let data = sender.txtRecordData() else {
            #if DEBUG
                NSLog("No TXT record for \(sender), skipping")
            #endif
            return
        }
        
        var infoDict = [String: String]()
        NetService.dictionary(fromTXTRecord: data).forEach({ infoDict[$0.key] = String(data: $0.value, encoding: .utf8)! })
        
        #if DEBUG
            NSLog("Did resolve service: \(sender)")
            NSLog("\(infoDict)")
        #endif
        
        guard infoDict["id"] != nil else {
            #if DEBUG
                NSLog("No id for device \(sender), skipping")
            #endif
            return
        }
        
        let device = CastDevice(service: sender, info: infoDict)
        if let index = devices.index(where: { $0.id == device.id }) {
            devices.remove(at: index)
            devices.insert(device, at: index)
        } else {
            devices.append(device)
        }
    }
    
    public func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        if let index = services.index(of: sender) {
            services.remove(at: index)
        }
        
        #if DEBUG
            NSLog("!! Failed to resolve service: \(sender) - \(errorDict) !!")
        #endif
    }
    
}

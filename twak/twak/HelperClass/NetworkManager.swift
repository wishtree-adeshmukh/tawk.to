//
//  Connection.swift
//  reachability-playground
//
//  Created by Neo Ighodaro on 27/10/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//
import Foundation
extension Notification.Name {
    static var Online: Notification.Name {
        return .init(rawValue: "NetworkManager.Online")
    }
    
    static var Offline: Notification.Name {
        return .init(rawValue: "NetworkManager.Offline")
    }
}

class NetworkManager: NSObject {
    var reachability: Reachability!
    static let sharedInstance: NetworkManager = { return NetworkManager() }()
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    
    override init() {
        super.init()
        do {
            reachability = try Reachability()
            try reachability.startNotifier()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(networkStatusChanged(_:)),
                name: .reachabilityChanged,
                object: reachability
            )
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
        // let reachability = notification.object as! Reachability
        if reachability.connection != .unavailable {
            SnackBar().snackBarNeedToBe(show: false)
            notificationCenter.post(name: .Online, object: nil)
        } else {
            SnackBar().snackBarNeedToBe(show: true)
            notificationCenter.post(name: .Offline, object: nil)
        }
    }
    
    static func stopNotifier() -> Void {
        do {
            try (NetworkManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    func isOnline() -> Bool {
        return (NetworkManager.sharedInstance.reachability).connection != .unavailable
    }
    
    
    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection != .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .wifi {
            completed(NetworkManager.sharedInstance)
        }
    }
}

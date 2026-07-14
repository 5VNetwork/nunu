#if os(macOS)
  import FlutterMacOS
#endif
import Foundation
import NetworkExtension
//
//  MacosHostApiImpl.swift
//  Runner
//
//  Created by v on 2025-01-03.
//
import Tm
#if canImport(Cocoa)
import Cocoa
#endif


#if os(macOS)
@available(macOSApplicationExtension 11.0, *)
#endif
class DarwinHostApiImpl: DarwinHostApi {
    private let monitorForDefaultPhysicalNIC = NWPathMonitor(prohibitedInterfaceTypes: [NWInterface.InterfaceType.other])
    // Unlike monitorForDefaultPhysicalNIC, this one does not prohibit any
    // interface type, so it observes the real default path including tunnels.
    private var defaultNetworkMonitor: NWPathMonitor?
    private var lastIsPhysical: Bool?
    private var flutterApi: DarwinFlutterApi?
    private var networkFlutterApi: DarwinNetworkFlutterApi?
    
    func appGroupPath() throws -> String {
#if os(iOS)
        let path = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group." + Bundle.main.bundleIdentifier!)?
            .relativePath
#else
        let path = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "K4FDLB3LLD."+Bundle.main.bundleIdentifier!)?
            .relativePath
#endif
        debugPrint(path!)
        if path == nil {
            throw PigeonError(
                code: "nil containerURL", message: nil, details: nil)
        }
        return path!
    }

    func startXApiServer(
        config: FlutterStandardTypedData,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.setDefaultNIC(path: self.monitorForDefaultPhysicalNIC.currentPath)
        DispatchQueue.global().async {
            var error: NSError?
            X_darwinStartApiServer(config.data, &error)
            if error != nil {
                completion(
                    .failure(
                        PigeonError(
                            code: error!.localizedDescription, message: nil,
                            details: nil)))
            } else {
                completion(.success(()))
            }
        }
        self.monitorForDefaultPhysicalNIC.pathUpdateHandler = { path in
            self.setDefaultNIC(path: path)
        }
        self.monitorForDefaultPhysicalNIC.start(queue: DispatchQueue.global())
    }
    
        private func setDefaultNIC(path: Network.NWPath) {
        print("path: \(path)")
        if path.status == .satisfied {
            let first = path.availableInterfaces.first { NWInterface in
                !NWInterface.name.contains("utun")
            }
            if first != nil {
                X_darwinUpdateDefaultRouteInterface(first!.name, first!.index)
            }
            path.availableInterfaces.forEach { NWInterface in
                print( "available nic \(NWInterface.name)")
            }
            path.gateways.forEach { NWEndpoint in
                print("available gateway \(NWEndpoint.debugDescription)")
            }
            print("path support ipv6: \(path.supportsIPv6)")
            print("path constrained: \(path.isConstrained)")
            print("path expensive: \(path.isExpensive)")
//                print("lq: \(path.linkQuality)")
        } else {
            print("not satisfied \(path.unsatisfiedReason)")
        }
    }

    func redirectStdErr(path: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        var error: NSError?
        X_darwinRedirectStderr(path, &error)
        if error != nil {
            completion(
                .failure(
                    PigeonError(
                        code: error!.localizedDescription, message: nil,
                        details: nil)))
        } else {
            completion(.success(()))
        }
    }
    
    func generateTls() throws -> FlutterStandardTypedData {
        var error: NSError?
        var data = X_darwinGenerateTls(&error)
        if error != nil {
            throw PigeonError(
                code: error!.localizedDescription, message: nil,
                details: nil)
        } else if data == nil {
            throw PigeonError(
                code: "data is null", message: nil,
                details: nil)
        }
        return FlutterStandardTypedData(bytes: data!)
    }

    func setupShutdownNotification() throws {
        #if os(macOS)
        // Set up NSWorkspace notifications for system events
        let workspace = NSWorkspace.shared
        let notificationCenter = workspace.notificationCenter
        
        // Listen for system shutdown/restart notifications
        notificationCenter.addObserver(
            forName: NSWorkspace.willPowerOffNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.flutterApi?.onSystemWillShutdown(completion: { _ in })
        }
        
        notificationCenter.addObserver(
            forName: NSWorkspace.sessionDidResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // This can indicate logout or restart
            self?.flutterApi?.onSystemWillRestart(completion: { _ in })
        }
        
        notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.flutterApi?.onSystemWillSleep(completion: { _ in })
        }
        
        // Also listen for application termination
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.flutterApi?.onSystemWillShutdown(completion: { _ in })
        }
        #endif
    }
    
    func setFlutterApi(_ flutterApi: DarwinFlutterApi) {
        self.flutterApi = flutterApi
    }

    func setNetworkFlutterApi(_ api: DarwinNetworkFlutterApi) {
        self.networkFlutterApi = api
    }

    /// Monitors the default network path and notifies Flutter whenever it
    /// switches between a physical interface and a tunnel (VPN), mirroring
    /// AndroidHostApi.startBindToDefaultNetwork.
    func startMonitorDefaultNetwork() throws {
        if defaultNetworkMonitor != nil {
            return
        }
        let monitor = NWPathMonitor()
        defaultNetworkMonitor = monitor
        monitor.pathUpdateHandler = { [weak self] path in
            print("default nic path: \(path)")
            guard let self = self else { return }
            guard path.status == .satisfied else {
                // No connectivity; report as non-physical like Android's
                // unknown-capability branch.
                self.notifyDefaultNetwork(isPhysical: false)
                return
            }
            self.notifyDefaultNetwork(isPhysical: !Self.isTunnelPath(path))
        }
        monitor.start(queue: DispatchQueue.global())
    }

    private static func isTunnelPath(_ path: Network.NWPath) -> Bool {
        // The first available interface is the one the default route uses.
        // Packet Tunnel / WireGuard / IKEv2 VPNs show up as utun/ipsec/ppp,
        // whose NWInterface type is `.other`.
        guard let primary = path.availableInterfaces.first else {
            return false
        }
        if primary.type == .other {
            return true
        }
        let tunnelPrefixes = ["utun", "ipsec", "ppp", "tun", "tap"]
        return tunnelPrefixes.contains { primary.name.hasPrefix($0) }
    }

    private func notifyDefaultNetwork(isPhysical: Bool) {
        if lastIsPhysical == isPhysical {
            return
        }
        lastIsPhysical = isPhysical
        DispatchQueue.main.async {
            self.networkFlutterApi?.defaultNetworkChanged(isPhysical: isPhysical) { _ in }
        }
    }
}

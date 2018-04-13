import Foundation
import NEKit
import CocoaLumberjackSwift

public class KcpSocket: NSObject, RawTCPSocketProtocol {
    private weak var schedule: KcpSchedule?
    private weak var remote: KcpRemote?

    private(set) var kcp: UnsafeMutablePointer<ikcpcb>?
    public var lastSendMs: UInt32

    weak open var delegate: RawTCPSocketDelegate?

    private static var conv = 1
    init(schedule: KcpSchedule, conv: UInt32) {
        self.schedule = schedule
        self.remote = nil
        self.kcp = nil
        self.lastSendMs = UInt32(DispatchTime.now().uptimeNanoseconds * 1000)
        super.init()

        let holder = Unmanaged.passRetained(self)
        let pointer = UnsafeMutableRawPointer(holder.toOpaque())
        self.kcp = ikcp_create(conv, pointer)

        DDLogError("kcp[\(ikcp_getconv(kcp))]: create")
    }

    deinit {
        DDLogError("kcp[\(ikcp_getconv(kcp))]: release")

        remote?.removeSocket(socket: self)
        ikcp_release(kcp)
        kcp = nil;
    }

    public var conv: UInt32 {
        get {
            return kcp?.pointee.conv ?? 0
        }
    }

    /// If the socket is connected.
    open var isConnected: Bool {
        return remote != nil
    }

    public var sourceIPAddress: IPAddress? { return schedule?.address }
    public var sourcePort: NEKit.Port? { return schedule?.port }

    public var destinationIPAddress: IPAddress? { return remote?.address }
    public var destinationPort: NEKit.Port? { return remote?.port }

    public func connectTo(host: String, port: Int, enableTLS: Bool, tlsSettings: [AnyHashable: Any]?) throws {

        remote?.removeSocket(socket: self)

        let hostAddr = IPAddress(fromString: host)
        remote = schedule?.findRemote(remoteAddr: hostAddr!, remotePort: UInt16(port))
        remote?.addSocket(socket: self)

        DDLogError("\(self): connectTo: \(isConnected)")
    }

    public func disconnect() {
        DDLogError("\(self): disconnect)")
        
        remote?.removeSocket(socket: self)
        remote = nil
    }

    public func forceDisconnect() {
        DDLogError("\(self): forceDisconnect)")
        
        remote?.removeSocket(socket: self)
        remote = nil
    }

    public func write(data: Data) {
        guard isConnected else {
            DDLogError("\(self): write: not connected")
            return
        }

        let rv = data.withUnsafeBytes { (d: UnsafePointer<CChar>) -> CInt in
            return ikcp_send(kcp, d, Int32(data.count))
        }
        
        DDLogError("\(self): write\(data.count), rv=\(rv)")        
    }

    public func readData() {
        DDLogError("\(self): readData")        
    }

    public func readDataTo(length: Int) {
        DDLogError("\(self): readDataTo")        
    }

    public func readDataTo(data: Data) {
        DDLogError("\(self): readDataTo2")
    }

    public func readDataTo(data: Data, maxLength: Int) {
        DDLogError("\(self): readDataTo3")
    }
}


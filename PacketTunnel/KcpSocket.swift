import Foundation
import NEKit
import CocoaLumberjackSwift

public class KcpSocket: NSObject, RawTCPSocketProtocol {
    private weak var remote: KcpRemote?

    open var remotePort: NEKit.Port = 0
    open var remoteAddress: IPAddress? = nil
    open private(set) var remoteAddr: Data? = nil

    private(set) var kcp: UnsafeMutablePointer<ikcpcb>?
    public var lastSendMs: UInt32

    weak open var delegate: RawTCPSocketDelegate?

    private static var conv = 1
    init(_ remote: KcpRemote) {
        self.remote = remote

        self.kcp = nil
        self.lastSendMs = UInt32(DispatchTime.now().uptimeNanoseconds * 1000)
        super.init()

        let holder = Unmanaged.passRetained(self)
        let pointer = UnsafeMutableRawPointer(holder.toOpaque())
        self.kcp = ikcp_create(UInt32(KcpSocket.conv), pointer)

        KcpSocket.conv += 1

        self.remote?.addSocket(socket: self)
        
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
        return remote != nil && remoteAddr != nil
    }

    public var sourceIPAddress: IPAddress? { return nil }
    public var sourcePort: NEKit.Port? { return nil }

    public var destinationIPAddress: IPAddress? { return remoteAddress }
    public var destinationPort: NEKit.Port? { return remotePort }

    public func connectTo(host: String, port: Int, enableTLS: Bool, tlsSettings: [AnyHashable: Any]?) throws {
        remoteAddress = IPAddress(fromString: host)
        remotePort = NEKit.Port(port: UInt16(port))

        // var data: NSData
        // var address: sockaddr ...

        // data.getBytes(&address, length: MemoryLayout<sockaddr>.size)
    }

    public func disconnect() {
        remoteAddr = nil
    }

    public func forceDisconnect() {
        remoteAddr = nil
    }

    public func write(data: Data) {
        guard isConnected else { return }

        let rv = data.withUnsafeBytes { (d: UnsafePointer<CChar>) -> CInt in
            return ikcp_send(kcp, d, Int32(data.count))
        }
        
        DDLogError("kcp ==> write\(data.count), rv=\(rv)")        
    }

    public func readData() {
    }

    public func readDataTo(length: Int) {
    }

    public func readDataTo(data: Data) {
    }

    public func readDataTo(data: Data, maxLength: Int) {
    }
}


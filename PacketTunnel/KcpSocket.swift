import Foundation
import NEKit
import CocoaLumberjackSwift

public class KcpSocket: NSObject, RawTCPSocketProtocol {
    private weak var remote: KcpRemote?
    private var kcp: UnsafeMutablePointer<ikcpcb>?
    
    weak open var delegate: RawTCPSocketDelegate?

    private static var conv = 1
    init(_ remote: KcpRemote) {
        self.remote = remote;
        kcp = nil;
        super.init()

        let holder = Unmanaged.passRetained(self)
        let pointer = UnsafeMutableRawPointer(holder.toOpaque())
        kcp = ikcp_create(UInt32(KcpSocket.conv), pointer)
        KcpSocket.conv+=1

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
        return remote != nil
    }

    public var sourceIPAddress: IPAddress? { return nil }
    public var sourcePort: NEKit.Port? { return nil }

    public var destinationIPAddress: IPAddress? { return nil }
    public var destinationPort: NEKit.Port? { return nil }

    public func connectTo(host: String, port: Int, enableTLS: Bool, tlsSettings: [AnyHashable: Any]?) throws {
    }

    public func disconnect() {
    }

    public func forceDisconnect() {
    }

    public func write(data: Data) {
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


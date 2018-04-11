import Foundation
import NEKit

public class KcpSocket: NSObject, RawTCPSocketProtocol {
    weak open var delegate: RawTCPSocketDelegate?

    /// If the socket is connected.
    open var isConnected: Bool {
        return true
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


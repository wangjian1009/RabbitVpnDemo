import Foundation
import NEKit
import CocoaAsyncSocket

class KcpShadowsocksProxyServer: ProxyServer, GCDAsyncSocketDelegate {
    private var kcp_socket: GCDAsyncUdpSocket!

    override public init(address: IPAddress?, port: NEKit.Port) {
        super.init(address: address, port: port)
    }
}

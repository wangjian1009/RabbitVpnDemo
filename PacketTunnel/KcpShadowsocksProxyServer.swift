import Foundation
import NEKit
import CocoaAsyncSocket

class KcpShadowsocksProxyServer: ProxyServer, GCDAsyncSocketDelegate {
    private var kcp_socket: GCDAsyncUdpSocket!

    override public init(address: IPAddress?, port: NEKit.Port) {
        super.init(address: address, port: port)

        kcp_socket = GCDAsyncSocket(delegate: self,
                                    delegateQueue: NEKit.QueueFactory.getQueue(),
                                    socketQueue: NEKit.QueueFactory.getQueue())
    }

    deinit {
        
    }
}

import Foundation
import NEKit
import CocoaAsyncSocket

class KcpShadowsocksProxyServer: ProxyServer {
    private let kcp_remote: KcpRemote

    public init(kcp_remote: KcpRemote, address: IPAddress?, port: NEKit.Port) {
        self.kcp_remote = kcp_remote
        super.init(address: address, port: port)
    }
}

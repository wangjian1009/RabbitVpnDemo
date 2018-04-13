import Foundation
import NEKit
import CocoaAsyncSocket

class KcpShadowsocksProxyServer: ProxyServer {
    private let kcpSchedule: KcpSchedule

    public init(_ kcpSchedule: KcpSchedule) {
        self.kcpSchedule = kcpSchedule
        super.init(address: nil, port: 0)
    }
}

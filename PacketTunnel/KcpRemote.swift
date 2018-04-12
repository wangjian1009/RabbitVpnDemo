import Foundation
import NEKit
import CocoaAsyncSocket
import CocoaLumberjackSwift

class KcpRemote: NSObject, GCDAsyncUdpSocketDelegate {
    private let kcp_socket: GCDAsyncUdpSocket!

    override public init() {
        kcp_socket = GCDAsyncUdpSocket(
            delegate: nil,
            delegateQueue: NEKit.QueueFactory.getQueue(),
            socketQueue: NEKit.QueueFactory.getQueue())
        super.init();
        
        kcp_socket.setDelegate(self);
    }
}

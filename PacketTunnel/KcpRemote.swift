import Foundation
import NEKit
import CocoaAsyncSocket
import CocoaLumberjackSwift

class KcpRemote: NSObject, GCDAsyncUdpSocketDelegate {
    static let kcpUpdateSpanMS = 10
    private let kcpSocket: GCDAsyncUdpSocket
    private var kcps: [KcpSocket?]

    override public init() {
        kcps = []
        kcpSocket = GCDAsyncUdpSocket(
            delegate: nil,
            delegateQueue: NEKit.QueueFactory.getQueue(),
            socketQueue: NEKit.QueueFactory.getQueue())
        super.init();
        
        kcpSocket.setDelegate(self);

        scheduleKcpUpdate(delayMs: KcpRemote.kcpUpdateSpanMS)
    }

    func scheduleKcpUpdate(delayMs: Int) {
        QueueFactory.getQueue().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(delayMs)) {
            [weak self] in

            guard self != nil else {
                return;
            }

            let curTimeMs : UInt32 = UInt32(DispatchTime.now().uptimeNanoseconds * 1000)
            for kcpSocket in (self?.kcps)! {
            }

            self?.scheduleKcpUpdate(delayMs: KcpRemote.kcpUpdateSpanMS)
        }
    }

    public func addSocket(socket: KcpSocket) {
        kcps.append(socket)
    }

    public func removeSocket(socket: KcpSocket) {
        kcps.remove(at: kcps.index(of: socket)!)
    }
}

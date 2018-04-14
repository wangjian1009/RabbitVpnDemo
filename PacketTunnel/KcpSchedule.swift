import Foundation
import NEKit
import CocoaAsyncSocket
import CocoaLumberjackSwift

class KcpSchedule: NSObject, GCDAsyncUdpSocketDelegate {
    public private(set) var address: IPAddress
    public private(set) var port: NEKit.Port
    public let socket: GCDAsyncUdpSocket
    public let kcpUpdateSpanMS = 10
    public let shkSpanMs = 800

    private var lastConv: UInt32 = 0
    private var remotes = [KcpRemote]()

    public init(address: IPAddress, port: UInt16) {
        self.address = address
        self.port = NEKit.Port(port: UInt16(port))

        self.socket = GCDAsyncUdpSocket(
            delegate: nil,
            delegateQueue: NEKit.QueueFactory.getQueue(),
            socketQueue: NEKit.QueueFactory.getQueue())

        super.init();

        socket.setDelegate(self);
    }

    public func scheduleKcpUpdate(delayMs: Int) {
        QueueFactory.getQueue().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(delayMs)) {
            [weak self] in

            guard self != nil else {
                DDLogError("KcpSchedule tick stop");
                return;
            }

            let curTimeMs = UInt32(DispatchTime.now().uptimeNanoseconds / 1000000)
            for remote in (self?.remotes)! {
                remote.kcpUpdate(curTimeMs: curTimeMs)
            }

            self?.scheduleKcpUpdate(delayMs: (self?.kcpUpdateSpanMS)!)
        }
    }

    open func addRemote(remoteAddr: IPAddress, remotePort: UInt16) -> KcpRemote {
        let remote = KcpRemote(schedule: self, addr: remoteAddr, port: remotePort)
        remotes.append(remote)
        return remote
    }

    open func removeRemote(remote: KcpRemote) {
        remotes.remove(at: remotes.index(of: remote)!)
    }

    open func findRemote(remoteAddr: IPAddress, remotePort: UInt16) -> KcpRemote? {
        for remote in remotes {
            if (remote.address == remoteAddr && remote.port == NEKit.Port(port: remotePort)) {
                return remote
            }
        }
        return nil
    }

    open func createSocket() -> KcpSocket? {
        lastConv += 1
        return KcpSocket(schedule: self, conv: lastConv + 1)
    }
}

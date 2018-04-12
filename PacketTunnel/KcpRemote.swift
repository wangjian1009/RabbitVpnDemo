import Foundation
import NEKit
import CocoaAsyncSocket
import CocoaLumberjackSwift

class KcpRemote: NSObject, GCDAsyncUdpSocketDelegate {
    enum KcpCmd : UInt32 {
    case PUSH = 81
    case ACK = 82
    case WASK = 83
    case WINS = 84
    case EXT_SHK = 88
    case EXT_REMOVE = 89
    }
    
    static let kcpUpdateSpanMS = 10
    private let kcpSocket: GCDAsyncUdpSocket
    private var kcps: [KcpSocket?]
    private var lastSendMs: UInt32
    private(set) var shkSpanMs: UInt32

    override public init() {
        self.kcps = []
        self.kcpSocket = GCDAsyncUdpSocket(
            delegate: nil,
            delegateQueue: NEKit.QueueFactory.getQueue(),
            socketQueue: NEKit.QueueFactory.getQueue())
        self.shkSpanMs = 800
        self.lastSendMs = UInt32(DispatchTime.now().uptimeNanoseconds * 1000);
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
                if (kcpSocket == nil) {
                    continue;
                }
                
                ikcp_update(kcpSocket!.kcp, curTimeMs)

                if (curTimeMs - (kcpSocket?.lastSendMs)! > (self?.shkSpanMs)!) {
                    self?.sendCmd(conv: (kcpSocket?.conv)!, cmd: .EXT_SHK);
                //         listener, server, (struct sockaddr *)&remote->addr, (socklen_t)remote->addr_len,
                //         remote->kcp->conv, IKCP_CMD_EXT_SHK);
                    self?.lastSendMs = curTimeMs
                    kcpSocket?.lastSendMs = curTimeMs
                }
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

    private func sendCmd(conv: UInt32, cmd: KcpCmd) {
        // struct sockaddr * addr, socklen_t addr_len, IUINT32 conv, IUINT32 cmd)
    }
}

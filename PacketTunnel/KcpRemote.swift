import Foundation
import NEKit
import CocoaAsyncSocket
import CocoaLumberjackSwift
import Darwin.C

class KcpRemote: NSObject {
    public private(set) weak var schedule: KcpSchedule?
    public private(set) var port: NEKit.Port
    public private(set) var address: IPAddress
    public private(set) var sockAddr: Data

    private var lastSendMs: UInt32
    private var kcps = [KcpSocket?]()

    public init(schedule: KcpSchedule, addr: IPAddress, port: UInt16) {
        self.schedule = schedule
        self.address = addr
        self.port = NEKit.Port(port: UInt16(port))
        self.lastSendMs = UInt32(DispatchTime.now().uptimeNanoseconds * 1000);
        self.sockAddr = Data()
        super.init();

        switch addr.address {
        case .IPv4(let inAddr):
            var sockAddrIn = sockaddr_in()
            sockAddrIn.sin_family = sa_family_t(AF_INET);
            sockAddrIn.sin_port = CFSwapInt16(UInt16(port))
            sockAddrIn.sin_addr = inAddr
            withUnsafePointer(to: &sockAddrIn) {
                self.sockAddr.append(UnsafeRawPointer($0).assumingMemoryBound(to: UInt8.self), count: MemoryLayout<sockaddr_in>.size)
            }
        case .IPv6:
            var sockAddrIn6 = sockaddr_in6()
            withUnsafePointer(to: &sockAddrIn6) {
                self.sockAddr.append(UnsafeRawPointer($0).assumingMemoryBound(to: UInt8.self), count: MemoryLayout<sockaddr_in6>.size)
            }
        }
    }

    public func addSocket(socket: KcpSocket) {
        kcps.append(socket)
    }

    public func removeSocket(socket: KcpSocket) {
        kcps.remove(at: kcps.index(of: socket)!)
    }

    public func kcpUpdate(curTimeMs : UInt32) {
        for kcpSocket in kcps {
            if (kcpSocket == nil || !(kcpSocket?.isConnected)!) {
                continue;
            }
            
            ikcp_update(kcpSocket!.kcp, curTimeMs)

            if (curTimeMs - (kcpSocket?.lastSendMs)! > (schedule?.shkSpanMs)!) {
                sendCmd(conv: (kcpSocket?.conv)!, cmd: .EXT_SHK);
                lastSendMs = curTimeMs
                kcpSocket?.lastSendMs = curTimeMs
            }
        }
    }

    private func sendCmd(conv: UInt32, cmd: KcpCmd) {
        // struct sockaddr * addr, socklen_t addr_len, IUINT32 conv, IUINT32 cmd)

        //outgoingSocket.sendData(nil, toAddress:(NSData *)remoteAddr withTimeout:(NSTimeInterval)timeout tag:(long)tag;
    }

}

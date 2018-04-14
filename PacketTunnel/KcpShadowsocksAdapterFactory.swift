import Foundation
import CocoaLumberjackSwift
import NEKit

class KcpShadowsocksAdapterFactory : AdapterFactory {
    let kcpSchedule: KcpSchedule
    let remoteAddr: IPAddress
    let remotePort: UInt16
    let protocolObfuscaterFactory: ShadowsocksAdapter.ProtocolObfuscater.Factory
    let cryptorFactory: ShadowsocksAdapter.CryptoStreamProcessor.Factory
    let streamObfuscaterFactory: ShadowsocksAdapter.StreamObfuscater.Factory

    public init(
        kcpSchedule: KcpSchedule,
        remoteAddr: IPAddress,
        remotePort: UInt16,
        protocolObfuscaterFactory: ShadowsocksAdapter.ProtocolObfuscater.Factory,
        cryptorFactory: ShadowsocksAdapter.CryptoStreamProcessor.Factory,
        streamObfuscaterFactory: ShadowsocksAdapter.StreamObfuscater.Factory)
    {
        self.kcpSchedule = kcpSchedule
        self.remoteAddr = remoteAddr
        self.remotePort = remotePort
        self.protocolObfuscaterFactory = protocolObfuscaterFactory
        self.cryptorFactory = cryptorFactory
        self.streamObfuscaterFactory = streamObfuscaterFactory
    }

    override open func getAdapterFor(session: ConnectSession) -> AdapterSocket {
        DDLogError("xxxx: getAdapterFor: \(session)"); DDLog.flushLog()
        
        let adapter = ShadowsocksAdapter(
            host: remoteAddr.description, port: Int(remotePort),
            protocolObfuscater: protocolObfuscaterFactory.build(),
            cryptor: cryptorFactory.build(),
            streamObfuscator: streamObfuscaterFactory.build(for: session))
        adapter.socket = kcpSchedule.createSocket()
        try! adapter.socket.connectTo(host: remoteAddr.description, port: Int(remotePort), enableTLS: false, tlsSettings: nil)
        return adapter
    }
}

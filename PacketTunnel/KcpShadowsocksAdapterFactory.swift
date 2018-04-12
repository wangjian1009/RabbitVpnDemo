import Foundation
import NEKit

class KcpShadowsocksAdapterFactory : AdapterFactory {
    let kcp_remote: KcpRemote
    let protocolObfuscaterFactory: ShadowsocksAdapter.ProtocolObfuscater.Factory
    let cryptorFactory: ShadowsocksAdapter.CryptoStreamProcessor.Factory
    let streamObfuscaterFactory: ShadowsocksAdapter.StreamObfuscater.Factory

    public init(
        kcp_remote: KcpRemote,
        protocolObfuscaterFactory: ShadowsocksAdapter.ProtocolObfuscater.Factory,
        cryptorFactory: ShadowsocksAdapter.CryptoStreamProcessor.Factory,
        streamObfuscaterFactory: ShadowsocksAdapter.StreamObfuscater.Factory)
    {
        self.kcp_remote = kcp_remote;
        self.protocolObfuscaterFactory = protocolObfuscaterFactory
        self.cryptorFactory = cryptorFactory
        self.streamObfuscaterFactory = streamObfuscaterFactory
    }

    override open func getAdapterFor(session: ConnectSession) -> AdapterSocket {
        let adapter = ShadowsocksAdapter(
            host: "", port: 0,
            protocolObfuscater: protocolObfuscaterFactory.build(),
            cryptor: cryptorFactory.build(),
            streamObfuscator: streamObfuscaterFactory.build(for: session))
        adapter.socket = KcpSocket(kcp_remote)
        return adapter
    }
}

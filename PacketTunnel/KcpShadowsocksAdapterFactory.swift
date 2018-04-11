import Foundation
import NEKit

public class KcpShadowsocksAdapterFactory : AdapterFactory {
    let serverHost: String
    let serverPort: Int
    let protocolObfuscaterFactory: ShadowsocksAdapter.ProtocolObfuscater.Factory
    let cryptorFactory: ShadowsocksAdapter.CryptoStreamProcessor.Factory
    let streamObfuscaterFactory: ShadowsocksAdapter.StreamObfuscater.Factory

    public init(serverHost: String, serverPort: Int, protocolObfuscaterFactory: ShadowsocksAdapter.ProtocolObfuscater.Factory, cryptorFactory: ShadowsocksAdapter.CryptoStreamProcessor.Factory, streamObfuscaterFactory: ShadowsocksAdapter.StreamObfuscater.Factory) {
        self.protocolObfuscaterFactory = protocolObfuscaterFactory
        self.cryptorFactory = cryptorFactory
        self.streamObfuscaterFactory = streamObfuscaterFactory
        self.serverHost = serverHost
        self.serverPort = serverPort
    }

    override open func getAdapterFor(session: ConnectSession) -> AdapterSocket {
        let adapter = ShadowsocksAdapter(host: serverHost, port: serverPort, protocolObfuscater: protocolObfuscaterFactory.build(), cryptor: cryptorFactory.build(), streamObfuscator: streamObfuscaterFactory.build(for: session))
        adapter.socket = KcpSocket()
        return adapter
    }
}

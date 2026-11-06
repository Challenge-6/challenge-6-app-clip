//
//  HostService.swift
//  challenge6
//
//  Created by Lucas on 29/10/26.
//

import Foundation
import Network
import Combine

class HostService: ObservableObject {

    private var listener: NWListener?
    var connections: [NWConnection] = []
    @Published var players: [Player] = []

    
    
    func initListener(){
        let parameters = NWParameters.tcp
        //parameters.requiredInterfaceType = .loopback
        //parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: "127.0.0.1", port: 8080)
        
        do {
            listener = try NWListener(using: parameters, on: 5252)
        } catch {
            print("erro ao iniciar o listener \(error)")
            return
        }
        // [weak self] serve para evitar vazamento de memoria e ciclos de renteção
        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("escutando na porta 8080")
            case .failed(let error):
                print("escuta falhou: \(error)")
                self?.listener?.cancel()
            case .cancelled:
                print("escuta cancelada")
            default:
                break
            }
        }
        
        listener?.newConnectionHandler = { [weak self] connection in
            guard let self else { return }
            print("novo cliente foi conectado: \(connection.endpoint)")
            self.connections.append(connection)
            let player = Player(connection: connection)

            players.append(player)
            //print(player.nickname ?? "erro ao criar player")

//            connection.stateUpdateHandler = { state in
//                if case .ready = state {
//                    player.receiveNickname { nickname in
//                        print("Jogador conectado: \(nickname)")
//                        self.objectWillChange.send()   
//                    }                }
//                if case .none = self.listener {
//                    print("ndajsbhdjbhsa")
//                }
//            }
            connection.stateUpdateHandler = { [weak self, weak connection] state in
                guard let self, let connection else { return }

                switch state {

                case .ready:
                    print("Jogador conectado: \(connection.endpoint)")

                    guard let player = self.players.first(where: {
                        $0.connection === connection
                    }) else { return }

                    player.receiveNickname { nickname in
                        print("Jogador conectado: \(nickname)")

                        DispatchQueue.main.async {
                            print("Jogador identificado: \(nickname)")
                            self.objectWillChange.send()
                            self.broadcastParticipants()
                        }
                    }            }
                if case .none = self.listener {
                    print("ndajsbhdjbhsa")
                }
            }
            connection.start(queue: .main)
            //self.message(connection: connection)
        }
        
        listener?.start(queue: .main)
        
    }
    
    private func message(connection: NWConnection){
        //recebe mensagem
        connection.receive(minimumIncompleteLength: 1, maximumLength: 100) { [weak self] data, _, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("Received: \(message)")
                // envia mensagem
                connection.send(content: data, completion: .contentProcessed { _ in })
            }
            if isComplete {
                connection.cancel()
            } else if error == nil {
                self?.message(connection: connection)
            }
        }
        
    }

    func stop() {
        listener?.cancel()
        connections.forEach { $0.cancel() }
    }
    
    func localIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }

        for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            guard interface.ifa_addr.pointee.sa_family == UInt8(AF_INET),
                  String(cString: interface.ifa_name) == "en0" else { continue }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                        &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
            address = String(cString: host)
        }
        return address
    }
    
    func broadcastParticipants() {

        let nomes = players.compactMap { $0.nickname }

        let mensagem: [String: Any] = [
            "type": "participants",
            "names": nomes
        ]

        guard let json = try? JSONSerialization.data(
            withJSONObject: mensagem
        ) else {
            return
        }

        var dados = json
        dados.append(0x0A) // Quebra de linha

        for connection in connections {
            connection.send(
                content: dados,
                completion: .contentProcessed { error in
                    if let error {
                        print("Erro ao enviar participantes: \(error)")
                    }
                }
            )
        }
        print("Enviando participantes:", nomes)
    }
    func broadcastDrawResult(winner: String) {

        let mensagem: [String: Any] = [
            "type": "draw_result",
            "winner": winner
        ]

        guard let json = try? JSONSerialization.data(
            withJSONObject: mensagem
        ) else {
            return
        }

        var dados = json
        dados.append(0x0A)

        for connection in connections {
            connection.send(
                content: dados,
                completion: .contentProcessed { error in
                    if let error {
                        print("Erro ao enviar vencedor: \(error)")
                    }
                }
            )
        }

        print("Vencedor enviado aos App Clips:", winner)
    }
}

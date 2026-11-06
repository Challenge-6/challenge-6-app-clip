//
//  ClientService.swift
//  challenge6
//
//  Created by Lucas on 28/10/26.
//

import Network
import Foundation

class ClientService {
    //O nwconnection representa uma conexao unica entre dois dispositivos, com isso conseguimos enviar e receber dados.
    private var connection: NWConnection?
    var nickname: String = ""
    var onParticipantsUpdated: (([String]) -> Void)?
    var onConnected: (() -> Void)?
    var onDrawResult: ((String) -> Void)?
    private(set) var participantes: [String] = []
    private var receivedData = Data()
    
    // se conecta em ip fixo utilizamos para testes
    func connect(to host: String, port: UInt16){
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            print("porta inválida")
            return
        }
        connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: nwPort,
            using: .tcp
        )
        
        
        connection?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("conectado")
                self?.receiveMessages()
                self?.toSend(dataToSend: self?.nickname ?? "")
                self?.onConnected?()
            case .waiting(let error):
                print("erro de conexao \(error)")
            case .failed(let error):
                print("conexao falhou \(error)")
            case .cancelled:
                print("conexao foi cancelada")
            default:
                break
            }
        }
        connection?.start(queue: .main)

    }
    
    func toSend(dataToSend: String){
        guard let data = dataToSend.data(using: .utf8) else {return}
        // .contentProcessed verifica se a os dados forao enviados com sucesso dado que estao na pilha de rede
        connection?.send(content: data, completion: .contentProcessed {error in
            if let error = error{
                print("erro de envio: \(error)")
            }else {
                print("envio com sucesso")
            }}
        )
    }
   func receiveMessages() {

        connection?.receive(
            minimumIncompleteLength: 1,
            maximumLength: 4096
        ) { [weak self] data, _, isComplete, error in

            guard let self else { return }

            if let data {
                self.receivedData.append(data)

                while let newlineIndex = self.receivedData.firstIndex(of: 0x0A) {

                    let messageData = Data(
                        self.receivedData[..<newlineIndex]
                    )

                    self.receivedData.removeSubrange(
                        ...newlineIndex
                    )

                    self.processMessage(messageData)
                }
            }

            if let error {
                print("Erro ao receber mensagem: \(error)")
                return
            }

            if !isComplete {
                self.receiveMessages()
            }
        }
    }
    
    func processMessage(_ data: Data) {

        guard let json = try? JSONSerialization.jsonObject(
            with: data
        ) as? [String: Any],
        let type = json["type"] as? String else {
            return
        }

        switch type {

        case "participants":

            guard let names = json["names"] as? [String] else {
                return
            }

            DispatchQueue.main.async {
                self.participantes = names

                print("Participantes recebidos do host:", names)

                self.onParticipantsUpdated?(names)
            }
            print("Participantes recebidos:", names)
            
        case "draw_result":

            guard let winner = json["winner"] as? String else {
                return
            }

            DispatchQueue.main.async {
                print("Vencedor recebido do host:", winner)
                self.onDrawResult?(winner)
            }

        default:
            print("Mensagem desconhecida: \(type)")
        }
    }
        
}

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
        
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("conectado")
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
        
}

//
//  HostService.swift
//  challenge6
//
//  Created by Lucas on 28/10/26.
//

import Foundation
import Network

class HostService {
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    
    
    func initListener(){
        let parameters = NWParameters.tcp
        parameters.requiredInterfaceType = .loopback
        parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: "127.0.0.1", port: 8080)
        
        do {
            listener = try NWListener(using: parameters)
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
            connection.start(queue: .main)
            self.message(connection: connection)
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
}


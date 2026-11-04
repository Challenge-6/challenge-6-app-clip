//
//  Player.swift
//  challenge6
//
//  Created by Lucas on 04/11/26.
//

import Foundation
import Network

final class Player: Identifiable {

    let id = UUID()
    let connection: NWConnection
    var nickname: String?

    init(connection: NWConnection) {
        self.connection = connection
    }


    func receiveNickname(completion: @escaping (String) -> Void) {

        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: 1024
        ) { [weak self] data, _, _, error in

            guard error == nil,
                  let data,
                  let nickname = String(data: data, encoding: .utf8)
            else {
                return
            }

            let nick = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

            self?.nickname = nick
            completion(nick)
        }
    }
}

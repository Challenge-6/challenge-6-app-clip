//
//  EntrarSalaView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 29/10/26.
//

import SwiftUI

struct EntrarSalaView: View {

    @AppStorage("nickname") private var nickname = ""
    @State private var mostrandoScanner = false


    @State private var salaID = ""
    @State private var entrouNaSala = false
    @State private var clientService = ClientService()

    var body: some View {
        VStack(spacing: 24) {

            Image(systemName: "person.3.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)

            Text("Entrar na sala")
                .font(.largeTitle)
                .bold()

            TextField("Código da sala", text: $salaID)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()

            Button("Entrar") {
                mostrandoScanner = true
            }
            .sheet(isPresented: $mostrandoScanner) {
                QRScannerView { text in
                    mostrandoScanner = false
                    if let (host, port) = parseHost(text) {
                        clientService.connect(to: host, port: port)
                        entrouNaSala = true
                    }
                }
            }            .buttonStyle(.borderedProminent)
            .disabled(
                salaID.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
        }
        .padding()
        .alert("Entrada simulada", isPresented: $entrouNaSala) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(nickname), você entrou na sala \(salaID)!")
        }
    }
}

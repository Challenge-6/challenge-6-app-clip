//
//  SalaView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 29/10/26.
//

import SwiftUI

struct SalaView: View {

    let salaID: String
    @State private var hostService = HostService()
    private let qrCodeGenerator = QRCodeGenerator()

    private var urlSala: String {
        "https://example.com/sala?id=\(salaID)"
    }

    var body: some View {

        VStack(spacing: 24) {

            Text("Sala criada!")
                .font(.largeTitle)
                .bold()

            Text("Código: \(salaID)")
                .font(.headline)

            if let imagem = qrCodeGenerator.gerarQRCode(
                texto: "\(hostService.localIPAddress() ?? ""):5252"
            ) {

                Image(uiImage: imagem)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .accessibilityLabel("QR Code da sala \(salaID)")

            }

            Text("Escaneie o QR Code para entrar na sala.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            ShareLink(item: urlSala) {
                Label("Compartilhar convite", systemImage: "square.and.arrow.up")
            }
        }
        .padding()
        .onAppear {
            print("ID recebido:", salaID)
            print("URL gerada:", urlSala)
        }
    }
}

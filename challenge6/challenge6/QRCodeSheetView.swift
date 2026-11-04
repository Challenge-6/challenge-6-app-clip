//
//  QRCodeSheetView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 04/11/26.
//


import SwiftUI

struct QRCodeSheetView: View {

    let salaID: String

    @Environment(\.dismiss) private var dismiss

    private let qrCodeGenerator = QRCodeGenerator()

    private var urlSala: String {
        "https://example.com/sala?id=\(salaID)"
    }

    var body: some View {
        VStack(spacing: 24) {
            
            
            
            Text("Convidar participantes")
                .font(.largeTitle)
                .bold()

            Text("Código: \(salaID)")
                .font(.headline)

            if let imagem = qrCodeGenerator.gerarQRCode(
                texto: urlSala
            ) {
                Image(uiImage: imagem)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .accessibilityLabel(
                        "QR Code da sala \(salaID)"
                    )
            }

            Text("Escaneie o QR Code para entrar na sala.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            ShareLink(item: urlSala) {
                Label(
                    "Compartilhar convite",
                    systemImage: "square.and.arrow.up"
                )
            }

            Spacer()
        }
        .padding()
        .padding(.top, 80)
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.quaternary, in: Circle())
            }
            .accessibilityLabel("Fechar")
            .padding(.leading, 20)
            .padding(.top, 16)
        }
    }
}

#Preview {
    QRCodeSheetView(salaID: "ABC123")
}


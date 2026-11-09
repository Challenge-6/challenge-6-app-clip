//
//  QrCodeAppClip.swift
//  challenge6
//
//  Created by Lucas on 05/11/26.
//

import SwiftUI

struct QrCodeAppClip: View {
    private let qrCodeGenerator = QRCodeGenerator()
    let salaID: String
    var body: some View {
        VStack(spacing: 24) {
                Text("App Clip")
                    .font(.largeTitle)
                    .bold()

            if let imagem = qrCodeGenerator.gerarQRCode(
                texto: "https://example.com/sala?id=\(salaID)"
            ) {
                Image(uiImage: imagem)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }

                Text("Escaneie com a câmera do iPhone para abrir o App Clip.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .presentationDetents([.medium])

    }
}

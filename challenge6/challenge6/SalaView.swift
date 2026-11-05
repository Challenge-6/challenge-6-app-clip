//
//  SalaView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 29/10/26.
//


import SwiftUI

struct SalaView: View {

    let salaID: String

    @State private var mostrarQRCode = false

    @State private var participantes: [String] = [
        "Gabriel",
        "Lucas",
        "Sarah"
    ]

    // Resultado do sorteio
    @State private var vencedor: String?
    @State private var sorteioID: UUID?

    var body: some View {

        VStack(spacing: 24) {

            Text("Sala \(salaID)")
                .font(.title2)
                .bold()

            Button {
                mostrarQRCode = true
            } label: {
                Label(
                    "Convidar participantes",
                    systemImage: "qrcode"
                )
                .frame(maxWidth: 240)
                .padding(5)
            }
            .buttonStyle(.borderedProminent)

            // Roleta dinâmica
            RoletaView(
                participantes: participantes,
                vencedor: vencedor,
                sorteioID: sorteioID
            )
            .frame(width: 300, height: 300)

            Text("\(participantes.count) participantes")
                .foregroundStyle(.secondary)

            // Botão temporário para testar a animação
            Button {
                vencedor = "Lucas"
                sorteioID = UUID()
            } label: {
                Label(
                    "Simular sorteio",
                    systemImage: "play.fill"
                )
                .frame(maxWidth: 240)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle("Sorteio")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $mostrarQRCode) {
            QRCodeSheetView(salaID: salaID)
        }
    }
}

#Preview {
    NavigationStack {
        SalaView(salaID: "ABC123")
    }
}

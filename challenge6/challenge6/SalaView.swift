//
//  SalaView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 29/10/26.
//

import SwiftUI

struct SalaView: View {

    let salaID: String
    @ObservedObject var hostService: HostService
    @State private var mostrarQRAppClip = false
    private let qrCodeGenerator = QRCodeGenerator()
    
    @State private var mostrarQRCode = false
    @State private var sorteando = false
    @State private var mostrarVencedor = false
    private var participantes: [String] {
        hostService.players.compactMap { $0.nickname }
    }

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
            
            Button {
                mostrarQRAppClip = true
            } label: {
                Label(
                    "App clip",
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

            if mostrarVencedor, let vencedor {
                VStack(spacing: 8) {

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.yellow)

                    Text("Participante sorteado!")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(vencedor)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .transition(
                    .opacity.combined(
                        with: .move(edge: .bottom)
                    )
                )
            }

            Button {
                guard let sorteado = participantes.randomElement() else {
                    return
                }

                // Esconde o resultado anterior
                mostrarVencedor = false

                // Define o vencedor e inicia a roleta
                vencedor = sorteado
                sorteioID = UUID()
                sorteando = true

                // Aguarda os 5 segundos da animação da roleta
                Task {
                    try? await Task.sleep(for: .seconds(5))

                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        mostrarVencedor = true
                        sorteando = false
                    }
                }

            } label: {
                Label(
                    "Sortear participante",
                    systemImage: "play.fill"
                )
                .frame(maxWidth: 240)
            }
            .buttonStyle(.borderedProminent)
            .disabled(participantes.isEmpty || sorteando)

            Spacer()
        }
        .padding()
        .navigationTitle("Sorteio")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $mostrarQRCode) {
            QRCodeSheetView(salaID: salaID)
        }
        .sheet(isPresented: $mostrarQRAppClip) {
            QrCodeAppClip()
        }
    }
}

struct PlayerRow: View {
    @ObservedObject var player: Player

    var body: some View {
        Text(player.nickname ?? "...")
    }
}

#Preview {
    NavigationStack {
        SalaView(salaID: "ABC123", hostService: HostService())
    }
}

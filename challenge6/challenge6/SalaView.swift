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


    @State private var mostrarQRCode = false

    @State private var participantes: [String] = [
        "Gabriel",
        "Lucas",
        "Sarah"
    ]

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
           

            ZStack {
                Circle()
                    .fill(.blue.opacity(0.15))
                    .frame(width: 280, height: 280)

                VStack(spacing: 12) {
                    Image(systemName: "circle.dotted.circle")
                        .font(.system(size: 65))
                        .foregroundStyle(.blue)

                    Text("Roleta")
                        .font(.title)
                        .bold()
                }
            }

            Text(participantes.joined(separator: " • "))
                .multilineTextAlignment(.center)

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

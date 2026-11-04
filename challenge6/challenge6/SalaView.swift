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
                .frame(maxWidth: .infinity)
                .padding()
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

                    Text("\(participantes.count) participantes")
                        .foregroundStyle(.secondary)
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


#Preview {
    NavigationStack {
        SalaView(salaID: "ABC123")
    }
}

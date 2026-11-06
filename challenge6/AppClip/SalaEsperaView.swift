//
//  SalaEsperaView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 06/11/26.
//


import SwiftUI

struct SalaEsperaView: View {

    let salaID: String
    let clientService: ClientService
    @State private var participantes: [String] = []

    @State private var vencedor: String?
    @State private var sorteioID: UUID?
    @State private var sorteando = false
    @State private var mostrarVencedor = false

    var body: some View {

        GeometryReader { geometry in

            VStack(spacing: 0) {

                Spacer()
                    .frame(height: 25)

                Text("Sorteiaí")
                    .font(.system(size: 34, weight: .bold).width(.expanded))
                    .foregroundStyle(Color("Amarelo"))

                Spacer()
                    .frame(height: 50)

                Text("Sala: \(salaID)")
                    .font(.system(size: 20).width(.expanded))
                    .foregroundStyle(.white)

                Spacer()
                    .frame(height: 55)

                RoletaView(
                    participantes: participantes,
                    vencedor: vencedor,
                    sorteioID: sorteioID
                )
                .frame(width: min(320, geometry.size.width - 40),
                       height: min(320, geometry.size.width - 40))

                Spacer()
                    .frame(height: 35)

                if mostrarVencedor, let vencedor {

                    VStack(spacing: 8) {

                        Text("Participante sorteado!")
                            .font(.system(size: 20).width(.expanded))
                            .foregroundStyle(.white)

                        Text(vencedor)
                            .font(.system(size: 28, weight: .bold).width(.expanded))
                            .foregroundStyle(Color("Amarelo"))
                    }
                    .frame(height: 75)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                } else {

                    Text(
                        sorteando
                        ? "Sorteio em andamento..."
                        : "Aguardando Host\niniciar o sorteio..."
                    )
                    .font(.system(size: 20).width(.expanded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .frame(height: 75)
                }

                Spacer()
                    .frame(height: 20)

                RoundedRectangle(cornerRadius: 25)
                    .stroke(.white, lineWidth: 1.5)
                    .frame(width: 250, height: 45)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height)
        }
        .background {
            ZStack {
                Image("fundo")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                Image("detalheFundo")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            participantes = clientService.participantes
            clientService.onParticipantsUpdated = { nomes in
                participantes = nomes
            }
            clientService.onDrawResult = { nome in
                iniciarSorteio(vencedor: nome)
            }
        }
    }
    

    private func iniciarSorteio(vencedor nome: String) {

        guard participantes.contains(nome), !sorteando else {
            return
        }

        mostrarVencedor = false
        sorteando = true

        vencedor = nome
        sorteioID = UUID()

        Task {
            try? await Task.sleep(for: .seconds(5))

            withAnimation(.spring(
                response: 0.5,
                dampingFraction: 0.7
            )) {
                mostrarVencedor = true
                sorteando = false
            }
        }
    }
}




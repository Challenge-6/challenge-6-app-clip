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
    @Environment(\.dismiss) private var dismiss
    
    @State private var mostrarQRCode = false
    @State private var sorteando = false
    @State private var mostrarVencedor = false
    @State private var vencedor: String?
    @State private var sorteioID: UUID?

    private var participantes: [String] {
        hostService.players.compactMap { $0.nickname }
    }

    var body: some View {

        GeometryReader { geometry in

            VStack(spacing: 0) {

                Spacer()
                    .frame(height: 20)

                Text("Sorteiaí")
                    .font(.system(size: 34, weight: .bold).width(.expanded))
                    .foregroundStyle(Color("Amarelo"))

                Spacer()
                    .frame(height: 20)

                Text("Sala: \(salaID)")
                    .font(.system(size: 20).width(.expanded))
                    .foregroundStyle(.white)

                Spacer()
                    .frame(height: 25)

                Button {
                    mostrarQRCode = true
                } label: {
                    Label(
                        "Convidar participantes",
                        systemImage: "qrcode"
                    )
                    .font(.system(size: 17, weight: .semibold).width(.expanded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Color("RoxoEscuroBotao"),
                        in: Capsule()
                    )
                }
                .padding(.horizontal, 55)

                Spacer()
                    .frame(height: 30)

                RoletaView(
                    participantes: participantes,
                    vencedor: vencedor,
                    sorteioID: sorteioID
                )
                .frame(
                    width: min(310, geometry.size.width - 40),
                    height: min(310, geometry.size.width - 40)
                )

                Spacer()
                    .frame(height: 15)

                Text("\(participantes.count) participantes")
                    .font(.system(size: 17).width(.expanded))
                    .foregroundStyle(.white)

                Spacer()
                    .frame(height: 20)

                Button {
                    iniciarSorteio()
                } label: {
                    HStack{
                        Image(systemName: "play")
                            .padding(.leading)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color("RoxoEscuroBotao"))
                        
                        Text("Sortear participante")
                            .padding(.trailing)
                            .font(.system(size: 19, weight: .bold).width(.expanded))
                            .foregroundStyle(Color("RoxoEscuroBotao"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            
                    }
                    .background(
                        Color("Amarelo"),
                        in: Capsule()
                    )
                }
                .disabled(participantes.isEmpty || sorteando)
                .padding(.horizontal, 50)

                Spacer()
                    .frame(height: 25)

                if mostrarVencedor {
                    Text("Participante sorteado!")
                        .font(.system(size: 20).width(.expanded))
                        .foregroundStyle(.white)
                } else {
                    Text(
                        sorteando
                        ? "Sorteio em andamento..."
                        : "Aguardando sorteio..."
                    )
                    .font(.system(size: 20).width(.expanded))
                    .foregroundStyle(.white)
                }

                Spacer()
                    .frame(height: 12)

                ZStack {

                    RoundedRectangle(cornerRadius: 25)
                        .stroke(.white, lineWidth: 1.5)

                    if mostrarVencedor, let vencedor {
                        Text(vencedor)
                            .font(.system(size: 22, weight: .bold).width(.expanded))
                            .foregroundStyle(Color("Amarelo"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 16)
                            .transition(.opacity)
                    }
                }
                .frame(width: 250, height: 45)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height)
        }
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .padding(.leading, 16)
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
        .sheet(isPresented: $mostrarQRCode) {
            QRCodeSheetView(salaID: salaID)
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if mostrarVencedor {
                ConfettiView()
                    .ignoresSafeArea()
                    .zIndex(10)
            }
        }
    }

    private func iniciarSorteio() {

        guard let sorteado = participantes.randomElement() else {
            return
        }

        mostrarVencedor = false

        vencedor = sorteado
        sorteioID = UUID()
        sorteando = true

        hostService.broadcastDrawResult(winner: sorteado)

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

#Preview {
    NavigationStack {
        SalaView(
            salaID: "ABC123",
            hostService: HostService()
        )
    }
}

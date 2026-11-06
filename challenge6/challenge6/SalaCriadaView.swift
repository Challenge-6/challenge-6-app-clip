//
//  SalaCriadaView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 06/11/26.
//

import SwiftUI

struct SalaCriadaView: View {

    let salaID: String

    @ObservedObject var hostService: HostService

    @State private var irParaSala = false

    private let qrCodeGenerator = QRCodeGenerator()

    private var urlAppClip: String {
        "https://example.com/sala?id=\(salaID)"
    }

    var body: some View {

        GeometryReader { geometry in

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 45)

                Text("Sala criada!")
                    .font(.system(size: 28, weight: .bold).width(.expanded))
                    .foregroundStyle(Color("Amarelo"))

                Spacer()
                    .frame(height: 30)

                Text("Sala: \(salaID)")
                    .font(.system(size: 17).width(.expanded))
                    .foregroundStyle(.white)

                Spacer()
                    .frame(height: 30)

                if let imagem = qrCodeGenerator.gerarQRCode(
                    texto: urlAppClip,
                    branco: true
                ) {
                    Image(uiImage: imagem)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 270, height: 270)
                }

                Spacer()
                    .frame(height: 30)

                Text("Escaneie o QR code para os\nparticipantes abrirem o App Clip.")
                    .font(.system(size: 13, weight: .bold).width(.expanded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 30)

                Spacer()
                    .frame(height: 30)

                    
                VStack(spacing: 18) {
                    ShareLink(
                        item: URL(string: urlAppClip)!
                    ) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 19, weight: .semibold))

                            Text("Compartilhar convite")
                                .font(.system(size: 17, weight: .bold).width(.expanded))
                        }
                        .foregroundStyle(Color("RoxoEscuro"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color("Amarelo"), in: Capsule())
                    }

                    Button {
                        irParaSala = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 20, weight: .semibold))

                            Text("Ir para a sala")
                                .font(.system(size: 17, weight: .bold).width(.expanded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color("RoxoEscuroBotao"), in: Capsule())
                    }
                }
                .padding(.horizontal, 45)


                Spacer()
                    .frame(height: 30)
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
            }
        }
        .navigationDestination(isPresented: $irParaSala) {
            SalaView(
                salaID: salaID,
                hostService: hostService
            )
        }
    }
}

#Preview {
    NavigationStack {
        SalaCriadaView(
            salaID: "ABC123",
            hostService: HostService()
        )
    }
}

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

    private let hostService = HostService()

    private var enderecoConexao: String {
        "\(hostService.localIPAddress() ?? ""):5252"
    }

    var body: some View {

        GeometryReader { geometry in

            VStack(spacing: 0) {

                Spacer()
                    .frame(height: 20)

                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color("RoxoEscuroBotao"))
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.65),in: Circle())
                    }
                    .accessibilityLabel("Fechar")
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 100)

                

                if let imagem = qrCodeGenerator.gerarQRCode(
                    texto: enderecoConexao,
                    branco: true
                ) {
                    Image(uiImage: imagem)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .accessibilityLabel(
                            "QR Code de conexão da sala \(salaID)"
                        )
                }

                Spacer()
                    .frame(height: 55)

                Text("Escaneie o QR Code\npara entrar na sala.")
                    .font(.system(size: 17).width(.expanded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
                    .frame(height: 55)

          
                ShareLink(item: enderecoConexao) {

                    HStack(spacing: 10) {

                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Compartilhar convite")
                            .font(.system(size: 17,weight: .bold).width(.expanded))
                    }
                    .foregroundStyle(Color("RoxoEscuroBotao"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        Color("Amarelo"),
                        in: Capsule()
                    )
                }
                .padding(.horizontal, 45)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height)
        }
        .background {
            Color("RoxoEscuroBotao")
                .ignoresSafeArea()
        }
        .presentationBackground {
            Color("RoxoEscuroBotao")
        }
    }
}

#Preview {
    QRCodeSheetView(salaID: "ABC123")
}


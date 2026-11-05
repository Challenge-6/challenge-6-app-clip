//
//  AppClipApp.swift
//  AppClip
//
//  Created by Gabriel Groppo on 28/10/26.
//

import SwiftUI

struct ContentView: View {

    @State private var salaID: String = ""
    @State private var nickname: String = ""
    @State private var mostrandoScanner = false
    @State private var clientService = ClientService()

    var body: some View {
        GeometryReader { geometry in
            let altura = geometry.size.height

            VStack(spacing: 0) {

                Spacer()
                    .frame(height: altura * 0.12)

                Text("Bem Vindo(a)!")
                    .font(.system(size: 32, weight: .bold).width(.expanded))
                    .foregroundStyle(Color("Amarelo"))
               

                Spacer()
                    .frame(height: 40)

                Text("Sala: \(salaID.isEmpty ? "Não identificada" : salaID)")
                    .font(.system(size: 20).width(.expanded))
                    .foregroundStyle(.white)

                Spacer()
                    .frame(height: 36)

                Text("Escolha um nome para\nparticipar da sala.")
                    .font(.system(size: 21).width(.expanded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Spacer()
                    .frame(height: 40)

                
                ZStack(alignment: .bottom) {

                    Image("logoPavao")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 290)
                        .padding(.bottom, 34)
                    TextField("", text: $nickname, prompt: Text("Digite o seu apelido").foregroundStyle(.white.opacity(0.75)))
                        .font(.system(size: 14).width(.expanded))
                        .foregroundStyle(.white)
                        
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .frame(height: 45)
                    .background(Color("RoxoEscuro"),in: RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white, lineWidth: 1)
                    }
                    .padding(.horizontal, 40)
                    .offset(y: 10)
                }

                Spacer()

                Button {
                    mostrandoScanner = true
                    
                } label: {
                    Text("Entrar na sala")
                        .font(.system(size: 19, weight: .bold).width(.expanded))
                        .foregroundStyle(Color("RoxoEscuro"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            Color("Amarelo"),
                            in: Capsule()
                        )
                }
                .disabled(
                    nickname.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty || salaID.isEmpty
                )
                .padding(.horizontal, 70)

                Spacer()
                    .frame(height: altura * 0.10)
            }
            .frame(maxWidth: .infinity)
            .frame(height: altura)
        }
        .background {
            RadialGradient(
                colors: [
                    Color("RoxoClaro"),
                    Color("RoxoEscuro")
                ],
                center: .center,
                startRadius: 0,
                endRadius: 450
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $mostrandoScanner) {
            QRScannerView { text in
                mostrandoScanner = false
                if let (host, port) = parseHost(text) {
                    clientService.nickname = nickname
                    clientService.connect(to: host, port: port)
                    //entrouNaSala = true
                }
            }
        }

        // Mantém o recebimento do QR Code
        .onContinueUserActivity(
            NSUserActivityTypeBrowsingWeb
        ) { activity in

            guard let url = activity.webpageURL else {
                return
            }

            receberURL(url)
        }
    }

    private func receberURL(_ url: URL) {

        guard let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            return
        }

        salaID = components.queryItems?
            .first(where: { $0.name == "id" })?
            .value ?? ""
    }
}

#Preview {
    ContentView()
}

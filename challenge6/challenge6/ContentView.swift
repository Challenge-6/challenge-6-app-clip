import SwiftUI

struct Sala: Identifiable, Hashable {
    let id: String
}

struct ContentView: View {

    @AppStorage("nickname") private var nickname = ""

    @State private var salaRecebidaID: String?
    //@State private var mostrarEntradaSala = false
    @State private var salaCriada: Sala?
    @State private var nomeDigitado = ""
    @StateObject private var server = HostService()
    @FocusState private var nomeEmFoco: Bool
    @State private var mostrandoScanner = false
    @State private var entrouNaSala = false
    @State private var clientService = ClientService()

    var body: some View {
        NavigationStack {
            Group {
                if nickname.isEmpty {
                    telaCadastro
                } else {
                    telaInicial
                }
            }
            .navigationDestination(item: $salaCriada) { sala in
                SalaView(salaID: sala.id, hostService: server)   
            }
            .sheet(isPresented: $mostrandoScanner) {
                QRScannerView { text in
                    mostrandoScanner = false
                    if let (host, port) = parseHost(text) {
                        clientService.nickname = nickname
                        clientService.connect(to: host, port: port)
                        entrouNaSala = true
                    }
                }
            }
            .onContinueUserActivity(
                NSUserActivityTypeBrowsingWeb
            ) { activity in
                guard let url = activity.webpageURL else {
                    return
                }
                receberURL(url)
            }
            .onOpenURL { url in
                receberURL(url)
            }
            .alert(
                "Convite recebido",
                isPresented: Binding(
                    get: { salaRecebidaID != nil },
                    set: {
                        if !$0 {
                            salaRecebidaID = nil
                        }
                    }
                )
            ) {
                Button("OK") {
                    salaRecebidaID = nil
                }
            } message: {
                Text(
                    "Olá, \(nickname)! Convite para a sala \(salaRecebidaID ?? "")."
                )
            }
        }
    }

    private var telaCadastro: some View {
        GeometryReader { geometry in
            let altura = geometry.size.height

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)

                Text("Bem Vindo(a)!")
                    .font(.system(size: 32, weight: .bold).width(.expanded))
                    .foregroundStyle(Color("Amarelo"))

                Spacer()
                    .frame(height: nomeEmFoco ? 25 : 40)

                if !nomeEmFoco {

                    // Ocupa o lugar do "Sala: ..." do App Clip (texto 20pt + 36)
                    Spacer()
                        .frame(height: 60)

                    Text("Escolha um nome para\nparticipar das salas.")
                        .font(.system(size: 21).width(.expanded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)

                    Spacer()
                        .frame(height: 40)
                }

                ZStack(alignment: .bottom) {

                    Image("logoPavao")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 290)
                        .padding(.bottom, 70)

                    TextField(
                        "",
                        text: $nomeDigitado,
                        prompt: Text("Digite o seu apelido")
                            .foregroundStyle(.white.opacity(0.75))
                    )
                    .font(.system(size: 14).width(.expanded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .focused($nomeEmFoco)
                    .submitLabel(.done)
                    .onSubmit {
                        nomeEmFoco = false
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 45)
                    .background(
                        Color("RoxoEscuro"),
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white, lineWidth: 1)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .offset(y: 10)
                }
                Spacer()
                if !nomeEmFoco {
                    Button {
                        nomeEmFoco = false
                        nickname = nomeDigitado
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    } label: {
                        Text("Continuar")
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
                        nomeDigitado.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                    .opacity(
                        nomeDigitado.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ? 0.5 : 1
                    )
                    .padding(.horizontal, 70)
                }

                Spacer()
                    .frame(height: nomeEmFoco ? 12 : altura * 0.10)
            }
            .frame(maxWidth: .infinity)
            .frame(height: altura)
            .contentShape(Rectangle())
            .onTapGesture {
                nomeEmFoco = false
            }
        }
        .background {
            Image("fundo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
    


    private var telaInicial: some View {
        VStack(spacing: 0) {

            Image("logoPavao")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding(.bottom, 12)

            Text("Olá, \(nickname)!")
                .font(.system(size: 30, weight: .heavy))
                .fontWidth(.expanded)
                .foregroundStyle(Color("Amarelo"))
                .shadow(color: .black.opacity(0.25), radius: 6, y: 4)

            Button {
                nickname = ""
                nomeDigitado = ""
            } label: {
                Label("Alterar apelido", systemImage: "pencil")
                    .font(.system(size: 14))
                    .fontWidth(.expanded)
                    .underline()
            }
            .foregroundStyle(.white)
            .padding(.top, 8)

            Text("O que deseja fazer?")
                .font(.system(size: 20))
                .fontWidth(.expanded)
                .foregroundStyle(.white)
                .padding(.top, 35)

            Button {
                let novoID = String(UUID().uuidString.prefix(6))
                print("ID gerado:", novoID)
                server.initListener()
                salaCriada = Sala(id: novoID)
            } label: {
                Label("Criar Sala", systemImage: "plus.circle")
                    .font(.system(size: 20, weight: .bold))
                    .fontWidth(.expanded)
                    .foregroundStyle(Color("RoxoEscuro"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("Amarelo"), in: Capsule())
            }
            .padding(.top, 28)

            Button {
                mostrandoScanner = true
            } label: {
                Label("Entrar na sala", systemImage: "arrow.right.circle")
                    .font(.system(size: 20, weight: .bold))
                    .fontWidth(.expanded)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("RoxoEscuro"), in: Capsule())
            }
            .padding(.top, 18)
        }
        .padding(.horizontal, 52)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("fundo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }

    private func receberURL(_ url: URL) {
        guard let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ),
        components.scheme == "https",
        components.host == "example.com",
        components.path == "/sala",
        let id = components.queryItems?
            .first(where: { $0.name == "id" })?
            .value,
        !id.isEmpty else {
            return
        }

        print("Sala recebida pelo aplicativo completo:", id)

        salaRecebidaID = id
    }
}

#Preview {
    ContentView()
}

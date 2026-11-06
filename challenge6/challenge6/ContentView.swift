import SwiftUI

struct Sala: Identifiable, Hashable {
    let id: String
}

struct ContentView: View {

    @AppStorage("nickname") private var nickname = ""

    @State private var salaRecebidaID: String?
    @State private var mostrarEntradaSala = false
    @State private var salaCriada: Sala?
    @State private var nomeDigitado = ""
    @StateObject private var server = HostService()
    @FocusState private var nomeEmFoco: Bool


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
            .sheet(isPresented: $mostrarEntradaSala) {
                EntrarSalaView()
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



//    private var telaCadastro: some View {
//
//        VStack(spacing: 24) {
//
//            Image(systemName: "person.crop.circle")
//                .font(.system(size: 60))
//                .foregroundStyle(.blue)
//
//            Text("Bem-vindo!")
//                .font(.largeTitle)
//                .bold()
//
//            Text("Escolha um nome para participar das salas.")
//                .multilineTextAlignment(.center)
//                .foregroundStyle(.secondary)
//
//            TextField("Digite seu nome", text: $nomeDigitado)
//                .textFieldStyle(.roundedBorder)
//                .autocorrectionDisabled()
//
//            Button("Continuar") {
//
//                nickname = nomeDigitado
//                    .trimmingCharacters(in: .whitespacesAndNewlines)
//
//            }
//            .buttonStyle(.borderedProminent)
//            .disabled(
//                nomeDigitado.trimmingCharacters(
//                    in: .whitespacesAndNewlines
//                ).isEmpty
//            )
//
//        }
//        .padding()
//    }
    
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

        VStack(spacing: 24) {

            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Olá, \(nickname)!")
                .font(.largeTitle)
                .bold()

            Text("O que deseja fazer?")
                .foregroundStyle(.secondary)

            Button {
                let novoID = String(UUID().uuidString.prefix(6))

                print("ID gerado:", novoID)
                server.initListener()

                salaCriada = Sala(id: novoID)

            } label: {
                Label("Criar sala", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
                    .padding()
                
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                mostrarEntradaSala = true
            } label: {
                Label("Entrar na sala", systemImage: "arrow.right.circle")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)

            Button("Alterar nome") {
                nickname = ""
                nomeDigitado = ""
            }
            .font(.footnote)

        }
        .padding()
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

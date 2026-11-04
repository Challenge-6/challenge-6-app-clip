import SwiftUI

struct Sala: Identifiable {
    let id: String
}

struct ContentView: View {

    @AppStorage("nickname") private var nickname = ""

    @State private var salaRecebidaID: String?
    @State private var mostrarEntradaSala = false
    @State private var salaCriada: Sala?
    @State private var nomeDigitado = ""

    var body: some View {

        Group {

            if nickname.isEmpty {
                telaCadastro
            } else {
                telaInicial
                    .onAppear {
                        if let url = URL(string: "https://example.com/sala?id=ABC123"
                        ) {
                            receberURL(url)
                        }
                    }
            }

        }
        .sheet(item: $salaCriada) { sala in
            SalaView(salaID: sala.id)
        }
        .sheet(isPresented: $mostrarEntradaSala) {
            EntrarSalaView()
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            guard let url = activity.webpageURL else { return }
            receberURL(url)
        }
        .onOpenURL { url in
            receberURL(url)
        }
        .alert(
            "Convite recebido",
            isPresented: Binding(
                get: { salaRecebidaID != nil },
                set: { if !$0 { salaRecebidaID = nil } }
            )
        ) {
            Button("OK") {
                salaRecebidaID = nil
            }
        } message: {
            Text("Olá, \(nickname)! Convite para a sala \(salaRecebidaID ?? "").")
        }
    }


    private var telaCadastro: some View {

        VStack(spacing: 24) {

            Image(systemName: "person.crop.circle")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Bem-vindo!")
                .font(.largeTitle)
                .bold()

            Text("Escolha um nome para participar das salas.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            TextField("Digite seu nome", text: $nomeDigitado)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()

            Button("Continuar") {

                nickname = nomeDigitado
                    .trimmingCharacters(in: .whitespacesAndNewlines)

            }
            .buttonStyle(.borderedProminent)
            .disabled(
                nomeDigitado.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )

        }
        .padding()
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

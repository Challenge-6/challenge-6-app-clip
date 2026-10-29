import SwiftUI

struct Sala: Identifiable {
    let id: String
}

struct ContentView: View {

    @AppStorage("nickname") private var nickname = ""

    @State private var salaCriada: Sala?
    @State private var nomeDigitado = ""

    var body: some View {

        Group {

            if nickname.isEmpty {
                telaCadastro
            } else {
                telaInicial
            }

        }
        .sheet(item: $salaCriada) { sala in
            SalaView(salaID: sala.id)
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
                .textInputAutocapitalization(.words)
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
                print("Entrar na sala")
            } label: {
                Label("Entrar na sala", systemImage: "arrow.right.circle")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)

            Button("Alterar nickname") {
                nickname = ""
                nomeDigitado = ""
            }
            .font(.footnote)

        }
        .padding()
    }
}

#Preview {
    ContentView()
}

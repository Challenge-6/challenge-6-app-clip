import SwiftUI

struct ContentView: View {

    @State private var salaID: String = ""
    @State private var nickname: String = ""
    @State private var entrouNaSala = false

    var body: some View {
        VStack(spacing: 24) {

            Image(systemName: "person.3.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)

            Text("Entrar na sala")
                .font(.largeTitle)
                .bold()

            Text("Sala: \(salaID.isEmpty ? "Não identificada" : salaID)")
                .font(.headline)
                .foregroundStyle(.secondary)

            TextField("Digite seu nome", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()

            Button {
                entrouNaSala = true
            } label: {
                Text("Entrar na sala")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(
                nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || salaID.isEmpty
            )

        }
        .padding()
        .alert("Entrada simulada", isPresented: $entrouNaSala) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(nickname), você entrou na sala \(salaID)!")
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            guard let url = activity.webpageURL else { return }
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


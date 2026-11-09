### Arquivo: \⁠ ./AppClip/AppClipApp.swift\ ⁠
⁠ swift
//
//  AppClipApp.swift
//  AppClip
//
//  Created by Gabriel Groppo on 28/10/26.
//

import SwiftUI

@main
struct AppClipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./AppClip/SalaEsperaView.swift\ ⁠
⁠ swift
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
    @State private var mostrarConfete = false

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
                    .font(.system(size: 17).width(.expanded))
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

                if mostrarVencedor {
                    Text("Participante sorteado!")
                        .font(.system(size: 17).width(.expanded))
                        .foregroundStyle(.white)
                        .frame(height: 75)
                        .transition(.opacity)
                } else {
                    Text(
                        sorteando
                        ? "Sorteio em andamento..."
                        : "Aguardando Host\niniciar o sorteio..."
                    )
                    .font(.system(size: 17).width(.expanded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .frame(height: 75)
                }

                Spacer()
                    .frame(height: 20)

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
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                }
                .frame(width: 250, height: 45)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: mostrarVencedor)

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
        .overlay {
            if mostrarConfete {
                ConfettiView()
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
        mostrarConfete = true


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



 ⁠

---

### Arquivo: \⁠ ./AppClip/ContentView.swift\ ⁠
⁠ swift
//
//  AppClipApp.swift
//  AppClip
//
//  Created by Gabriel Groppo on 28/10/26.
//


import SwiftUI

struct ContentView: View {

    @State private var mostrarSalaEspera = false
    @State private var salaID: String = ""
    @State private var nickname: String = ""
    @State private var mostrandoScanner = false
    @State private var clientService = ClientService()

    @FocusState private var nicknameEmFoco: Bool

    var body: some View {
        GeometryReader { geometry in

            let altura = geometry.size.height

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)

                Text("Bem Vindo(a)!")
                    .font(.system(size: 32, weight: .bold).width(.expanded))
                    .foregroundStyle(Color("Amarelo"))

                Spacer()
                    .frame(height: nicknameEmFoco ? 25 : 40)

                if !nicknameEmFoco {

                    Text("Sala: \(salaID.isEmpty ? "Não identificada" : salaID)")
                        .font(.system(size: 17).width(.expanded))
                        .foregroundStyle(.white)

                    Spacer()
                        .frame(height: 36)

                    Text("Escolha um nome para\nparticipar da sala.")
                        .font(.system(size: 20).width(.expanded))
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
                        text: $nickname,
                        prompt: Text("Digite o seu apelido")
                            .foregroundStyle(.white.opacity(0.75))
                    )
                    .font(.system(size: 13).width(.expanded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .focused($nicknameEmFoco)
                    .submitLabel(.done)
                    .onSubmit {
                        nicknameEmFoco = false
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

                if !nicknameEmFoco {
                    Button {
                        nicknameEmFoco = false
                        mostrandoScanner = true
                    } label: {
                        Text("Entrar na sala")
                            .font(.system(size: 17, weight: .bold).width(.expanded))
                            .foregroundStyle(Color("RoxoEscuro"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
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
                }

                Spacer()
                    .frame(height: nicknameEmFoco ? 12 : altura * 0.10)
            }
            .frame(maxWidth: .infinity)
            .frame(height: altura)
            .contentShape(Rectangle())
            .onTapGesture {
                nicknameEmFoco = false
            }
        }
        .background {
            Image("fundo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .sheet(isPresented: $mostrandoScanner) {
            QRScannerView { text in
                if let (host, port) = parseHost(text) {
                    clientService.nickname = nickname
                    clientService.onConnected = {
                        DispatchQueue.main.async {
                            mostrandoScanner = false
                            mostrarSalaEspera = true
                        }
                    }
                    clientService.connect(to: host, port: port)

                } else {
                    print("QR Code de conexão inválido")
                }
            }
        }
        .fullScreenCover(isPresented: $mostrarSalaEspera) {
            SalaEsperaView(salaID: salaID, clientService: clientService)
        }
        
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
 ⁠

---

### Arquivo: \⁠ ./Networking/HostService.swift\ ⁠
⁠ swift
//
//  HostService.swift
//  challenge6
//
//  Created by Lucas on 29/10/26.
//

import Foundation
import Network
import Combine

class HostService: ObservableObject {

    private var listener: NWListener?
    var connections: [NWConnection] = []
    @Published var players: [Player] = []

    
    
    func initListener(){
        let parameters = NWParameters.tcp
        //parameters.requiredInterfaceType = .loopback
        //parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: "127.0.0.1", port: 8080)
        
        do {
            listener = try NWListener(using: parameters, on: 5252)
        } catch {
            print("erro ao iniciar o listener \(error)")
            return
        }
        // [weak self] serve para evitar vazamento de memoria e ciclos de renteção
        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("escutando na porta 8080")
            case .failed(let error):
                print("escuta falhou: \(error)")
                self?.listener?.cancel()
            case .cancelled:
                print("escuta cancelada")
            default:
                break
            }
        }
        
        listener?.newConnectionHandler = { [weak self] connection in
            guard let self else { return }
            print("novo cliente foi conectado: \(connection.endpoint)")
            self.connections.append(connection)
            let player = Player(connection: connection)

            players.append(player)
            //print(player.nickname ?? "erro ao criar player")

            connection.stateUpdateHandler = { [weak self, weak connection] state in
                guard let self, let connection else { return }

                switch state {

                case .ready:
                    print("Jogador conectado: \(connection.endpoint)")

                    guard let player = self.players.first(where: {
                        $0.connection === connection
                    }) else { return }

                    player.receiveNickname { nickname in
                        print("Jogador conectado: \(nickname)")

                        DispatchQueue.main.async {
                            self.objectWillChange.send()
                            self.broadcastParticipants()
                        }
                    }

                case .failed(let error):
                    print("Jogador desconectado: \(error)")
                    self.removePlayer(for: connection)

                case .cancelled:
                    print("Conexão encerrada")
                    self.removePlayer(for: connection)

                default:
                    break
                }
            }
            connection.start(queue: .main)
            //self.message(connection: connection)
        }
        
        listener?.start(queue: .main)
        
    }
    
    private func message(connection: NWConnection){
        //recebe mensagem
        connection.receive(minimumIncompleteLength: 1, maximumLength: 100) { [weak self] data, _, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("Received: \(message)")
                // envia mensagem
                connection.send(content: data, completion: .contentProcessed { _ in })
            }
            if isComplete {
                connection.cancel()
            } else if error == nil {
                self?.message(connection: connection)
            }
        }
        
    }

    func stop() {
        listener?.cancel()
        connections.forEach { $0.cancel() }
    }
    
    func localIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }

        for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            guard interface.ifa_addr.pointee.sa_family == UInt8(AF_INET),
                  String(cString: interface.ifa_name) == "en0" else { continue }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                        &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
            address = String(cString: host)
        }
        return address
    }
    
    private func removePlayer(for connection: NWConnection) {
        connections.removeAll { $0 === connection }
        players.removeAll { $0.connection === connection }
        connection.stateUpdateHandler = nil
        connection.cancel()

        // avisa os outros participantes que a lista mudou
        broadcastParticipants()
    }
    
    func broadcastParticipants() {

        let nomes = players.compactMap { $0.nickname }

        let mensagem: [String: Any] = [
            "type": "participants",
            "names": nomes
        ]

        guard let json = try? JSONSerialization.data(
            withJSONObject: mensagem
        ) else {
            return
        }

        var dados = json
        dados.append(0x0A) // Quebra de linha

        for connection in connections {
            connection.send(
                content: dados,
                completion: .contentProcessed { error in
                    if let error {
                        print("Erro ao enviar participantes: \(error)")
                    }
                }
            )
        }
        print("Enviando participantes:", nomes)
    }
    func broadcastDrawResult(winner: String) {

        let mensagem: [String: Any] = [
            "type": "draw_result",
            "winner": winner
        ]

        guard let json = try? JSONSerialization.data(
            withJSONObject: mensagem
        ) else {
            return
        }

        var dados = json
        dados.append(0x0A)

        for connection in connections {
            connection.send(
                content: dados,
                completion: .contentProcessed { error in
                    if let error {
                        print("Erro ao enviar vencedor: \(error)")
                    }
                }
            )
        }

        print("Vencedor enviado aos App Clips:", winner)
    }
}
 ⁠

---

### Arquivo: \⁠ ./Networking/ClientService.swift\ ⁠
⁠ swift
//
//  ClientService.swift
//  challenge6
//
//  Created by Lucas on 28/10/26.
//

import Network
import Foundation

class ClientService {
    //O nwconnection representa uma conexao unica entre dois dispositivos, com isso conseguimos enviar e receber dados.
    private var connection: NWConnection?
    var nickname: String = ""
    var onParticipantsUpdated: (([String]) -> Void)?
    var onConnected: (() -> Void)?
    var onDrawResult: ((String) -> Void)?
    private(set) var participantes: [String] = []
    private var receivedData = Data()
    
    // se conecta em ip fixo utilizamos para testes
    func connect(to host: String, port: UInt16){
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            print("porta inválida")
            return
        }
        connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: nwPort,
            using: .tcp
        )
        
        
        connection?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("conectado")
                self?.receiveMessages()
                self?.toSend(dataToSend: self?.nickname ?? "")
                self?.onConnected?()
            case .waiting(let error):
                print("erro de conexao \(error)")
            case .failed(let error):
                print("conexao falhou \(error)")
            case .cancelled:
                print("conexao foi cancelada")
            default:
                break
            }
        }
        connection?.start(queue: .main)

    }
    
    func toSend(dataToSend: String){
        guard let data = dataToSend.data(using: .utf8) else {return}
        // .contentProcessed verifica se a os dados forao enviados com sucesso dado que estao na pilha de rede
        connection?.send(content: data, completion: .contentProcessed {error in
            if let error = error{
                print("erro de envio: \(error)")
            }else {
                print("envio com sucesso")
            }}
        )
    }
   func receiveMessages() {

        connection?.receive(
            minimumIncompleteLength: 1,
            maximumLength: 4096
        ) { [weak self] data, _, isComplete, error in

            guard let self else { return }

            if let data {
                self.receivedData.append(data)

                while let newlineIndex = self.receivedData.firstIndex(of: 0x0A) {

                    let messageData = Data(
                        self.receivedData[..<newlineIndex]
                    )

                    self.receivedData.removeSubrange(
                        ...newlineIndex
                    )

                    self.processMessage(messageData)
                }
            }

            if let error {
                print("Erro ao receber mensagem: \(error)")
                return
            }

            if !isComplete {
                self.receiveMessages()
            }
        }
    }
    
    func processMessage(_ data: Data) {

        guard let json = try? JSONSerialization.jsonObject(
            with: data
        ) as? [String: Any],
        let type = json["type"] as? String else {
            return
        }

        switch type {

        case "participants":

            guard let names = json["names"] as? [String] else {
                return
            }

            DispatchQueue.main.async {
                self.participantes = names

                print("Participantes recebidos do host:", names)

                self.onParticipantsUpdated?(names)
            }
            print("Participantes recebidos:", names)
            
        case "draw_result":

            guard let winner = json["winner"] as? String else {
                return
            }

            DispatchQueue.main.async {
                print("Vencedor recebido do host:", winner)
                self.onDrawResult?(winner)
            }

        default:
            print("Mensagem desconhecida: \(type)")
        }
    }
        
}
 ⁠

---

### Arquivo: \⁠ ./challenge6/animacaoConfete.swift\ ⁠
⁠ swift
//
//  animacaoConfete.swift
//  challenge6
//
//  Created by Lucas on 06/11/26.
//

import SwiftUI

struct ConfettiView: View {

    @State private var inicio = Date()

    private let particles: [ConfettiParticle] = {
        let colors: [Color] = [
            Color("Amarelo"),
            .pink,
            .cyan,
            .green,
            .orange,
            .purple
        ]

        return (0..<75).map { index in
            ConfettiParticle(
                id: index,
                x: CGFloat.random(in: 0...1),
                drift: CGFloat.random(in: -90...90),
                size: CGFloat.random(in: 8...15),
                delay: Double.random(in: 0...1.5),
                duration: Double.random(in: 4.2...6.7),
                rotation: Double.random(in: 180...540),
                color: colors[Int.random(in: 0..<colors.count)],
                shape: Int.random(in: 0...3),
                flipDuration: Double.random(in: 1.2...2.6),
                axisX: Double.random(in: 0.2...1),
                axisY: Double.random(in: 0.2...1),
                swayAmount: CGFloat.random(in: 12...32),
                swayDuration: Double.random(in: 1.5...3)
            )
        }
    }()

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { context in
                let tempo = context.date.timeIntervalSince(inicio)

                ZStack {
                    ForEach(particles) { particle in
                        ConfettiParticleView(
                            particle: particle,
                            area: geometry.size,
                            tempo: tempo
                        )
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiParticle: Identifiable {
    let id: Int
    let x: CGFloat
    let drift: CGFloat
    let size: CGFloat
    let delay: Double
    let duration: Double
    let rotation: Double
    let color: Color
    let shape: Int
    let flipDuration: Double
    let axisX: Double
    let axisY: Double
    let swayAmount: CGFloat
    let swayDuration: Double
}

private struct ConfettiParticleView: View {

    let particle: ConfettiParticle
    let area: CGSize
    let tempo: Double

    // tempo desta peça, descontando o atraso inicial
    private var t: Double { tempo - particle.delay }

    // 0 = acabou de aparecer, 1 = já saiu pela parte de baixo
    private var progresso: Double {
        min(max(t / particle.duration, 0), 1)
    }

    private var visivel: Bool { t > 0 && progresso < 1 }

    // Papéis (retângulo e cápsula) são mais finos, como confete de verdade
    private var altura: CGFloat {
        particle.shape == 1 || particle.shape == 2
            ? particle.size * 0.6
            : particle.size
    }

    private var preenchimento: LinearGradient {
        LinearGradient(
            colors: [particle.color, particle.color.opacity(0.65)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        let giro3D = (t / particle.flipDuration) * 360
        let balanco = sin(t * 2 * .pi / particle.swayDuration)
            * particle.swayAmount

        formato
            .frame(width: particle.size, height: altura)
            .shadow(color: particle.color.opacity(0.35), radius: 2, y: 1)
            // giro em 3D: a peça "vira" no ar
            .rotation3DEffect(
                .degrees(giro3D),
                axis: (x: particle.axisX, y: particle.axisY, z: 0),
                perspective: 0.5
            )
            // giro no plano da tela
            .rotationEffect(.degrees(particle.rotation * progresso))
            .position(
                x: particle.x * area.width
                    + particle.drift * progresso
                    + balanco,
                y: -20 + progresso * (area.height + 60)
            )
            .opacity(visivel ? 1 : 0)
    }

    @ViewBuilder
    private var formato: some View {
        switch particle.shape {
        case 0:
            Circle().fill(preenchimento)
        case 1:
            Rectangle().fill(preenchimento)
        case 2:
            Capsule().fill(preenchimento)
        default:
            Diamond().fill(preenchimento)
        }
    }
}

private struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
 ⁠

---

### Arquivo: \⁠ ./challenge6/QRCodeSheetView.swift\ ⁠
⁠ swift
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

 ⁠

---

### Arquivo: \⁠ ./challenge6/SalaView.swift\ ⁠
⁠ swift
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
 ⁠

---

### Arquivo: \⁠ ./challenge6/RoletaView.swift\ ⁠
⁠ swift
//
//  SalaView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 04/11/26.
//

import SwiftUI

struct FatiaRoleta: Shape {
    let inicio: Angle
    let fim: Angle

    func path(in rect: CGRect) -> Path {
        let centro = CGPoint(x: rect.midX, y: rect.midY)
        let raio = min(rect.width, rect.height) / 2

        var path = Path()
        path.move(to: centro)

        path.addArc(
            center: centro,
            radius: raio,
            startAngle: inicio,
            endAngle: fim,
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

struct RoletaView: View {

    let participantes: [String]
    let vencedor: String?
    let sorteioID: UUID?

    @State private var rotacao: Double = 0

    private let cores: [Color] = [
        Color("AzulRoleta"), Color("LaranjaRoleta"), Color("RoxoRoleta"), Color("AzulClaroRoleta"),
        Color("Amarelo"), Color("AmareloRoleta"), Color("SalmaoRoleta")
    ]

    var body: some View {
        GeometryReader { geometry in

            let tamanho = min(
                geometry.size.width,
                geometry.size.height
            )

            let quantidade = participantes.count

            ZStack {

                // Disco da roleta
                ZStack {
                    if quantidade == 0 {
                        Circle()
                            .fill(.gray.opacity(0.2))

                        Text("Aguardando participantes")
                            .foregroundStyle(.secondary)

                    } else {
                        ForEach(participantes.indices, id: \.self) { indice in

                            let angulo = 360.0 / Double(quantidade)
                            let inicio = Double(indice) * angulo - 90
                            let fim = inicio + angulo
                            let meio = (inicio + fim) / 2

                            FatiaRoleta(
                                inicio: .degrees(inicio),
                                fim: .degrees(fim)
                            )
                            .fill(cores[indice % cores.count])
                            .overlay {
                                FatiaRoleta(
                                    inicio: .degrees(inicio),
                                    fim: .degrees(fim)
                                )
                                .stroke(.white, lineWidth: 2)
                            }

                            Text(participantes[indice])
                                .font(.system(
                                    size: quantidade > 8 ? 10 : 14,
                                    weight: .semibold
                                ))
                                .foregroundStyle(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width: tamanho * 0.30)
                                .rotationEffect(.degrees(meio))
                                .position(
                                    x: tamanho / 2 +
                                        cos(meio * .pi / 180) * tamanho * 0.30,
                                    y: tamanho / 2 +
                                        sin(meio * .pi / 180) * tamanho * 0.30
                                )
                        }
                    }

                    Circle()
                        .fill(.white)
                        .frame(width: 5, height: 5)
                }
                .rotationEffect(.degrees(rotacao))

                // Seta fixa no topo
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                    .position(
                        x: tamanho / 2,
                        y: -5
                    )
            }
            .frame(width: tamanho, height: tamanho)
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .onChange(of: sorteioID) { _, novoID in
            guard novoID != nil else { return }
            girarRoleta()
        }
    }

    private func girarRoleta() {
        guard let vencedor,
              let indice = participantes.firstIndex(of: vencedor),
              !participantes.isEmpty else {
            return
        }

        let anguloFatia = 360.0 / Double(participantes.count)

        // Centro da fatia do vencedor
        let centroFatia = (Double(indice) + 0.5) * anguloFatia

        // Rotação necessária para alinhar com a seta
        let ajuste = (360.0 - centroFatia)
            .truncatingRemainder(dividingBy: 360)

        // Posição atual da roleta
        let posicaoAtual = rotacao
            .truncatingRemainder(dividingBy: 360)

        // Distância positiva até o vencedor
        let distancia = (ajuste - posicaoAtual + 360)
            .truncatingRemainder(dividingBy: 360)

        // Três voltas completas + alinhamento final
        let rotacaoFinal = rotacao + 1080 + distancia

        withAnimation(.easeOut(duration: 5)) {
            rotacao = rotacaoFinal
        }
    }
}

// MARK: - Preview

#Preview {
    RoletaPreview()
}

private struct RoletaPreview: View {

    @State private var participantes = [
        "Gabriel", "Lucas", "Sarah"
    ]

    @State private var vencedor: String?
    @State private var sorteioID: UUID?

    var body: some View {
        VStack(spacing: 30) {

            Text("Roleta")
                .font(.largeTitle)
                .bold()

            RoletaView(
                participantes: participantes,
                vencedor: vencedor,
                sorteioID: sorteioID
            )
            .frame(width: 320, height: 320)

            Text("\(participantes.count) participantes")
                .foregroundStyle(.secondary)

            Button("Simular sorteio") {
                // Simula o vencedor enviado pelo backend
                vencedor = "Sarah"
                sorteioID = UUID()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }
}
 ⁠

---

### Arquivo: \⁠ ./challenge6/EntrarSalaView.swift\ ⁠
⁠ swift
//
//  EntrarSalaView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 29/10/26.
//

import SwiftUI

struct EntrarSalaView: View {

    @AppStorage("nickname") private var nickname = ""
    @State private var mostrandoScanner = false


    @State private var salaID = ""
    @State private var entrouNaSala = false
    @State private var clientService = ClientService()

    var body: some View {
        VStack(spacing: 24) {

            Image(systemName: "person.3.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)

            Text("Entrar na sala")
                .font(.largeTitle)
                .bold()

            TextField("Código da sala", text: $salaID)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()

            Button("Entrar") {
                mostrandoScanner = true
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
            .buttonStyle(.borderedProminent)
            .disabled(
                salaID.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
        }
        .padding()
        .alert("Entrada simulada", isPresented: $entrouNaSala) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(nickname), você entrou na sala \(salaID)!")
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./challenge6/QrCodeScanner.swift\ ⁠
⁠ swift
//
//  QrCodeScanner.swift
//  challenge6
//
//  Created by Lucas on 04/11/26.
//

import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerController {
        let vc = ScannerController()
        vc.onScan = onScan
        return vc
    }
    func updateUIViewController(_ uiViewController: ScannerController, context: Context) {}
}

final class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onScan: ((String) -> Void)?
    private let session = AVCaptureSession()
    private let preview = AVCaptureVideoPreviewLayer()
    private var didScan = false

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        preview.session = session
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview.frame = view.bounds
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !didScan,
              let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let text = obj.stringValue else { return }
        didScan = true
        session.stopRunning()
        onScan?(text)
    }
}

func parseHost(_ text: String) -> (host: String, port: UInt16)? {
    let parts = text.split(separator: ":")
    guard parts.count == 2, let port = UInt16(parts[1]) else { return nil }
    return (String(parts[0]), port)
}
 ⁠

---

### Arquivo: \⁠ ./challenge6/MyApp.swift\ ⁠
⁠ swift
import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./challenge6/QRCodeGenerator.swift\ ⁠
⁠ swift
//
//  QRCodeGenerator.swift
//  challenge6
//
//  Created by Gabriel Groppo on 29/10/26.
//


import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {

    private let context = CIContext()

    func gerarQRCode(
        texto: String,
        branco: Bool = false
    ) -> UIImage? {

        let gerador = CIFilter.qrCodeGenerator()
        gerador.message = Data(texto.utf8)
        gerador.correctionLevel = "H"

        guard let qrOriginal = gerador.outputImage else {
            return nil
        }

        let imagemFinal: CIImage

        if branco {
            let filtro = CIFilter.falseColor()
            filtro.inputImage = qrOriginal

            filtro.color0 = CIColor(color: .white)

            filtro.color1 = CIColor(
                red: 0,
                green: 0,
                blue: 0,
                alpha: 0
            )

            imagemFinal = filtro.outputImage ?? qrOriginal
        } else {
            imagemFinal = qrOriginal
        }

        let imagemAmpliada = imagemFinal.transformed(
            by: CGAffineTransform(scaleX: 10, y: 10)
        )

        guard let cgImage = context.createCGImage(
            imagemAmpliada,
            from: imagemAmpliada.extent
        ) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
 ⁠

---

### Arquivo: \⁠ ./challenge6/QrCodeAppClip.swift\ ⁠
⁠ swift
//
//  QrCodeAppClip.swift
//  challenge6
//
//  Created by Lucas on 05/11/26.
//

import SwiftUI

struct QrCodeAppClip: View {
    private let qrCodeGenerator = QRCodeGenerator()
    let salaID: String
    var body: some View {
        VStack(spacing: 24) {
                Text("App Clip")
                    .font(.largeTitle)
                    .bold()

            if let imagem = qrCodeGenerator.gerarQRCode(
                texto: "https://example.com/sala?id=\(salaID)"
            ) {
                Image(uiImage: imagem)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }

                Text("Escaneie com a câmera do iPhone para abrir o App Clip.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .presentationDetents([.medium])

    }
}
 ⁠

---

### Arquivo: \⁠ ./challenge6/Player.swift\ ⁠
⁠ swift
//
//  Player.swift
//  challenge6
//
//  Created by Lucas on 04/11/26.
//

import Foundation
import Network
import Combine

final class Player: ObservableObject, Identifiable {

    let id = UUID()
    let connection: NWConnection
    @Published var nickname: String?

    init(connection: NWConnection) {
        self.connection = connection
    }


    func receiveNickname(completion: @escaping (String) -> Void) {

        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: 1024
        ) { [weak self] data, _, _, error in

            guard error == nil,
                  let data,
                  let nickname = String(data: data, encoding: .utf8)
            else {
                return
            }

            let nick = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

            self?.nickname = nick
            completion(nick)
        }
    }
}
 ⁠

---

### Arquivo: \⁠ ./challenge6/ContentView.swift\ ⁠
⁠ swift
import SwiftUI

struct Sala: Identifiable, Hashable {
    let id: String
}

struct ContentView: View {

    @AppStorage("nickname") private var nickname = ""

    @State private var salaRecebidaID: String?
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
                SalaCriadaView(salaID: sala.id, hostService: server)
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
            .navigationDestination(isPresented: $entrouNaSala) {
                SalaView(salaID: <#String#>, hostService: <#HostService#>)
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
 ⁠

---

### Arquivo: \⁠ ./challenge6/SalaCriadaView.swift\ ⁠
⁠ swift
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
 ⁠

---


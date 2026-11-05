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
        .blue, .orange, .purple, .green,
        .pink, .cyan, .indigo, .mint
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
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width: tamanho * 0.30)
                                .rotationEffect(.degrees(meio + 90))
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
                        .frame(width: 24, height: 24)
                        .shadow(radius: 2)
                }
                .rotationEffect(.degrees(rotacao))

                // Seta fixa no topo
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.red)
                    .shadow(radius: 2)
                    .position(
                        x: tamanho / 2,
                        y: 4
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

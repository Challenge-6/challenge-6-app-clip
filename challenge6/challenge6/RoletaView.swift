//
//  RoletaView.swift
//  challenge6
//
//  Created by Gabriel Groppo on 04/11/26.
//


import SwiftUI

// Representa uma fatia da roleta
struct FatiaRoleta: Shape {
    let inicio: Angle
    let fim: Angle

    func path(in rect: CGRect) -> Path {
        let centro = CGPoint(
            x: rect.midX,
            y: rect.midY
        )

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

    private let cores: [Color] = [
        .blue,
        .orange,
        .purple,
        .green,
        .pink,
        .cyan,
        .indigo,
        .mint
    ]

    var body: some View {
        GeometryReader { geometry in

            let tamanho = min(
                geometry.size.width,
                geometry.size.height
            )

            let quantidade = participantes.count

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

                        // Nome dentro da fatia
                        Text(participantes[indice])
                            .font(.system(
                                size: quantidade > 8 ? 10 : 14,
                                weight: .semibold
                            ))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(width: tamanho * 0.30)
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
            .frame(width: tamanho, height: tamanho)
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// Preview interativo
#Preview {
    RoletaPreview()
}

private struct RoletaPreview: View {

    @State private var participantes = [
        "Gabriel",
        "Lucas",
        "Sarah"
    ]

    private let nomes = [
        "Ana", "Pedro", "Julia",
        "Rafael", "Beatriz", "Carlos"
    ]

    var body: some View {
        VStack(spacing: 30) {

            Text("Roleta dinâmica")
                .font(.largeTitle)
                .bold()

            RoletaView(participantes: participantes)
                .frame(width: 320, height: 320)

            Text("\(participantes.count) participantes")
                .foregroundStyle(.secondary)

            HStack {
                Button("Remover") {
                    if !participantes.isEmpty {
                        participantes.removeLast()
                    }
                }
                .disabled(participantes.isEmpty)

                Spacer()

                Button("Adicionar") {
                    let indice = participantes.count - 3

                    if indice >= 0 && indice < nomes.count {
                        participantes.append(nomes[indice])
                    }
                }
                .disabled(participantes.count >= 9)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

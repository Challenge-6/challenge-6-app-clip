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

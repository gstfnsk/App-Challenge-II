//
//  DiceButton.swift
//  Pickture
//
//  Created by Lorenzo Fortes on 23/09/25.
//
import SwiftUI

struct DiceButton: View {
    var imageName: String = "img-diceSymbol1" // use a imagem reta (recomendado)
    var size: CGSize = CGSize(width: 22.4, height: 24.3)
    var onShaken: (() -> Void)? = nil // callback para atualizar phrases, etc.
    @State private var rotation: Double = 0
    @State private var xOffset: CGFloat = 0
    @State private var scale: CGFloat = 1
    @State private var isAnimating = false

    var body: some View {
        Button {
            onShaken?()
            startShake(times: 2) // quantas "sacudidas"
        } label: {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
                .rotationEffect(.degrees(rotation))
                .offset(x: xOffset)
                .scaleEffect(scale)
                .background(
                    Circle()
                        .frame(width: 35, height: 36)
                        .foregroundStyle(Color.lilac)
                )
        }
    }

    private func startShake(times: Int = 1) {
        Task { await performShake(times: times) }
    }

    private func performShake(times: Int) async {
        if isAnimating { return } // evita overlap
        isAnimating = true

        // keyframes de rotação (graus). Ajuste para ficar mais/menos agressivo.
        let keyframes: [Double] = [-20, 18, -12, 8, -5, 3, 0]
        let frameDelayNs: UInt64 = 60_000_000 // 60ms por frame (ajustável)

        for _ in 0..<times {
            for deg in keyframes {
                await MainActor.run {
                    // animação spring para cada keyframe — mais natural
                    withAnimation(.interpolatingSpring(stiffness: 350, damping: 22)) {
                        rotation = deg
                        xOffset = CGFloat(deg / 6) // pequeno deslocamento horizontal dependente da rotação
                        scale = 1 + CGFloat(abs(deg)) / 1000 // leve scale para dar "peso"
                    }
                }
                try? await Task.sleep(nanoseconds: frameDelayNs)
            }
        }

        // garante reset final suave
        await MainActor.run {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                rotation = 0
                xOffset = 0
                scale = 1
            }
            isAnimating = false
        }
    }
}

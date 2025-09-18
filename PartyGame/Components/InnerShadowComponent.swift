//
//  InnerShadowComponent.swift
//  Pickture
//
//  Created by Rafael Toneto on 15/09/25.
//

import SwiftUI

public struct InnerShadowComponent: ViewModifier {
    public var color: Color
    public var radius: CGFloat
    public var yOffset: CGFloat
    public var spread: CGFloat
    public var cornerRadius: CGFloat
    public var blendMode: BlendMode

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)

        return content
            .overlay(
                shape
                    .stroke(color, lineWidth: 2)
                    .blur(radius: radius)
                    .offset(x: 0, y: yOffset)
                    .blendMode(blendMode)
                    .mask(
                        shape.fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .black, location: 0.0),
                                    .init(color: .black, location: spread),
                                    .init(color: .clear, location: spread)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    )
            )
            .clipShape(shape)
            .compositingGroup()
    }
}

public extension View {
    func innerTopShadow(
        color: Color = .black.opacity(0.18),
        radius: CGFloat = 4,
        yOffset: CGFloat = 1,
        spread: CGFloat = 0.55,
        cornerRadius: CGFloat = 20,
        blendMode: BlendMode = .plusDarker
    ) -> some View {
        modifier(InnerShadowComponent(
            color: color,
            radius: radius,
            yOffset: yOffset,
            spread: spread,
            cornerRadius: cornerRadius,
            blendMode: blendMode
        ))
    }
}

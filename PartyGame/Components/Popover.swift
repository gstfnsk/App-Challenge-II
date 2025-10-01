//
//  Popover.swift
//  Pickture
//
//  Created by Giulia Stefainski on 30/09/25.
//

import SwiftUI



struct ArrowPopover<Content: View>: View {
    let arrowEdge: Edge
    let content: Content
    
    init(arrowEdge: Edge = .top, @ViewBuilder content: () -> Content) {
        self.arrowEdge = arrowEdge
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
                popoverBody
                arrow
        }
    }
    
    private var popoverBody: some View {
        content
            .padding()
            .background(Color.darkerPurple)
            .cornerRadius(32)
    }
    
    struct RoundedTipTriangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()

            let left = CGPoint(x: rect.minX, y: rect.maxY)  // canto inferior esquerdo
            let right = CGPoint(x: rect.maxX, y: rect.maxY) // canto inferior direito

            // começa no canto esquerdo
            path.move(to: left)
            // linha até o canto direito
            path.addLine(to: right)
            path.addQuadCurve(to: left, control: CGPoint(x: rect.midX, y: rect.minY + 6))

            path.closeSubpath()
            return path
        }
    }
    
    var arrow: some View {
        RoundedTipTriangle()
            .fill(Color.darkerPurple)
            .frame(width: 50, height: 45)
            .rotationEffect(arrowEdge == .top ? .degrees(0) : .degrees(180))
    }
}

//struct RoundedTriangle: Shape {
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
//        path.close()
//        
//        path.lineJoinStyle = .round
//        
//        return Path(path.cgPath)
//    }
//}

//#Preview {
//    Popover()
//}

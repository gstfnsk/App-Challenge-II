//
//  SliderView.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 11/09/25.
//

import SwiftUI

struct SliderView: View {
    var knobPadding: CGFloat = 8
    var latchesOn: Bool = false
    var onComplete: ((Bool) -> Void) = { _ in }
    var onDrag: (Double) -> () = { _ in }
    
    
    var contentsClipped: Bool = false
    
    
    @State private var knobXOffset: CGFloat = 0
    @State private var knobWidth: CGFloat = 0
    @State private var trackWidth: CGFloat = 0
    @State private var didComplete = false
    @State private var foregroundContentWidth: CGFloat = 0
    @State private var knobStartOffset: CGFloat = 0
    
    var configuration: SliderViewConfiguration = .init()
    var body: some View {
        GeometryReader { geom in
            ZStack(alignment: .leading) {
                
                configuration.background
                configuration.foreground
                
                ZStack {
                    configuration.track
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear { trackWidth = proxy.size.width }
                                    .onChange(of: proxy.size.width) { _, new in
                                        trackWidth = new
                                    }
                            }
                        )
                    configuration.knob
                    
                    
                }
                .onGeometryChange(for: CGSize.self, of: { proxy in
                    proxy.size // get the modified view's size
                }, action: { size in
                    self.knobWidth = size.width
                })
                .offset(x: knobXOffset)
                .gesture(dragGesture(with: geom), isEnabled: !didComplete || !latchesOn)
            }
        }
        .frame(height: 60)
        
    }
    
    private func dragGesture(with geomProxy: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let geomFrame = geomProxy.frame(in: .local)
                
                let maxXOffset = geomFrame.width - knobWidth - knobPadding
                
                let newOffset = knobStartOffset + value.translation.width
                knobXOffset = min(max(newOffset, 0), maxXOffset)
                
                let progress = max(0, min(knobXOffset / maxXOffset, 1))
                onDrag(progress)
                
                
                //                if progress >= 0.8 && !didComplete {
                //                    didComplete = true
                //                    onComplete(true)
                //                } else if progress == 0 && didComplete {
                //                    didComplete = false
                //                    onComplete(false)
                //                }
            }
            .onEnded { _ in
                knobStartOffset = knobXOffset
                
                // Optional: Add snap-to-end behavior
                let geomFrame = geomProxy.frame(in: .local)
                let maxXOffset = geomFrame.width - knobWidth - knobPadding
                var progress = maxXOffset > 0 ? knobXOffset / maxXOffset : 0
                
                if progress >= 0.8 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        knobXOffset = maxXOffset
                        knobStartOffset = maxXOffset
                    }
                    if !didComplete {
                        didComplete = true
                        onComplete(true)
                    }
                } else {
                    withAnimation(.easeOut) {
                        knobXOffset = 0
                        knobStartOffset = 0
                    }
                    progress = 0
                    didComplete = false
                    onComplete(false)
                    
                }
            }
    }
}



#Preview {
    SliderView(
        latchesOn: false,
        
        onComplete: { isReady in
        },
        onDrag: { progress in
            //Atualizar UI enquanto Drag
        },configuration: SliderViewConfiguration {
            ZStack(alignment: .center){
                Capsule()
                    .fill(Color.red)
                    .frame(height: 53)
                    .frame(maxWidth: .infinity)
                Text("ready?")
            }
        } foreground: {
            EmptyView()
        } track: {
            Circle()
                .frame(height: 40)
                .foregroundStyle(Color.white)
                .padding(8)
        } knob: {
            Image(systemName: "chevron.right")
                .foregroundStyle(.black)
        }
    )
}

//
//  SliderViewConfiguration.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 11/09/25.
//

import Foundation
import SwiftUI

struct SliderViewConfiguration {
    public let background: AnyView
    public let foreground: AnyView
    public let track: AnyView
    public let knob: AnyView
    
    public init<Background: View, Foreground: View, Knob: View, Track: View>(
        @ViewBuilder background: () -> Background,
        @ViewBuilder foreground: () -> Foreground,
        @ViewBuilder track: () -> Track,
        @ViewBuilder knob: () -> Knob
    ) {
        self.background = AnyView(background())
        self.foreground = AnyView(foreground())
        self.track = AnyView(track())
        self.knob = AnyView(knob())
    }
    
    public init(
        knobPadding: CGFloat = 8
    ) {
        self.background = AnyView(EmptyView())
        self.foreground = AnyView(EmptyView())
        self.track = AnyView(Capsule().fill(.tint.quaternary))
        self.knob = AnyView(Circle().fill(.tint).padding(knobPadding))
    }
    
    public init<Background: View, Foreground: View>(
        knobPadding: CGFloat = 8,
        @ViewBuilder background: () -> Background,
        @ViewBuilder foreground: () -> Foreground
    ) {
        self.background = AnyView(background())
        self.foreground = AnyView(foreground())
        self.track = AnyView(Capsule().fill(.tint.quaternary))
        self.knob = AnyView(Circle().fill(.tint).padding(knobPadding))
    }

}

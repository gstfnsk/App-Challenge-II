//
//  AppResetManagerViewModel.swift
//  Pickture
//
//  Created by Giulia Stefainski on 01/10/25.
//

import Foundation
import SwiftUI

class AppResetManagerViewModel: ObservableObject {
    @Published var resetID = UUID()
    
    func resetApp() {
        resetID = UUID()
    }
}

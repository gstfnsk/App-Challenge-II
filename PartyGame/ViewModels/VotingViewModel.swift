//
//  VotingViewModel.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import Foundation
import SwiftUI

@Observable
final class VotingViewModel {
    func voteImage(image: String) {
        print("you voted \(image)")
        // save vote something
    }
    func loadImage(name: String) -> UIImage? {
        if let resourcePath = Bundle.main.resourcePath {
            let path = "\(resourcePath)/\(name).jpeg"
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
}

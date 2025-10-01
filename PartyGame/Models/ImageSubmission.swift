//
//  PlayerSubmission.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//

import SwiftUI

struct ImageSubmission: Identifiable, Hashable, Codable {
    let id: UUID
    let playerID: String
    let image: Data?
    let submissionTime: Date
    
    var uiImage: UIImage? {
        guard let image else { return nil }
        return UIImage(data: image)
    }
    
    init(playerID: String, image: Data?, submissionTime: Date) {
        self.id = UUID()
        self.playerID = playerID
        self.image = image
        self.submissionTime = submissionTime
    }
}

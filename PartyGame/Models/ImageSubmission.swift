//
//  PlayerSubmission.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//

import SwiftUI

class ImageSubmission: Identifiable, Hashable, Equatable {
    static func == (lhs: ImageSubmission, rhs: ImageSubmission) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID()
    let image: Data?
    let submissionTime: Date
    
    var uiImage: UIImage? {
        guard let image else { return nil }
        return UIImage(data: image)
    }
    
    init(image: Data, submissionTime: Date) {
        self.image = image
        self.submissionTime = submissionTime
    }
}

//
//  PlayerSubmission.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//


import SwiftUI

class ImageSubmission: Identifiable {
    let id = UUID()
    let image: Data?
    let submissionTime: Date
    
    var uiImage: UIImage? {
            guard let image else { return nil }
            return UIImage(data: image)
        }
    
    init(image: Data?, submissionTime: Date) {
        self.image = image
        self.submissionTime = submissionTime
    }
}

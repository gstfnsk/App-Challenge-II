//
//  GamePhase.swift
//  Pickture
//
//  Created by Fernando Sulzbach on 08/10/25.
//

enum GamePhase: Hashable, CaseIterable, Codable {
    case lobby
    case phraseSelection
    case imageSelection
    case voting
}

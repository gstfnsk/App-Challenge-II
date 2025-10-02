//
//  GameCenterServiceProtocol.swift
//  Pickture
//
//  Created by Rafael Toneto on 02/10/25.
//

import Foundation
import Combine
import GameKit

protocol GameCenterServiceProtocol {
    var gamePlayersSnapshot: [Player] { get }
    var readyMapSnapshot: [String: Bool] { get }
    var messagesSnapshot: [String] { get }
    var isInMatchSnapshot: Bool { get }

    var gamePlayersPublisher: AnyPublisher<[Player], Never> { get }
    var readyMapPublisher: AnyPublisher<[String: Bool], Never> { get }
    var messagesPublisher: AnyPublisher<[String], Never> { get }
    var isInMatchPublisher: AnyPublisher<Bool, Never> { get }

    func sendMessage(_ text: String)
    func leaveMatch()
    func toggleReady()
    func resetReadyForAllPlayers()
}

extension GameCenterService: GameCenterServiceProtocol {
    var gamePlayersSnapshot: [Player] { gamePlayers }
    var readyMapSnapshot: [String : Bool] { readyMap }
    var messagesSnapshot: [String] { messages }
    var isInMatchSnapshot: Bool { isInMatch }

    var gamePlayersPublisher: AnyPublisher<[Player], Never> { $gamePlayers.eraseToAnyPublisher() }
    var readyMapPublisher: AnyPublisher<[String : Bool], Never> { $readyMap.eraseToAnyPublisher() }
    var messagesPublisher: AnyPublisher<[String], Never> { $messages.eraseToAnyPublisher() }
    var isInMatchPublisher: AnyPublisher<Bool, Never> { $isInMatch.eraseToAnyPublisher() }

    func resetReadyForAllPlayers() {
        resetReadyForAllPlayers(broadcast: true)
    }
}

//
//  MockGameCenterService.swift
//  PicktureTests
//
//  Created by Rafael Toneto on 02/10/25.
//

import Combine
@testable import Pickture


final class MockGameCenterService: GameCenterServiceProtocol {

    let gamePlayersSubject = CurrentValueSubject<[Player], Never>([])
    let readyMapSubject    = CurrentValueSubject<[String: Bool], Never>([:])
    let messagesSubject    = CurrentValueSubject<[String], Never>([])
    let isInMatchSubject   = CurrentValueSubject<Bool, Never>(false)

    var gamePlayersSnapshot: [Player] { gamePlayersSubject.value }
    var readyMapSnapshot: [String : Bool] { readyMapSubject.value }
    var messagesSnapshot: [String] { messagesSubject.value }
    var isInMatchSnapshot: Bool { isInMatchSubject.value }

    var gamePlayersPublisher: AnyPublisher<[Player], Never> { gamePlayersSubject.eraseToAnyPublisher() }
    var readyMapPublisher: AnyPublisher<[String : Bool], Never> { readyMapSubject.eraseToAnyPublisher() }
    var messagesPublisher: AnyPublisher<[String], Never> { messagesSubject.eraseToAnyPublisher() }
    var isInMatchPublisher: AnyPublisher<Bool, Never> { isInMatchSubject.eraseToAnyPublisher() }

    private(set) var lastSentMessage: String?
    private(set) var toggleReadyCount = 0
    private(set) var resetReadyCount  = 0
    private(set) var leaveMatchCount  = 0

    func sendMessage(_ text: String) { lastSentMessage = text }
    func leaveMatch() { leaveMatchCount += 1 }
    func toggleReady() { toggleReadyCount += 1 }
    func resetReadyForAllPlayers() { resetReadyCount += 1 }
}

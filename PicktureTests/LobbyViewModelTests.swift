//
//  LobbyViewModelTests.swift
//  PicktureTests
//
//  Created by Rafael Toneto on 02/10/25.
//

import Combine
import Testing
import GameKit
@testable import Pickture

@MainActor
struct LobbyViewModelTests {

    @Test
    func sendMessage_trims_and_delegates() async throws {
        let mock = MockGameCenterService()
        let vm = LobbyViewModel(service: mock)

        vm.typedMessage = "   hello  "
        vm.sendMessage()

        #expect(mock.lastSentMessage == "hello")
        #expect(vm.typedMessage.isEmpty)
    }

    @Test
    func sendMessage_ignores_empty() async throws {
        let mock = MockGameCenterService()
        let vm = LobbyViewModel(service: mock)

        vm.typedMessage = "   "
        vm.sendMessage()

        #expect(mock.lastSentMessage == nil)
        #expect(vm.typedMessage == "   ")
    }

    @Test
    func delegates_toggle_and_reset() async throws {
        let mock = MockGameCenterService()
        let vm = LobbyViewModel(service: mock)

        vm.toggleReady()
        vm.resetAllPlayersReady()

        #expect(mock.toggleReadyCount == 1)
        #expect(mock.resetReadyCount == 1)
    }

    @Test
    func maps_raw_messages_into_chat_items() async throws {
        let mock = MockGameCenterService()
        let vm = LobbyViewModel(service: mock)

        mock.messagesSubject.send(["You: Hi there", "Alice: hello!"])

        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(vm.messages.count == 2)
        #expect(vm.chat.count == 2)

        #expect(vm.chat[0].isLocal == true)
        #expect(vm.chat[0].text == "Hi there")

        #expect(vm.chat[1].senderName == "Alice")
        #expect(vm.chat[1].isLocal == false)
        #expect(vm.chat[1].text == "hello!")
    }

    @Test
    func builds_playerRows_from_players_and_readyMap() async throws {
        let mock = MockGameCenterService()
        let vm = LobbyViewModel(service: mock)

        let local = GKLocalPlayer.local
        let localID = local.gamePlayerID

        mock.gamePlayersSubject.send([Player(player: local)])
        mock.readyMapSubject.send([localID: true])

        try await Task.sleep(nanoseconds: 80_000_000)

        #expect(vm.playerRows.count == 1)
        #expect(vm.playerRows[0].id == localID)
        #expect(vm.playerRows[0].isMe == true)
        #expect(vm.playerRows[0].isReady == true)
        #expect(vm.allReady == true)
    }

    @Test
    func leaveLobby_delegates_to_service() async throws {
        let mock = MockGameCenterService()
        let vm = LobbyViewModel(service: mock)

        vm.leaveLobby()
        #expect(mock.leaveMatchCount == 1)
    }
}

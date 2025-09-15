import Foundation
import Combine
import GameKit

final class MockGameCenterService: GameCenterService {
    override func sendMessage(_ text: String) {
        messages.append(text)
    }
    
    override func leaveMatch() {
        isInMatch = false
    }
    
    override func toggleReady() {
        let id = GKLocalPlayer.local.gamePlayerID
        readyMap[id] = !(readyMap[id] ?? false)
    }
}


class MockPlayer: GKPlayer {
    private let mockID: String
    private let mockName: String
    
    init(id: String, name: String) {
        self.mockID = id
        self.mockName = name
        super.init()
    }
    
    override var gamePlayerID: String { mockID }
    override var displayName: String { mockName }
}

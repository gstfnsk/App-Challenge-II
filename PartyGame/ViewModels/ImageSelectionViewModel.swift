//
//  ImageSelectionViewModel.swift
//  PartyGame
//
//  Created by Rafael Toneto on 11/09/25.
//

import SwiftUI
import GameKit
import Combine

final class ImageSelectionViewModel: ObservableObject {
    @Published var errorMessage: String?

    @Published var selectedPhrase: [String] = []
    @Published var currentPhrase: String = ""
    
    @Published var playerSubmissions: [PlayerSubmission] = []
    @Published private(set) var hasSubmitted = false
    
    var players: [GKPlayer] = []
    var readyMap: [String: Bool] = [:]
    
    private var timer: Timer?
    @Published var hasProcessedTimeRunOut: Bool = false
    @Published var remainingTimeDouble: Double = 60.0
    @Published var timeRemaining: Int = 60
    
    let service = GameCenterService.shared
    private var cancellables: Set<AnyCancellable> = []

    init() {
        
        self.players = service.gamePlayers.map { $0.player as! GKPlayer }
   
        service.$readyMap
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] newMap in
                        self?.readyMap = newMap[.imageSelection] ?? [:]
                    }
                    .store(in: &cancellables)
        
        service.$phrases
            .receive(on: DispatchQueue.main)
            .assign(to: &$selectedPhrase)
        
        service.$currentPhrase
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentPhrase)
        
        service.$playerSubmissions
            .receive(on: DispatchQueue.main)
            .assign(to: &$playerSubmissions)
        
        service.$timerStart
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] target in
                self?.startCountdown(until: target)
            }
            .store(in: &cancellables)
        
    }
    
    deinit {
        timer?.invalidate()
        cancellables.forEach { $0.cancel() }
    }
    
    var allReady: Bool {
        guard !players.isEmpty else { return false }
        for p in players {
            if readyMap[p.gamePlayerID] != true { return false }
        }
        return true
    }
    
    func resetAllPlayersReady() {
        service.resetReadyForAllPlayers(gamePhase: .imageSelection)
    }
    
    func toggleReady() {
        service.setReady(gamePhase: .imageSelection)
    }
    
    var haveAllPlayersSubmittedImg: Bool {
        service.haveAllPlayersSubmittedImage()
    }

//    func chooseCamera() {
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//            errorMessage = "Câmera não disponível neste dispositivo."
//            return
//        }
//        //isShowingCamera = true
//    }
    
    func setCurrentRandomPhrase() -> String {
        
        if currentPhrase.isEmpty && service.phraseLeaderID == nil {
            service.initiatePhraseSelection()
        }
        return currentPhrase
    }

//    func chooseLibrary() {
//        isShowingLibrary = true
//    }
    
    func submitSelectedImage(image: UIImage) {
        let maxWidth: CGFloat = 600
        let scale = min(1, maxWidth / image.size.width)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let resized = resizedImage else {
            errorMessage = "Falha ao redimensionar a imagem."
            return
        }

        guard let data = resized.jpegData(compressionQuality: 0.1) else {
            errorMessage = "Falha ao preparar a imagem."
            return
        }

        let player = GKLocalPlayer.local.gamePlayerID
        let imageSubmission = ImageSubmission(playerID: player, image: data, submissionTime: Date())
        let phrase = currentPhrase
        service.addSubmission(playerID: player, phrase: phrase, image: imageSubmission)

        hasSubmitted = true
        
        print("Imagem pronta para envio, tamanho em bytes:", data.count)
    }
    
    func getSubmittedImages() -> [ImageSubmission] {
        return service.playerSubmissions.map { $0.imageSubmission }
    }
    
    private func startCountdown(until target: Date) {
        timer?.invalidate()
        timer = nil
        timeRemaining = 60
        updateRemaining(target: target)
        hasProcessedTimeRunOut = false
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateRemaining(target: target)
        }
        
        
    }
    
    private func updateRemaining(target: Date) {
        let remainingSecondsDouble = target.timeIntervalSinceNow
        
        timeRemaining = max(0, Int(ceil(remainingSecondsDouble)))
        remainingTimeDouble = max(0.0, remainingSecondsDouble)
        
        if timeRemaining == 0  {
            timer?.invalidate()
            
            if !hasProcessedTimeRunOut {
                hasProcessedTimeRunOut = true

            }
        }
    }
    
    func startPhase() {
        print("🚀 Starting phase - resetting all states")
        hasProcessedTimeRunOut = false
        remainingTimeDouble = 60.0
        timeRemaining = 60
        
        service.schedulePhaseStart(delay: 60)
    }
    
   

}

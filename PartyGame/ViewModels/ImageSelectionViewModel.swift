//
//  ImageSelectionViewModel.swift
//  PartyGame
//
//  Created by Rafael Toneto on 11/09/25.
//

import SwiftUI
import GameKit
import Combine

@Observable
class ImageSelectionViewModel {
    var errorMessage: String?

    var selectedPhrase: [String] { service.phrases }
    var currentPhrase: String { service.currentPhrase }
    
    var playerSubmissions: [PlayerSubmission] { service.playerSubmissions }
    private(set) var hasSubmitted = false
    
    var players: [GKPlayer] { service.gamePlayers.map { $0.player } }
    var readyMap: [String: Bool] { service.readyMap[.imageSelection] ?? [:] }
    
    private var timer: Timer?
    var hasProcessedTimeRunOut: Bool = false
    var remainingTimeDouble: Double = 60.0
    var timeRemaining: Double = 60
    
    let service = GameCenterService.shared
    
    init() {
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
        return service.getSubmittedImages()
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
        
        timeRemaining = max(0, ceil(remainingSecondsDouble))
        remainingTimeDouble = max(0.0, remainingSecondsDouble)
        
        if timeRemaining == 0  {
            timer?.invalidate()
            
            if !hasProcessedTimeRunOut {
                hasProcessedTimeRunOut = true

            }
        }
    }

    
   

}

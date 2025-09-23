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
    @Published var isShowingCamera = false
    @Published var isShowingLibrary = false
    
    @Published var selectedImage: UIImage?

    @Published var selectedPhrase: [String] = []
    @Published var currentPhrase: String = ""
    
    @Published var playerSubmissions: [PlayerSubmission] = []
    
    @Published private(set) var hasSubmitted = false
    //@Published private(set) var isLocalReady = false
    
    private let service = GameCenterService.shared
    private var cancellables: Set<AnyCancellable> = []

    init() {
        
        service.$phrases
            .receive(on: DispatchQueue.main)
            .assign(to: &$selectedPhrase)
        
        service.$currentPhrase
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentPhrase)
        
        service.$playerSubmissions
            .receive(on: DispatchQueue.main)
            .assign(to: &$playerSubmissions)
        
//        service.$readyMap
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] map in
//                guard let self = self else { return }
//                let localID = GKLocalPlayer.local.gamePlayerID
//                self.isLocalReady = map[localID] ?? false
//            }
//            .store(in: &cancellables)
    }
    
    var haveAllPlayersSubmittedImg: Bool {
        service.haveAllPlayersSubmittedImage()
    }

    func chooseCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            errorMessage = "Câmera não disponível neste dispositivo."
            return
        }
        isShowingCamera = true
    }
    
    func setCurrentRandomPhrase() -> String {
        
        if currentPhrase.isEmpty && service.phraseLeaderID == nil {
            service.initiatePhraseSelection()
        }
        return currentPhrase
    }

    func chooseLibrary() {
        isShowingLibrary = true
    }

//    func handlePickedImage(_ image: UIImage, selectedPhrase: String) {
//        selectedImage = image
//        errorMessage = nil
//
//        guard let data = image.jpegData(compressionQuality: 0.01) else {
//            errorMessage = "Falha ao preparar a imagem."
//            return
//        }
//
//        let player = GKLocalPlayer.local.gamePlayerID
//        let imageSubmission = ImageSubmission(playerID: player, image: data, submissionTime: Date())
//        let phrase = selectedPhrase
//        GameCenterService.shared.addSubmission(playerID: player, phrase: phrase, image: imageSubmission)
//        hasSubmitted = true
//    }
    
    func handlePickedImage(_ image: UIImage, selectedPhrase: String) {
        selectedImage = image
        errorMessage = nil
    }
    
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

//    func toggleReady() {
//        service.toggleReady()
//    }

//    func clear() {
//        selectedImage = nil
//        hasSubmitted = false
//        errorMessage = nil
//    }
}

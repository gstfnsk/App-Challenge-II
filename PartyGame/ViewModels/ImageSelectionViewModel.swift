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

    @Published private(set) var hasSubmitted = false
    @Published private(set) var isLocalReady = false

    private let service: GameCenterService
    private let onSubmit: (ImageSubmission) -> Void
    private var cancellables: Set<AnyCancellable> = []

    init(service: GameCenterService,
         onSubmit: @escaping (ImageSubmission) -> Void) {
        self.service = service
        self.onSubmit = onSubmit

        service.$readyMap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] map in
                guard let self = self else { return }
                let localID = GKLocalPlayer.local.gamePlayerID
                self.isLocalReady = map[localID] ?? false
            }
            .store(in: &cancellables)
    }


    func chooseCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            errorMessage = "Câmera não disponível neste dispositivo."
            return
        }
        isShowingCamera = true
    }

    func chooseLibrary() {
        isShowingLibrary = true
    }

    func handlePickedImage(_ image: UIImage) {
        selectedImage = image
        errorMessage = nil

        guard let data = image.jpegData(compressionQuality: 0.7) else {
            errorMessage = "Falha ao preparar a imagem."
            return
        }

        let submission = ImageSubmission(image: data, submissionTime: Date())
        onSubmit(submission)
        hasSubmitted = true
    }

    func send() {
        guard let image = selectedImage else {
            errorMessage = "Selecione ou tire uma foto antes de enviar."
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            errorMessage = "Falha ao preparar a imagem."
            return
        }
        let submission = ImageSubmission(image: data, submissionTime: Date())
        onSubmit(submission)
        hasSubmitted = true
    }

    func toggleReady() {
        service.toggleReady()
    }

    func clear() {
        selectedImage = nil
        hasSubmitted = false
        errorMessage = nil
    }
}

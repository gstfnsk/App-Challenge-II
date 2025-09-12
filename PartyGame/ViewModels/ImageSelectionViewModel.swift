//
//  ImageSelectionViewModel.swift
//  PartyGame
//
//  Created by Rafael Toneto on 11/09/25.
//

import SwiftUI

final class ImageSelectionViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isShowingCamera = false
    @Published var isShowingLibrary = false

    @Published var selectedImage: UIImage?

    private let onSubmit: (ImageSubmission) -> Void

    init(onSubmit: @escaping (ImageSubmission) -> Void) {
        self.onSubmit = onSubmit
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
    }

    func clear() {
        selectedImage = nil
        errorMessage = nil
    }
}

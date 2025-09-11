//
//  ImageSelectionViewModel.swift
//  PartyGame
//
//  Created by Rafael Toneto on 11/09/25.
//

import SwiftUI

final class ImageSelectionViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var errorMessage: String?

    @Published var isShowingCamera = false
    @Published var isShowingLibrary = false

    private let onImageSelected: (Data) -> Void

    init(onImageSelected: @escaping (Data) -> Void) {
        self.onImageSelected = onImageSelected
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
        onImageSelected(data)
    }

    func clear() {
        selectedImage = nil
        errorMessage = nil
    }
}

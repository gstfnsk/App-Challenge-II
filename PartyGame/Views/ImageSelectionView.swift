//
//  ImageSelectionView.swift
//  PartyGame
//
//  Created by Rafael Toneto on 11/09/25.
//

import SwiftUI
import GameKit

struct ImageSelectionView: View {
    @ObservedObject var viewModel: ImageSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSourceMenu = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Button {
                showSourceMenu = true
            } label: {
                Text("Selecionar imagem")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
        .navigationTitle("Imagem")
        .navigationBarTitleDisplayMode(.inline)

        .confirmationDialog("Escolher origem", isPresented: $showSourceMenu, titleVisibility: .visible) {
            Button("Tirar foto") { viewModel.chooseCamera() }
            Button("Escolher da Galeria") { viewModel.chooseLibrary() }
            Button("Cancelar", role: .cancel) { }
        }

        .sheet(isPresented: $viewModel.isShowingCamera) {
            ImagePicker(sourceType: .camera, allowsEditing: false) { img in
                viewModel.handlePickedImage(img)
                dismiss()
            }
        }
        .sheet(isPresented: $viewModel.isShowingLibrary) {
            ImagePicker(sourceType: .photoLibrary, allowsEditing: false) { img in
                viewModel.handlePickedImage(img)
                dismiss()
            }
        }
    }
}

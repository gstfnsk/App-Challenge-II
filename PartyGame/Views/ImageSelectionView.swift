//
//  ImageSelectionView.swift
//  PartyGame
//
//  Created by Rafael Toneto on 11/09/25.
//

import SwiftUI
import GameKit

struct ImageSelectionView: View {
    @ObservedObject var viewModel = ImageSelectionViewModel()
    @State private var showSourceMenu = false
    @State var selectedPhrase: String = ""
    @State var goToVotingView: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(selectedPhrase)
            
            Group {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.secondary.opacity(0.3)))
                        .padding(.horizontal)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.secondary.opacity(0.08))
                            .frame(height: 220)
                        VStack(spacing: 6) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 34))
                                .foregroundStyle(.secondary)
                            Text("Nenhuma imagem selecionada")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Button {
                showSourceMenu = true
            } label: {
                Text("Selecionar imagem")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            
            Button {
                goToVotingView = true
                viewModel.toggleReady()
                if viewModel.haveAllPlayersSubmitted {
                    goToVotingView = true
                }
            } label: {
                Text(viewModel.isLocalReady ? "Cancelar ready" : "Ready")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.hasSubmitted)
            .padding(.horizontal)
            .opacity(viewModel.hasSubmitted ? 1.0 : 0.5)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            selectedPhrase = viewModel.getRandomPhrase()
        }
        .navigationTitle("Imagem")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToVotingView) {
            VotingView(phrase: selectedPhrase)
        }
        
        .confirmationDialog("Escolher origem", isPresented: $showSourceMenu, titleVisibility: .visible) {
            Button("Tirar foto") { viewModel.chooseCamera() }
            Button("Escolher da Galeria") { viewModel.chooseLibrary() }
            Button("Cancelar", role: .cancel) { }
        }
        
        .sheet(isPresented: $viewModel.isShowingCamera) {
            ImagePicker(sourceType: .camera, allowsEditing: false) { img in
                viewModel.handlePickedImage(img, selectedPhrase: selectedPhrase)             }
        }
        .sheet(isPresented: $viewModel.isShowingLibrary) {
            ImagePicker(sourceType: .photoLibrary, allowsEditing: false) { img in
                viewModel.handlePickedImage(img, selectedPhrase: selectedPhrase)
            }
        }
    }
}


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
    
    @State var goToStackView: Bool = false
    
    @State var currentPhrase: String = ""
    
    @State var playerReady: Bool = false
    
    @State var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            
            if currentPhrase.isEmpty {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Aguardando frase...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                Text(currentPhrase)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Group {
                if let image = selectedImage {
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
            .disabled(playerReady ? true : false)
            
            Button {
                if let selectedImage = selectedImage {
                    viewModel.submitSelectedImage(image: selectedImage)
                    playerReady = true
                }
            } label: {
                Text(playerReady ? "Cancelar ready" : "Ready")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .disabled(playerReady ? true : false)
            .padding(.horizontal)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            currentPhrase = viewModel.setCurrentRandomPhrase()
        }
        .onReceive(viewModel.$currentPhrase) { currentPhrase in
            self.currentPhrase = currentPhrase
        }
        .onChange(of: viewModel.haveAllPlayersSubmittedImg) {
            goToStackView = true
        }
        
        .navigationTitle("Imagem")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToStackView) {
            
            ImageStackView(viewModel: ImageStackViewModel(), imageSubmissions: viewModel.getSubmittedImages())
        }
        
        .confirmationDialog("Escolher origem", isPresented: $showSourceMenu, titleVisibility: .visible) {
            Button("Tirar foto") { viewModel.chooseCamera() }
            Button("Escolher da Galeria") { viewModel.chooseLibrary() }
            Button("Cancelar", role: .cancel) { }
        }
        
        .sheet(isPresented: $viewModel.isShowingCamera) {
            ImagePicker(sourceType: .camera, allowsEditing: false) { img in
                selectedImage = img
            }
        }
        .sheet(isPresented: $viewModel.isShowingLibrary) {
            ImagePicker(sourceType: .photoLibrary, allowsEditing: false) { img in
                selectedImage = img
            }
        }
    }
}


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
    @State private var isShowingCamera = false
    @State private var isShowingLibrary = false
    @State private var showSourceMenu = false
    
    @State var goToStackView: Bool = false
    
    @State var currentPhrase: String = ""
    
    @State var playerReady: Bool = false
    
    @State var selectedImage: UIImage?
    
    var body: some View {
        ZStack{
            Image("img-textureI")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                VStack(spacing: 24) {
                    VStack(spacing: 5) {
                        Text("round \(viewModel.service.currentRound)")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.lilac)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack (spacing: 42) {
                            Text("send a pickture")
                                .font(.custom("DynaPuff-Medium", size: 28))
                                .foregroundStyle(.ice
                                    .shadow(.inner(color: .lilac, radius: 2, y: 3)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            TimerComponent(duration: 30.0)
                        }
                    }
                    ProgressBarComponent(duration: 30.0)
                }
                .safeAreaPadding(.top, 32)
                .padding(.horizontal)
                
                VStack(spacing: 90) {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("the phrase is:")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundStyle(.ice)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\"\(currentPhrase)\"")
                                .font(.custom("Dynapuff-Regular", size: 22))
                                .foregroundStyle(.ice)
                                .lineLimit(6)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: 297, alignment: .leading)
                                .padding(.bottom, 28)
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 26).fill(Color.lighterPurple))
                        
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 300, maxHeight: 280)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(RoundedRectangle(cornerRadius: 24).stroke(.lighterPurple, lineWidth: 3))
                                .padding(.horizontal)
                                .onTapGesture {
                                    showSourceMenu = true
                                }
                                .confirmationDialog("Escolher origem", isPresented: $showSourceMenu) {
                                    Button("Tirar foto") { isShowingCamera = true }
                                    Button("Escolher da Galeria") { isShowingLibrary = true }
                                    Button("Cancelar", role: .cancel) { }
                                }
                        } else {
                            VStack(spacing: 8) {
                                
                                Spacer(minLength: 8)
                                    .frame(maxHeight: 114)
                                
                                Image("img-addImage")
                                    .padding(.horizontal, 100)
                                
                                Text("click to add")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .underline()
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.horizontal, 100)
                                
                                Spacer(minLength: 8)
                                    .frame(maxHeight: 114)
                                    
                            }
                            .padding(.bottom)
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 26)
                                .fill(Color.lighterPurple.shadow(.inner(color: .darkerPurple, radius: 2, y: 3))))
                            .onTapGesture {
                                showSourceMenu = true
                            }
                            .confirmationDialog("Escolher origem", isPresented: $showSourceMenu) {
                                Button("Tirar foto") { isShowingCamera = true }
                                Button("Escolher da Galeria") { isShowingLibrary = true }
                                Button("Cancelar", role: .cancel) { }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .background(GradientBackground())
                        
                        ButtonView(image: "img-cameraSymbol", title: "confirm pickture", titleDone: "pickture sent", action:{
                                if let selectedImage = selectedImage {
                                    viewModel.submitSelectedImage(image: selectedImage)
                                    playerReady = true
                                }
                            }//, state: playerReady ? .enabled : .inactive
                        )
                }
                .safeAreaPadding(.bottom, 32)
                .padding(.horizontal)
                                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }
        }
        .background(Color.darkerPurple)
        .navigationBarBackButtonHidden(true)


        .onAppear {
            currentPhrase = viewModel.setCurrentRandomPhrase()
        }
        .onReceive(viewModel.$currentPhrase) { currentPhrase in
            self.currentPhrase = currentPhrase
        }
        .onChange(of: viewModel.haveAllPlayersSubmittedImg) {
            goToStackView = true
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToStackView) {
            
            ImageStackView(viewModel: ImageStackViewModel(), submittedPhrase: currentPhrase, imageSubmissions: viewModel.getSubmittedImages())
        }
        .sheet(isPresented: $isShowingCamera) {
            ImagePicker(sourceType: .camera, allowsEditing: false) { img in
                selectedImage = img
            }
        }
        .sheet(isPresented: $isShowingLibrary) {
            ImagePicker(sourceType: .photoLibrary, allowsEditing: false) { img in
                selectedImage = img
            }
        }
    }
}

#Preview {
    ImageSelectionView()
}

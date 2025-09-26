//
//  GameCenterListener.swift
//  Pickture
//
//  Created by Fernando Sulzbach on 25/09/25.
//
import SwiftUI
import GameKit

extension GameCenterService: GKLocalPlayerListener {
    // Quando um convite é aceito pelo usuário FORA do app
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        print("📩 Convite recebido de \(invite.sender.displayName)")
        
        // Armazenar o convite para processamento
        pendingInvite = invite
        
        // Se o app estiver ativo, processar imediatamente
        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.processPendingInvite()
            }
        }
        // Se o app não estiver ativo, será processado quando se tornar ativo
    }
    
    // Recebimento de solicitação de partida
    func player(_ player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("📩 Solicitação de partida recebida para \(recipientPlayers.count) jogadores")
        
        // Armazenar a solicitação para processamento
        pendingPlayersToInvite = recipientPlayers
        
        // Se o app estiver ativo, processar imediatamente
        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.processPendingInvite()
            }
        }
        // Se o app não estiver ativo, será processado quando se tornar ativo
    }
}

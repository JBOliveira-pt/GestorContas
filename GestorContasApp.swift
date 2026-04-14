//
//  GestorContasApp.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import SwiftUI
import SwiftData

//PONTO DE ENTRADA
//Configura o modelContainer e o 'injeta' em toda a app

@main
struct GestorContasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        .modelContainer(for: [Conta.self, Divida.self])    //Configura a BD para a 'Conta' e a "Divida"
        
    }
}

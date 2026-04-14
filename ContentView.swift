//
//  ContentView.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var tabSelecionada: Int = 0  //Controla a tab ativa (abre sempre no Resumo)
    
    @State private var viewModel: ContasViewModel?
    
    var body: some View {
        
        let vm = viewModel ?? ContasViewModel(contexto: modelContext)
        
        TabView(selection: $tabSelecionada) {
            
            //Tab 0: Resumo (abre por defeito)
            ResumoView()
                .tabItem {
                    Label("Resumo", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            //Tab 1: Lista as contas
            NavigationStack {
                ContasListView(tabSelecionada: $tabSelecionada)
            }
            .tabItem {
                Label("Contas", systemImage: "list.bullet.clipboard")
            }
            .tag(1)
            
            // Tab 2: Dívidas
                        NavigationStack {
                            DividasListView(tabSelecionada: $tabSelecionada)
                        }
                        .tabItem { Label("Dívidas", systemImage: "creditcard.fill") }
                        .tag(2)

                        // Tab 3: Adicionar
                        AdicionarDebitoView(tabSelecionada: $tabSelecionada)
                            .tabItem { Label("Adicionar", systemImage: "plus.circle.fill") }
                            .tag(3)
                    }
                    .environmentObject(vm)
                    .onAppear {
                                //Guarda a instância para reutilizar nos renders seguintes
                                if viewModel == nil {
                                    viewModel = vm
                                }
                            }
        
    }//Fechamento do View (body)
}//Fechamento do View (struct)

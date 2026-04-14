//
//  DividasListView.swift
//  GestorContas
//
//  Created by iMac08 on 27/03/2026.
//

import SwiftUI
import SwiftData

enum FiltroDividas: CaseIterable {
    case todas, pendentes, pagas

    var titulo: String {
        switch self {
        case .todas: return "Todas"
        case .pendentes: return "Pendentes"
        case .pagas: return "Pagas"
        }
    }
}

struct DividasListView: View {

    @Query(sort: \Divida.dataVencimento)
    private var todasDividas: [Divida]

    @EnvironmentObject var viewModel: ContasViewModel

    //Usa o filtro específico
    @State private var filtroSelecionado: FiltroDividas = .todas
    
    @AppStorage("tipoParaAdicionar") private var tipoParaAdicionarRaw: String = "conta"

    @Binding var tabSelecionada: Int

    var body: some View {
        VStack(spacing: 0) {

            Picker("Filtro", selection: $filtroSelecionado) {
                ForEach(FiltroDividas.allCases, id: \.self) { filtro in
                    Text(filtro.titulo).tag(filtro)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            List {
                ForEach(dividasFiltradas) { divida in
                    NavigationLink(destination: DividaDetalheView(divida: divida)) {
                        DividaRowView(divida: divida) {
                            viewModel.alternarPagamentoDivida(divida)
                        }
                    }
                }
                .onDelete { offsets in
                    viewModel.apagarDividas(em: offsets, de: dividasFiltradas)
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if dividasFiltradas.isEmpty {
                    if todasDividas.isEmpty {
                        ContentUnavailableView(
                            "Sem dívidas",
                            systemImage: "creditcard",
                            description: Text("Adiciona uma dívida com o botão +")
                        )
                    } else {
                        ContentUnavailableView(
                            "Sem resultados",
                            systemImage: "line.3.horizontal.decrease.circle",
                            description: Text("Não há dívidas no filtro selecionado")
                        )
                    }
                }
            }
        }//Fecha o 'VStack'
        .navigationTitle("Minhas Dívidas")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    tipoParaAdicionarRaw = "divida"     //'Dívida' pré-seleciona
                    tabSelecionada = 3                  //Tab "Adicionar"
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            filtroSelecionado = .todas
        }
        
    }//Fecha o 'View' (body)

    //Método do filtro
    private var dividasFiltradas: [Divida] {
        switch filtroSelecionado {
        case .todas:
            return todasDividas
        case .pendentes:
            return todasDividas.filter { !$0.paga }
        case .pagas:
            return todasDividas.filter { $0.paga }
        }
    }
    
}//Fecha o 'View' (struct)

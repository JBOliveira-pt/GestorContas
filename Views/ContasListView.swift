//
//  ContasListView.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import SwiftUI
import SwiftData

//LISTA DE CONTAS
//Ecrã principal com a lista de todas as contas

struct ContasListView: View {

    @Query(sort: \Conta.dataVencimento) //Busca os dados da BD...
    private var todasContas: [Conta]    //...e atualiza a view quando há mudanças

    @EnvironmentObject var viewModel: ContasViewModel   //Acesso ao ViewModel

    @State private var filtroSelecionado: FiltroContas = .todas     //Estado local desta view (filtro selecionado)

    @Binding var tabSelecionada: Int                        //Recebe o binding da tab do ContentView

    @AppStorage("tipoParaAdicionar") private var tipoParaAdicionarRaw: String = "conta"

    var body: some View {

        VStack(spacing: 0) {
            
            //Seletor de filtro: 'Todas', 'Pendentes' e 'Pagas'
            Picker("Filtro", selection: $filtroSelecionado) {
                ForEach(FiltroContas.allCases, id: \.self) { filtro in
                    Text(filtro.titulo).tag(filtro)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            List {      //Lista de contas filtradas
                ForEach(contasFiltradas) { conta in

                    //Leva ao ecrã de 'detalhe'
                    NavigationLink(destination: ContaDetalheView(conta: conta)) {
                        ContaRowView(conta: conta) {
                            viewModel.alternarPagamento(conta)
                        }
                    }
                }

                .onDelete { offsets in      //Ação para deletar a conta
                    viewModel.apagarContas(em: offsets, de: contasFiltradas)
                }
            }
            .listStyle(.insetGrouped)
            .overlay {

                if contasFiltradas.isEmpty {
                    ContentUnavailableView(
                        "Sem contas",           //Mensagem quando a lista está vazia
                        systemImage: "tray",
                        description: Text("Adiciona uma conta com o botão +")
                    )
                }
            }
        }
        .navigationTitle("Minhas Contas")
        .toolbar {

            ToolbarItem(placement: .navigationBarLeading) {     //Botão para 'apagar' (modo de edição)
                EditButton()
            }

            ToolbarItem(placement: .navigationBarTrailing) {    //Botão para 'adicionar' nova conta
                Button {
                    tipoParaAdicionarRaw = "conta"  //Força sempre "Conta" ao navegar daqui
                    tabSelecionada = 3
                } label: {
                    Image(systemName: "plus")
                }
            }
        }

        .onAppear {
            filtroSelecionado = .todas   //Volta ao topo da lista quando a view aparece
        }
    }

    private var contasFiltradas: [Conta] {      //Filtra as contas
        switch filtroSelecionado {
        case .todas:     return todasContas
        case .pendentes: return todasContas.filter { !$0.paga }
        case .pagas:     return todasContas.filter { $0.paga }
        }
    }
}


enum FiltroContas: CaseIterable {   //Enum para os filtros da lista
    case todas, pendentes, pagas

    var titulo: String {
        switch self {
        case .todas:     return "Todas"
        case .pendentes: return "Pendentes"
        case .pagas:     return "Pagas"
        }
    }
}

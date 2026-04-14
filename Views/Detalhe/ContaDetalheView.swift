//
//  ContaDetalheView.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import SwiftUI

//DETALHES DA CONTA
//Ecrã com os detalhes de uma conta

struct ContaDetalheView: View {

    @Bindable var conta: Conta
    @EnvironmentObject var viewModel: ContasViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var nome: String = ""
    @State private var valor: String = ""
    @State private var dataVencimento: Date = Date()
    @State private var categoriaEscolhida: CategoriaConta = .outros
    @State private var notas: String = ""
    @State private var modoEdicao: Bool = false

    var body: some View {
        Form {

            //Secção #1: Informações principais
            Section("Informação da Conta") {
                if modoEdicao {
                    TextField("Nome da conta", text: $nome)

                    TextField("Valor (€)", text: $valor)
                        .keyboardType(.decimalPad)
                        .onChange(of: valor) { _, novoValor in
                            let filtrado = novoValor.filter { $0.isNumber || $0 == "." || $0 == "," }
                            if filtrado != novoValor { valor = filtrado }
                        }

                    DatePicker(
                        "Vencimento",
                        selection: $dataVencimento,
                        displayedComponents: .date
                    )
                } else {
                    LabeledContent("Nome", value: conta.nome)

                    LabeledContent("Valor (€)") {
                        Text(String(format: "%.2f", conta.valor))
                    }

                    LabeledContent("Vencimento") {
                        Text(conta.dataVencimento, style: .date)
                    }
                }
            }

            //Secção #2: Categoria
            Section("Categoria") {
                if modoEdicao {
                    Picker("Categoria", selection: $categoriaEscolhida) {
                        ForEach(CategoriaConta.allCases, id: \.rawValue) { cat in
                            Label(cat.rawValue, systemImage: cat.icone)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    LabeledContent("Categoria") {
                        Label(
                            conta.categoria,
                            systemImage: CategoriaConta(rawValue: conta.categoria)?.icone ?? "creditcard.fill"
                        )
                        .labelStyle(.titleAndIcon)
                        .font(.body)
                        .lineLimit(1)
                        .fixedSize()
                    }
                }
            }

            //Secção #3: Notas
            Section("Notas") {
                if modoEdicao {
                    TextField("Adicionar notas...", text: $notas, axis: .vertical)
                        .lineLimit(3...6)
                } else {
                    Text(conta.notas.isEmpty ? "Sem notas" : conta.notas)
                        .foregroundColor(conta.notas.isEmpty ? .secondary : .primary)
                }
            }

            //Secção #4: Taxa de Câmbio (da API)
            Section("Equivalente em USD") {
                if viewModel.carregandoTaxa {
                    HStack {
                        ProgressView()
                        Text("A carregar taxa...")
                            .foregroundColor(.secondary)
                    }
                } else if let erro = viewModel.erroAPI {
                    Text(erro)
                        .foregroundColor(.red)
                        .font(.caption)
                } else {
                    LabeledContent("Valor em USD") {
                        Text(String(format: "$%.2f", viewModel.converterParaUSD(conta.valor)))
                            .fontWeight(.semibold)
                    }
                    LabeledContent("Taxa EUR/USD") {
                        Text(String(format: "%.4f", viewModel.taxaUSD))
                            .foregroundColor(.secondary)
                    }
                }
            }

            //Secção #5: Estado de pagamento
            Section {
                Toggle("Marca como Paga", isOn: $conta.paga)
                    .tint(.green)
            }
        }
        .navigationTitle(modoEdicao ? "Editar Conta" : conta.nome)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(modoEdicao ? "Guardar" : "Editar") {
                    if modoEdicao { guardarEdicao() }
                    else { ativarEdicao() }
                }
            }
            if modoEdicao {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        modoEdicao = false
                        carregarDados()
                    }
                }
            }
        }
        .onAppear { carregarDados() }
        .task {
            await viewModel.carregarTaxaCambio()    //Carrega a taxa quando o ecrã aparece
        }
    }

    private func carregarDados() {
        nome = conta.nome
        valor = String(format: "%.2f", conta.valor)
        dataVencimento = conta.dataVencimento
        categoriaEscolhida = CategoriaConta(rawValue: conta.categoria) ?? .outros
        notas = conta.notas
    }

    private func ativarEdicao() {
        carregarDados()
        modoEdicao = true
    }

    private func guardarEdicao() {
        guard !nome.trimmingCharacters(in: .whitespaces).isEmpty,
              let valorDouble = Double(valor.replacingOccurrences(of: ",", with: ".")),
              valorDouble > 0 else { return }

        conta.nome = nome
        conta.valor = valorDouble
        conta.dataVencimento = dataVencimento
        conta.categoria = categoriaEscolhida.rawValue
        conta.notas = notas
        modoEdicao = false
    }
}

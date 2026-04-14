//
//  DividaDetalheView.swift
//  GestorContas
//
//  Created by iMac08 on 27/03/2026.
//

import SwiftUI

struct DividaDetalheView: View {

    @EnvironmentObject var viewModel: ContasViewModel
    @Bindable var divida: Divida

    @State private var nome: String = ""
    @State private var valor: String = ""
    @State private var dataVencimento: Date = Date()
    @State private var categoriaEscolhida: CategoriaDivida = .outros
    @State private var notas: String = ""
    @State private var numeroParcelas: Int = 1
    @State private var modoEdicao: Bool = false

    //Garante que o picker arranca com a categoria correta
    init(divida: Divida) {
        self.divida = divida
        _categoriaEscolhida = State(
            initialValue: CategoriaDivida(rawValue: divida.categoria) ?? .outros
        )
    }

    var body: some View {
        Form {

            //Secção #1: Detalhes da dívida
            Section("Detalhes da Dívida") {
                if modoEdicao {
                    TextField("Nome", text: $nome)

                    TextField("Valor (€)", text: $valor)
                        .keyboardType(.decimalPad)
                        .onChange(of: valor) { _, novoValor in
                            let filtrado = novoValor.filter { $0.isNumber || $0 == "." || $0 == "," }
                            if filtrado != novoValor { valor = filtrado }
                        }

                    DatePicker("Vencimento", selection: $dataVencimento, displayedComponents: .date)

                    Stepper(
                        "Parcelas: \(numeroParcelas)x",
                        value: $numeroParcelas, in: 1...360
                    )
                } else {
                    LabeledContent("Nome", value: divida.nome)

                    // Valor da parcela em destaque
                    VStack(alignment: .leading, spacing: 2) {
                        Text("€\(String(format: "%.2f", divida.valorParcela))")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("por parcela")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Valor total: €\(String(format: "%.2f", divida.valor))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }

                    LabeledContent("Vencimento") {
                        Text(divida.dataVencimento, style: .date)
                    }

                    //Descritivo de parcelas no detalhe
                    if divida.numeroParcelas > 0 {
                        let parcelaExibida = min(divida.parcelaAtual, divida.numeroParcelas)
                        LabeledContent("Parcelas", value: "\(parcelaExibida)/\(divida.numeroParcelas)")
                    }
                }
            }

            //Secção #2: Categoria
            Section("Categoria") {
                if modoEdicao {
                    Picker("Categoria", selection: $categoriaEscolhida) {
                        ForEach(CategoriaDivida.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icone).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    LabeledContent("Categoria") {
                        Label(
                            divida.categoria,
                            systemImage: CategoriaDivida(rawValue: divida.categoria)?.icone ?? "creditcard.fill"
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
                    TextField("Notas...", text: $notas, axis: .vertical)
                        .lineLimit(3...5)
                } else {
                    Text(divida.notas.isEmpty ? "Sem notas" : divida.notas)
                        .foregroundColor(divida.notas.isEmpty ? .secondary : .primary)
                }
            }

            //Secção #4: Equivalente em USD
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
                        Text(String(format: "$%.2f", viewModel.converterParaUSD(divida.valor)))
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
                Toggle("Marca como Paga", isOn: Binding(
                    get: { divida.paga },
                    set: { _ in viewModel.alternarPagamentoDivida(divida) }
                ))
                .tint(.green)
            }
        }
        .navigationTitle(modoEdicao ? "Editar Dívida" : divida.nome)
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
        nome = divida.nome
        valor = String(format: "%.2f", divida.valor)
        dataVencimento = divida.dataVencimento
        categoriaEscolhida = CategoriaDivida(rawValue: divida.categoria) ?? .outros
        notas = divida.notas
        numeroParcelas = divida.numeroParcelas
    }

    private func ativarEdicao() {
        carregarDados()
        modoEdicao = true
    }

    private func guardarEdicao() {
        guard !nome.trimmingCharacters(in: .whitespaces).isEmpty,
              let valorDouble = Double(valor.replacingOccurrences(of: ",", with: ".")),
              valorDouble > 0 else { return }

        divida.nome = nome
        divida.valor = valorDouble
        divida.dataVencimento = dataVencimento
        divida.categoria = categoriaEscolhida.rawValue
        divida.notas = notas
        divida.numeroParcelas = numeroParcelas
        modoEdicao = false
    }
}

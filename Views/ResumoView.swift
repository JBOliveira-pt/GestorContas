//
//  ResumoView.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import SwiftUI
import SwiftData

//DASHBOARD
//Ecrã com dashboard que mostra as principais infos


struct ResumoView: View {

    @Query private var todasContas: [Conta]
    @Query private var todasDividas: [Divida]
    @EnvironmentObject var viewModel: ContasViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Cartões de resumo (contas + dívidas)
                    HStack(spacing: 16) {
                        CartaoResumo(
                            titulo: "Total a pagar",
                            valor: viewModel.formatarMoeda(
                                viewModel.totalEmDividaComDividas(contas: todasContas, dividas: todasDividas)
                            ),
                            icone: "exclamationmark.circle.fill",
                            cor: .red
                        )
                        CartaoResumo(
                            titulo: "Total pago",
                            valor: viewModel.formatarMoeda(
                                viewModel.totalPagoComDividas(contas: todasContas, dividas: todasDividas)
                            ),
                            icone: "checkmark.circle.fill",
                            cor: .green
                        )
                    }
                    .padding(.horizontal)

                    // Cartão "Em Atraso"
                    let valorEmAtraso = viewModel.totalEmAtraso(contas: todasContas, dividas: todasDividas)
                    if valorEmAtraso > 0 {
                        HStack(spacing: 12) {
                            Image(systemName: "clock.badge.exclamationmark.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("TOTAL EM ATRASO")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.red)
                                Text(viewModel.formatarMoeda(valorEmAtraso))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
                        )
                        .padding(.horizontal)
                    }

                    // Contas e Dívidas a vencer (em 7 dias)
                    VStack(alignment: .leading, spacing: 12) {
                        if proximasAVencer.isEmpty {
                            Text("Não tens nenhuma conta a vencer nos próximos 7 dias. Parabéns! 🎉")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                Text("A VENCER EM BREVE")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(Color.red))
                            .padding(.horizontal)
                            .padding(.top, 6)

                            ForEach(proximasAVencer) { item in
                                item.rowView
                                    .padding(.horizontal)
                                Divider().padding(.leading)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
                .padding(.top, 16)
                .padding(.bottom)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("📊 Resumo")
        }
    }

    private struct ItemProximo: Identifiable {
        let id: PersistentIdentifier
        let dataVencimento: Date
        let rowView: AnyView
    }

    private var proximasAVencer: [ItemProximo] {
        //meia-noite de hoje
        let hoje = Calendar.current.startOfDay(for: Date())
        //meia-noite daqui a 7 dias
        let seteDias = Calendar.current.date(byAdding: .day, value: 7, to: hoje)!

        let itensConta: [ItemProximo] = todasContas
            .filter { !$0.paga && $0.dataVencimento >= hoje && $0.dataVencimento <= seteDias }
            .map { conta in
                ItemProximo(
                    id: conta.persistentModelID,
                    dataVencimento: conta.dataVencimento,
                    rowView: AnyView(
                        ContaRowView(conta: conta) {
                            viewModel.alternarPagamento(conta)
                        }
                    )
                )
            }

        let itensDivida: [ItemProximo] = todasDividas
            .filter { !$0.paga && $0.dataVencimento >= hoje && $0.dataVencimento <= seteDias }
            .map { divida in
                ItemProximo(
                    id: divida.persistentModelID,
                    dataVencimento: divida.dataVencimento,
                    rowView: AnyView(
                        DividaRowView(divida: divida) {
                            viewModel.alternarPagamentoDivida(divida)
                        }
                    )
                )
            }

        return (itensConta + itensDivida)
            .sorted { $0.dataVencimento < $1.dataVencimento }
    }
}

// Cartão de resumo com valor e ícone (sub-componente)
struct CartaoResumo: View {
    let titulo: String
    let valor: String
    let icone: String
    let cor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icone)
                    .foregroundColor(cor)
                Text(titulo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(valor)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

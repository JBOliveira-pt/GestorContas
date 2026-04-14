//
//  DividaRowView.swift
//  GestorContas
//
//  Created by iMac08 on 27/03/2026.
//

import SwiftUI

struct DividaRowView: View {
    let divida: Divida
    let aoAlternarPagamento: () -> Void     //Função chamada no botão 'pagar'

    //Atributo para verificar se a dívida está atrasada
    private var estaAtrasada: Bool {
        
        //usa meia-noite de hoje (como em totalEmAtraso)
        !divida.paga && divida.dataVencimento < Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        
        HStack(spacing: 12) {

            //Adaptado para quando a dívida está em atraso

            //Ícone da categoria
            Image(systemName: iconeCategoria)
                .font(.title2)
                .foregroundColor(estaAtrasada ? .white : corCategoriaBase)
                .frame(width: 40, height: 40)
                .background((estaAtrasada ? Color.red : corCategoriaBase).opacity(0.25))
                .clipShape(Circle())

            //Informações da dívida
            VStack(alignment: .leading, spacing: 4) {
                Text(divida.nome)
                    .font(.headline)
                    .strikethrough(divida.paga)
                    .foregroundColor(estaAtrasada ? .white : .primary)
                
                Text(divida.categoria)
                    .font(.caption)
                    .foregroundColor(estaAtrasada ? .white.opacity(0.8) : .secondary)
                
                HStack(spacing: 6) {
                    Text("Vence: \(divida.dataVencimento, style: .date)")
                        .font(.caption2)
                        .foregroundColor(estaAtrasada ? .white.opacity(0.9) : .secondary)
                    
                    //Mostra as parcelas, se existirem
                    if divida.numeroParcelas > 0 {
                        
                        let parcelaExibida = min(divida.parcelaAtual, divida.numeroParcelas)
                        
                        Text("· \(parcelaExibida)/\(divida.numeroParcelas)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(estaAtrasada ? .white.opacity(0.9) : .secondary)
                    }
                }
            }
            

            Spacer()

            //Valor e botão pill
            VStack(alignment: .trailing, spacing: 6) {
                Text("€\(String(format: "%.2f", divida.valorParcela))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(estaAtrasada ? .white : .primary)

                Text("Total: €\(String(format: "%.2f", divida.valor))")
                    .font(.caption2)
                    .foregroundColor(estaAtrasada ? .white.opacity(0.8) : .secondary)

                //Pill PAGA / A PAGAR
                Button(action: aoAlternarPagamento) {
                    Text(divida.paga ? "TOTAL PAGO" : "A PAGAR")
                        .font(.system(size: 11, weight: divida.paga ? .bold : .regular))
                        .foregroundColor(
                            divida.paga ? .white : estaAtrasada ? .white.opacity(0.9) : Color(.systemGray3)
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(divida.paga ? Color.green : estaAtrasada ? Color.white.opacity(0.25) : Color.clear)
                        )
                        .overlay(
                            Capsule().stroke(
                                divida.paga ? Color.green :
                                estaAtrasada ? Color.white.opacity(0.5) : Color(.systemGray4),
                                lineWidth: 1.5
                            )
                        )
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.2), value: divida.paga)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, estaAtrasada ? 12 : 0)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(estaAtrasada ? Color.red.opacity(0.75) : Color.clear)
        )
        .opacity(divida.paga ? 0.6 : 1.0)
    }

    //Cor base da categoria
    private var corCategoriaBase: Color {
        CategoriaDivida(rawValue: divida.categoria)?.cor ?? .gray
    }

    private var iconeCategoria: String {
        CategoriaDivida(rawValue: divida.categoria)?.icone ?? "creditcard.fill"
    }

}

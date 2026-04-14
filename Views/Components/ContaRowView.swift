//
//  ContaRowView.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import SwiftUI

//LINHA NA LISTA DE CONTAS
//Componente reutilizável que representa uma linha na lista de contas

struct ContaRowView: View {
    
    let conta: Conta
    let aoAlternarPagamento: () -> Void     //Função chamada no botão 'pagar'

    //Atributo para verificar se a conta está atrasada
    private var estaAtrasada: Bool {
            !conta.paga && conta.dataVencimento < Date()
        }
    
    var body: some View {
        HStack(spacing: 12) {

            //Ícone da categoria (diferente se tiver em atraso)
            Image(systemName: iconeCategoria)
                .font(.title2)
                .foregroundColor(estaAtrasada ? .white : corCategoria)
                .frame(width: 40, height: 40)
                .background((estaAtrasada ? Color.white : corCategoria).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {   //Informações da conta
                Text(conta.nome)
                    .font(.headline)
                    .strikethrough(conta.paga) // risca o texto se paga
                    .foregroundColor(estaAtrasada ? .white : .primary)

                Text(conta.categoria)
                    .font(.caption)
                    .foregroundColor(estaAtrasada ? .white.opacity(0.8) : .secondary)

                Text("Vence: \(conta.dataVencimento, style: .date)")    //Data de vencimento
                    .font(.caption2)
                    .foregroundColor(estaAtrasada ? .white.opacity(0.9) : .secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(String(format: "€%.2f", conta.valor))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(estaAtrasada ? .white : .primary)

                //Botão para marcar como pago/não pago
                Button(action: aoAlternarPagamento) {
                    
                    Text(conta.paga ? "PAGA" : "A PAGAR")
                        .font(.system(size: 11, weight: conta.paga ? .bold : .regular))
                        .foregroundColor(
                            conta.paga ? .white :
                            estaAtrasada ? .white.opacity(0.9) : Color(.systemGray3)
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(
                                conta.paga ? Color.green : estaAtrasada ? Color.white.opacity(0.25) : Color.clear
                            )
                        )
                        .overlay(
                            Capsule().stroke(
                                conta.paga ? Color.green : estaAtrasada ? Color.white.opacity(0.5) : Color(.systemGray4),
                                lineWidth: 1.5
                            )
                        )
                }
                
                .buttonStyle(.plain)    //Evita o acionamento indevido do botão
                .animation(.easeInOut(duration: 0.2), value: conta.paga)
            }
        }
        .padding(.vertical, 4)
        
        //Formatação para exibir as contas atrasadas
        .padding(.horizontal, estaAtrasada ? 12 : 0)
        .background(
            RoundedRectangle(cornerRadius: 10)
            .fill(estaAtrasada ? Color.red.opacity(0.75) : Color.clear)
        )
        
        .opacity(conta.paga ? 0.6 : 1.0) //Se a conta for paga fica + transparente
    }

    private var iconeCategoria: String {  //Propriedades do ícone e cor por categoria
        CategoriaConta(rawValue: conta.categoria)?.icone ?? "creditcard.fill"
    }

    private var corCategoria: Color {
        switch conta.categoria {
        case "Energia":              return .yellow
        case "Água":                 return .blue
        case "Telecomunicações":     return .purple
        case "Arrendamento":         return .orange
        case "Escolas":              return .cyan
        case "Cartões de Crédito":   return .red
        case "Portagens":            return .brown
        case "Combustível":          return .indigo
        case "Mercado":              return .green
        case "Vestuário":            return .pink
        default:                     return .gray
        }
    }
}

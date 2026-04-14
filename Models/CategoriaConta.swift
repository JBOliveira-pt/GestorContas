//
//  CategoriaConta.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import SwiftUI

//CATEGORIAS DE GASTOS

enum CategoriaConta: String, CaseIterable {  //Lista fixa de opções possíveis
    case energia        = "Energia"
    case agua           = "Água"
    case telecom        = "Telecomunicações"
    case arrendamento   = "Arrendamento"
    case escolas        = "Escolas"
    case creditos       = "Cartões de Crédito"
    case portagens      = "Portagens"
    case combustivel    = "Combustível"
    case mercado        = "Mercado"
    case vestuario      = "Vestuário"
    case outros         = "Outros"

    var icone: String {     //Ícones associados a cada categoria (SF Symbols)
        switch self {
        case .energia:        return "bolt.fill"
        case .agua:           return "drop.fill"
        case .telecom:        return "wifi"
        case .arrendamento:   return "house.fill"
        case .escolas:        return "graduationcap.fill"
        case .creditos:       return "creditcard.fill"
        case .portagens:      return "road.lanes"
        case .combustivel:    return "fuelpump.fill"
        case .mercado:        return "cart.fill"
        case .vestuario:      return "tshirt.fill"
        case .outros:         return "square.grid.2x2.fill"
        }
    }

    var cor: Color {       //Cores associada a cada categoria
        switch self {
        case .energia:        return .yellow
        case .agua:           return .blue
        case .telecom:        return .purple
        case .arrendamento:   return .orange
        case .escolas:        return .cyan
        case .creditos:       return .red
        case .portagens:      return .brown
        case .combustivel:    return .indigo
        case .mercado:        return .green
        case .vestuario:      return .pink
        case .outros:         return .gray
        }
    }
}

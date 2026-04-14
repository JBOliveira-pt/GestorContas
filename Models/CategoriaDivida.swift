//
//  CategoriaDivida.swift
//  GestorContas
//
//  Created by iMac08 on 27/03/2026.
//

import SwiftUI

enum CategoriaDivida: String, CaseIterable {
    case consumo     = "Consumo"
    case habitacao   = "Habitação"
    case automoveis  = "Automóveis"
    case pessoal     = "Pessoal"
    case estudantil  = "Estudantil"
    case outros      = "Outros"

    var icone: String {
        switch self {
        case .consumo:    return "cart.fill"
        case .habitacao:  return "house.fill"
        case .automoveis: return "car.fill"
        case .pessoal:    return "person.fill"
        case .estudantil: return "graduationcap.fill"
        case .outros:     return "creditcard.fill"
        }
    }

    var cor: Color {
        switch self {
        case .consumo:    return .orange
        case .habitacao:  return .blue
        case .automoveis: return .indigo
        case .pessoal:    return .purple
        case .estudantil: return .cyan
        case .outros:     return .gray
        }
    }
}

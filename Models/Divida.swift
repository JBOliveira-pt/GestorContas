//
//  Divida.swift
//  GestorContas
//
//  Created by iMac08 on 27/03/2026.
//

import Foundation
import SwiftData

@Model
class Divida {
    var nome: String
    var valor: Double
    var dataVencimento: Date
    var categoria: String
    var notas: String
    var numeroParcelas: Int     // 0 = sem parcelas definidas
    var parcelaAtual: Int       // Parcela corrente
    var pagaSemParcelas: Bool   // Estado real para dívidas sem parcelas (mantido por compatibilidade)
    var dataCriacao: Date

    var valorParcela: Double {
            valor / Double(max(numeroParcelas, 1))
        }
    
    // Propriedade não persistida
    var paga: Bool {
        numeroParcelas > 0 ? parcelaAtual > numeroParcelas : pagaSemParcelas
    }

    init(
        nome: String,
        valor: Double,
        dataVencimento: Date,
        categoria: String,
        notas: String = "",
        numeroParcelas: Int = 0
    ) {
        self.nome = nome
        self.valor = valor
        self.dataVencimento = dataVencimento
        self.categoria = categoria
        self.notas = notas
        self.numeroParcelas = numeroParcelas
        self.parcelaAtual = 1
        self.pagaSemParcelas = false
        self.dataCriacao = Date()
    }
}

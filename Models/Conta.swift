//
//  Conta.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import Foundation
import SwiftData

//CONTA

@Model                      //Persistência dos dados
class Conta {
    var id: UUID
    var nome: String          //Ex: "Electricidade", "Internet"
    var valor: Double         //Valor em euros
    var dataVencimento: Date  //Data limite de pagamento
    var paga: Bool            //Se já foi paga ou não
    var categoria: String     //Ex: "Energia", "Telecomunicações"
    var notas: String         //Notas opcionais

    init(
        nome: String,
        valor: Double,
        dataVencimento: Date,
        categoria: String,
        notas: String = ""
    ) {
        self.id = UUID()
        self.nome = nome
        self.valor = valor
        self.dataVencimento = dataVencimento
        self.paga = false       //A conta começa sempre por NÃO estar paga
        self.categoria = categoria
        self.notas = notas
    }
}

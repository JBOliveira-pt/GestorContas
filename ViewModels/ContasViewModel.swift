//
//  ContasViewModel.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import Foundation
import SwiftData
import Combine

//LÓGICA DE NEGÓCIO

@MainActor      //Garante que as atualizações de UI acontecem na main
class ContasViewModel: ObservableObject {

    @Published var taxaUSD: Double = 1.0
    @Published var carregandoTaxa: Bool = false
    @Published var erroAPI: String? = nil

    private var contexto: ModelContext    //Referência ao SwiftData (BD local)

    //NumberFormatter como propriedade estática — criado apenas uma vez
    private static let formatadorMoeda: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        f.locale = Locale(identifier: "pt_PT")
        return f
    }()

    init(contexto: ModelContext) {
        self.contexto = contexto
    }

    //-----------------------------------------------
    //FUNÇÕES BÁSICAS (ADICIONA, REMOVE, ALTERA O ESTADO)

    //Adiciona uma nova conta na BD
    func adicionarConta(
        nome: String,
        valor: Double,
        dataVencimento: Date,
        categoria: String,
        notas: String = ""
    ) {
        let novaConta = Conta(
            nome: nome,
            valor: valor,
            dataVencimento: dataVencimento,
            categoria: categoria,
            notas: notas
        )
        contexto.insert(novaConta)  //Guarda na BD
    }

    //Remove uma conta da base de dados
    func apagarConta(_ conta: Conta) {
        contexto.delete(conta)
    }

    //Apaga múltiplas contas
    func apagarContas(em offsets: IndexSet, de lista: [Conta]) {
        for indice in offsets {
            contexto.delete(lista[indice])
        }
    }

    //Alterna o estado pago/não da conta
    func alternarPagamento(_ conta: Conta) {
        conta.paga.toggle()
    }

    //-----------------------------------------------
    //FUNÇÕES DE CÁLCULOS (TOTAL PAGO/NÃO PAGO, CONVERTER/FORMATAR VALOR)

    //Calcula o total de contas não pagas
    func totalEmDivida(contas: [Conta]) -> Double {
        contas.filter { !$0.paga }.reduce(0) { $0 + $1.valor }
    }

    //Calcula o total de contas já pagas
    func totalPago(contas: [Conta]) -> Double {
        contas.filter { $0.paga }.reduce(0) { $0 + $1.valor }
    }

    //Converte um valor de EUR para USD (API)
    func converterParaUSD(_ valorEUR: Double) -> Double {
        return valorEUR * taxaUSD
    }

    //Formata um valor Double como moeda (€)
    func formatarMoeda(_ valor: Double) -> String {
        
        //Reutiliza instância estática
        return ContasViewModel.formatadorMoeda.string(from: NSNumber(value: valor)) ?? "€0,00"
    }

    //Carrega a API (Taxa de Câmbio Euro -> Dólar)
    func carregarTaxaCambio() async {   //Busca a taxa de câmbio à API externa
        
        carregandoTaxa = true
        erroAPI = nil

        do {
            taxaUSD = try await TaxaCambioService.shared.obterTaxaEURparaUSD()
        } catch {
            erroAPI = "Não foi possível carregar a taxa de câmbio."
        }

        carregandoTaxa = false
    }

    //------------------------------
    //FUNÇÕES DAS DÍVIDAS

    //Adicionar uma nova dívida
    func adicionarDivida(
        nome: String,
        valorTotal: Double,
        dataVencimento: Date,
        categoria: String,
        notas: String = "",
        numeroParcelas: Int = 1
    ) {
        let novaDivida = Divida(
            nome: nome,
            valor: valorTotal,
            dataVencimento: dataVencimento,
            categoria: categoria,
            notas: notas,
            numeroParcelas: numeroParcelas
        )
        contexto.insert(novaDivida)
    }

    //Mudar o pagamento da dívida
    func alternarPagamentoDivida(_ divida: Divida) {
        if divida.numeroParcelas > 0 {

            //Dívida com parcelas
            if divida.parcelaAtual <= divida.numeroParcelas {

                //Avança para a próxima parcela e atualiza a data (+1 mês)
                divida.parcelaAtual += 1

                if let novaData = Calendar.current.date(
                    byAdding: .month, value: 1,
                    to: divida.dataVencimento
                ) {
                    divida.dataVencimento = novaData
                }
            }

        //Se parcelaAtual > numeroParcelas, a dívida fica paga...
        } else {

            //..caso contrário (dívida sem parcelas), o comportamento é normal
            divida.pagaSemParcelas.toggle()
        }
    }

    //Corrige o pagamento da última parcela (recua 1 parcela)
    func recuarParcela(_ divida: Divida) {
        guard divida.numeroParcelas > 0,
              divida.parcelaAtual > 1 else { return }

        divida.parcelaAtual -= 1

        //Reverte a data (-1 mês)
        if let dataAnterior = Calendar.current.date(
            byAdding: .month, value: -1,
            to: divida.dataVencimento
        ) {
            divida.dataVencimento = dataAnterior
        }
    }

    //Apagar a dívida
    func apagarDividas(em offsets: IndexSet, de lista: [Divida]) {
        
        for index in offsets {
            contexto.delete(lista[index])
        }
        
    }

    //Total em dívida (só as parcelas não pagas das dívidas)
    func totalEmDividaComDividas(contas: [Conta], dividas: [Divida]) -> Double {
        
        let totalContas = contas.filter { !$0.paga }.reduce(0) { $0 + $1.valor }
        let totalDividas = dividas.filter { !$0.paga }
            .reduce(0) { $0 + Double($1.numeroParcelas - ($1.parcelaAtual - 1)) * $1.valorParcela }
        return totalContas + totalDividas
        
    }

    // Total pago (pagamento de contas + todas as parcelas pagas de dívidas)
    func totalPagoComDividas(contas: [Conta], dividas: [Divida]) -> Double {
        
        let totalContas = contas.filter { $0.paga }.reduce(0) { $0 + $1.valor }
        
        // Parcelas pagas das dívidas: (parcelaAtual-1) * valorParcela
        let totalDividasPagas = dividas.filter { !$0.paga && $0.parcelaAtual > 1 }
            .reduce(0) { $0 + Double($1.parcelaAtual - 1) * $1.valorParcela }
        let totalDividasQuitadas = dividas.filter { $0.paga }
            .reduce(0) { $0 + $1.valor }
        return totalContas + totalDividasPagas + totalDividasQuitadas
        
    }

    // Total em atraso (parcelas vencidas e não pagas)
    func totalEmAtraso(contas: [Conta], dividas: [Divida]) -> Double {
        
        let inicioDoDiaHoje = Calendar.current.startOfDay(for: Date())

        let atrasadoContas = contas
            .filter { !$0.paga && $0.dataVencimento < inicioDoDiaHoje }
            .reduce(0) { $0 + $1.valor }

        // Para cada dívida, contar quantas parcelas vencidas e não pagas há
        let atrasadoDividas = dividas.reduce(0.0) { acc, divida in
            guard !divida.paga else { return acc }
            var countVencidasNaoPagas = 0
            var data = divida.dataVencimento
            
            // Parcela 1 é paga quando parcelaAtual > 1, etc.
            for i in (divida.parcelaAtual)...divida.numeroParcelas {
                if data < inicioDoDiaHoje { countVencidasNaoPagas += 1 }
                data = Calendar.current.date(byAdding: .month, value: 1, to: data)!
            }
            return acc + Double(countVencidasNaoPagas) * divida.valorParcela
        }

        return atrasadoContas + atrasadoDividas
    }

}

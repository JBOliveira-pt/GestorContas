//
//  TaxaCambioService.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import Foundation

//TAXA DE CÂMBIO (EUR -> USD)
//INTERPRETA O JSON DA API (nome variáveis = chaves JSON)

struct TaxaCambioResposta: Decodable {
    let result: String
    let rates: [String: Double]
}

class TaxaCambioService {       //Comunicação com a API
    
    static let shared = TaxaCambioService() //Singleton: 1 instância em toda a app
    private init() {}                       //Impede criar outras instâncias
    
    //Função assíncrona que pode lançar erros
    func obterTaxaEURparaUSD() async throws -> Double {
        
        //API gratuita da web
        let urlString = "https://open.er-api.com/v6/latest/EUR"
        
        //Verifica se o URL é válido
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        //Faz o pedido à API e espera a resposta usa o "cliente HTTP" nativo do iOS
        let (dados, _) = try await URLSession.shared.data(from: url)
          
        let respostaDecodificada = try JSONDecoder().decode(TaxaCambioResposta.self, from: dados)
        
        return respostaDecodificada.rates["USD"] ?? 1.0

    }
}

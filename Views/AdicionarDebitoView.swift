//
//  AdicionarDebitosView.swift
//  GestorContas
//
//  Created by iMac08 on 25/03/2026.
//

import SwiftUI

//ADIÇÃO DE NOVA CONTA/DÍVIDA
//Formulário para adicionar uma nova conta ou dívida

//Enum para o tipo de entrada (Conta ou Dívida)
enum TipoEntrada {
    case conta, divida
}

struct AdicionarDebitoView: View {
    
    @EnvironmentObject var viewModel: ContasViewModel
    @Binding var tabSelecionada: Int    //Recebe o tab selecionado para navegar

    @AppStorage("tipoParaAdicionar") private var tipoInicialRaw: String = "conta"
    
    //Tipo selecionado: Conta ou Dívida (local)
    private var tipoInicial: TipoEntrada {
        get { tipoInicialRaw == "divida" ? .divida : .conta }
        set { tipoInicialRaw = newValue == .divida ? "divida" : "conta" }
    }
    
    //Estado local do formulário
    @State private var nome: String = ""
    @State private var valor: String = ""
    @State private var dataVencimento: Date = Date()
    @State private var categoriaEscolhida: CategoriaConta = .outros
    @State private var notas: String = ""

    //Campos exclusivos de Dívida
    @State private var categoriaDividaEscolhida: CategoriaDivida = .outros
    @State private var numeroParcelas: Int = 1
    
    //Controlo de visibilidade e aviso
    @State private var mensagemAviso: String = ""
    @State private var mostrarAviso: Bool = false

    var body: some View {
        
        NavigationStack {
            
            Form {
                
                //Seletor Conta/Dívida no topo
                Section {
                    
                    Picker("Tipo", selection: Binding(
                        get: { tipoInicial },
                        set: { tipoInicialRaw = $0 == .divida ? "divida" : "conta" }
                    )) {
                        Label("Conta", systemImage: "list.bullet.clipboard").tag(TipoEntrada.conta)
                        Label("Dívida", systemImage: "creditcard.fill").tag(TipoEntrada.divida)
                    }
                    .pickerStyle(.segmented)
                }
                
                //Campos comuns
                Section(tipoInicial == .conta ? "Detalhes da Conta" : "Detalhes da Dívida") {
                    
                    TextField("Nome (ex: \(tipoInicial == .conta ? "Electricidade" : "Cartão Visa"))", text: $nome)
                    TextField("Valor total da dívida em € (ex: 830.50)", text: $valor)
                        .keyboardType(.decimalPad)
                        .onChange(of: valor) { _, novoValor in
                            let filtrado = novoValor.filter { $0.isNumber || $0 == "." || $0 == "," }
                            if filtrado != novoValor { valor = filtrado }
                        }
                    
                    DatePicker("Data de Vencimento", selection: $dataVencimento, displayedComponents: .date)
                    
                    //Campo de parcelas (exclusivo da Dívida)
                    if tipoInicial == .divida {
                        Stepper(
                            "Parcelas: \(numeroParcelas)x",
                            value: $numeroParcelas, in: 1...360
                        )
                    }
                }
                
                //Categoria (muda consoante o tipo)
                Section("Categoria") {
                    if tipoInicial == .conta {
                        Picker("Categoria", selection: $categoriaEscolhida) {
                            ForEach(CategoriaConta.allCases, id: \.self) { cat in
                                Label(cat.rawValue, systemImage: cat.icone).tag(cat)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    } else {
                        Picker("Categoria", selection: $categoriaDividaEscolhida) {
                            ForEach(CategoriaDivida.allCases, id: \.self) { cat in
                                Label(cat.rawValue, systemImage: cat.icone).tag(cat)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }
                
                //Seção das notas (comum a ambos os casos)
                Section("Notas (opcional)") {
                    TextField("Adicionar notas...", text: $notas, axis: .vertical)
                        .lineLimit(3...5)
                }
                
            }//Fecha o "Form"
            
            .navigationTitle(tipoInicial == .conta ? "Nova Conta" : "Nova Dívida")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                
                if mostrarAviso {
                    Text(mensagemAviso)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            mensagemAviso.contains("Guardada") ? Color.green :
                                mensagemAviso.contains("Cancelado") ? Color.orange : Color.red
                        )
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            .animation(.easeInOut(duration: 0.3), value: mostrarAviso)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        mostrarAvisoTemporario("Cancelado ❌") {
                            limparCampos()
                            tabSelecionada = 0
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardar()
                    }
                    .fontWeight(.bold)
                }
            }
            
        }//Fecha o "NavigationStack"
    }//Fecha a "View" (body)
    
    //-----------
    //FUNÇÕES

    //Guarda a conta
    private func guardar() {
        guard !nome.trimmingCharacters(in: .whitespaces).isEmpty,
        let valorDouble = Double(valor.replacingOccurrences(of: ",", with: ".")),
        valorDouble > 0
        
        else {
            mostrarAvisoTemporario("Preenche o nome e o valor! ⚠️")
            return
        }

        if tipoInicial == .conta {
            viewModel.adicionarConta(
                nome: nome,
                valor: valorDouble,
                dataVencimento: dataVencimento,
                categoria: categoriaEscolhida.rawValue,
                notas: notas
            )
            mostrarAvisoTemporario("Nova Conta Guardada ✅") {
                limparCampos()
                tabSelecionada = 0
            }
        } else {
            viewModel.adicionarDivida(
                nome: nome,
                valorTotal: valorDouble,
                dataVencimento: dataVencimento,
                categoria: categoriaDividaEscolhida.rawValue,
                notas: notas,
                numeroParcelas: numeroParcelas
            )
            mostrarAvisoTemporario("Nova Dívida Guardada ✅") {
                limparCampos()
                tabSelecionada = 0
            }
        }
    }

    //Limpa os campos
    private func limparCampos() {
        nome = ""
        valor = ""
        dataVencimento = Date()
        categoriaEscolhida = .outros
        categoriaDividaEscolhida = .outros
        notas = ""
        numeroParcelas = 1
        tipoInicialRaw = "conta"
    }

    //Mostra o aviso temporário de conta salva ou cancelada
    private func mostrarAvisoTemporario(_ mensagem: String, aposEsconder: (() -> Void)? = nil) {
        mensagemAviso = mensagem
        withAnimation { mostrarAviso = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { mostrarAviso = false }
            aposEsconder?()
        }
    }
    
}//Fecha a "View" (Struct)

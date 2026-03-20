//
//  EscolhaCriacaoTreinoView.swift
//  Spark
//
//  Created by Jota Pe on 11/03/26.
//

import SwiftUI

struct EscolhaCriacaoTreinoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gerenciadorSessoes: GerenciadorSessoesViewModel
    @State private var mostrarAddModel = false
    @State private var mostrarGeradorAI = false
    @State private var sessaoInjetadaParaEdicao: SessaoDeTreino? = nil
    @Binding var voltarParaRaiz: Bool
    
    let corDeFundoPrincipal = Color("BackgroundColor")
    let corBotaoPrincipal = Color("CorBotao")
    
    var body: some View {
        ZStack {
            corDeFundoPrincipal.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("Como deseja criar seu treino?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
            
                Button(action: {
                    mostrarAddModel = true
                }) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "plus.square.dashed")
                                .font(.title)
                                .foregroundColor(corBotaoPrincipal)
                            Text("Criar do Zero")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        Text("Adicione um plano novo em branco. Seus planos atuais não serão excluídos.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("ColorCard"))
                    .cornerRadius(15)
                }
            
                NavigationLink(destination: TreinosTemplatesView(voltarParaRaiz: $voltarParaRaiz).environmentObject(gerenciadorSessoes)) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.title)
                                .foregroundColor(corBotaoPrincipal)
                            Text("Usar Template Pré-pronto")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        Text("Escolha uma rotina montada. Atenção: isso substituirá todos os seus treinos atuais.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("ColorCard"))
                    .cornerRadius(15)
                }
                
                NavigationLink(destination: GeradorAITreinoView(onTreinoGerado: { sessaoGerada in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        sessaoInjetadaParaEdicao = sessaoGerada
                        mostrarAddModel = true
                    }
                })
                .navigationBarHidden(true)
                .environmentObject(gerenciadorSessoes), isActive: $mostrarGeradorAI) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.title)
                                .foregroundColor(corBotaoPrincipal)
                            Text("Gerar com Inteligência Artificial")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        Text("Descreva seu treino ideal e a IA montará ele para você em segundos.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("ColorCard"))
                    .cornerRadius(15)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
        .sheet(isPresented: $mostrarAddModel) {
            AddModel(sessaoInjetada: sessaoInjetadaParaEdicao)
                .environmentObject(gerenciadorSessoes)
                .interactiveDismissDisabled(true)
                .onDisappear {
                    sessaoInjetadaParaEdicao = nil
                }
        }
    }
}

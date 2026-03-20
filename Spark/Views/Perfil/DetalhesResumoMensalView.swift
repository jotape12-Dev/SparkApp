//
//  DetalhesResumoMensalView.swift
//  Spark
//
//  Created by Jota Pe on 16/03/26.
//

import SwiftUI

struct DetalhesResumoMensalView: View {
    var volumeTotal: Double
    var objetoAlcancado: ObjetoComparacao?
    
    @Environment(\.dismiss) var dismiss
    
    let corDeFundoPrincipal = Color("BackgroundColor")
    let corBotaoPrincipal = Color("CorBotao")
    
    var body: some View {
        NavigationStack {
            ZStack {

                corDeFundoPrincipal
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    if volumeTotal < 200 {
                        Text("Bom começo! Continue treinando para alcançar novos marcos.")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        Divider()
                            .background(Color.gray.opacity(0.5))
                            .padding(.vertical)
                            
                    } else if let objeto = objetoAlcancado {
                        Text("Você levantou um(a) \(objeto.nome)!")
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        
                        Text(objeto.descricao)
                            .font(.body)
                            .foregroundColor(Color("CorBotao"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Divider()
                            .background(Color.gray.opacity(0.5))
                            .padding(.vertical)
                    }
                    VStack(spacing: 8) {
                        Text("Volume Total do Mês")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("\(String(format: "%.0f", volumeTotal)) kg")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color("CorBotao"))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .foregroundColor(Color("CorBotao"))
                }
            }
            .toolbarBackground(corDeFundoPrincipal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

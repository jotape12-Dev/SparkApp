//
//  CalendarioMensalView.swift
//  Spark
//
//  Created by Jota Pe on 14/03/26.
//

import SwiftUI

struct CardResumoMensalView: View {
    var volumeTotal: Double
    
    @State private var mostrarModal: Bool = false
    
    var objetoAlcancado: ObjetoComparacao? {
        marcosDePeso
            .filter { volumeTotal >= $0.pesoMinimo }
            .max(by: { $0.pesoMinimo < $1.pesoMinimo })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Seu resumo")
                .font(.title3)
                .bold()
                .foregroundColor(.white)
                .padding(.leading, 5)
            
            Button(action: {
                mostrarModal = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    if volumeTotal == 0  {
                        Text("No data yet")
                            .font(.headline)
                            .foregroundColor(Color.gray.opacity(0.8))
                    } else if volumeTotal > 0 && volumeTotal < 200 {
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Neste mês você já levantou:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("\(String(format: "%.0f", volumeTotal)) kg")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding()
                    } else {
                        if let objeto = objetoAlcancado {
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Neste mês você já levantou:")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text("\(String(format: "%.0f", volumeTotal)) kg")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Text("O equivalente a um(a) \(objeto.nome)!")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .sheet(isPresented: $mostrarModal) {
                DetalhesResumoMensalView(volumeTotal: volumeTotal, objetoAlcancado: objetoAlcancado)
            }
        }
    }
}

//
//  ObjetoComparacao.swift
//  Spark
//
//  Created by Jota Pe on 13/03/26.
//

import Foundation

struct ObjetoComparacao {
    let nome: String
    let pesoMinimo: Double
    let icone: String
    let descricao: String
}

let marcosDePeso: [ObjetoComparacao] = [
    ObjetoComparacao(nome: "", pesoMinimo: 0, icone: "💪", descricao: "Continue treinando para ver sua evolução"),
    ObjetoComparacao(nome: "Moto", pesoMinimo: 200, icone: "🏍️", descricao: "Já dá para pegar a estrada!"),
    ObjetoComparacao(nome: "Urso Pardo", pesoMinimo: 600, icone: "🐻", descricao: "Força da natureza!"),
    ObjetoComparacao(nome: "Carro Popular", pesoMinimo: 1000, icone: "🚗", descricao: "Você levantou um veículo inteiro!"),
    ObjetoComparacao(nome: "Rinoceronte", pesoMinimo: 2500, icone: "🦏", descricao: "Absolutamente imparável!"),
    ObjetoComparacao(nome: "Elefante Asiático", pesoMinimo: 4000, icone: "🐘", descricao: "Força de proporções épicas!"),
    ObjetoComparacao(nome: "Caminhão Leve", pesoMinimo: 8000, icone: "🚚", descricao: "Você é uma máquina pesada!"),
    ObjetoComparacao(nome: "Avião de Caça", pesoMinimo: 15000, icone: "✈️", descricao: "Pronto para decolar!")
]

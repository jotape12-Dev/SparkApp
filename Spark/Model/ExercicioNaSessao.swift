//
//  ExercicioNaSessao.swift
//  Spark
//
//  Created by Jota Pe on 11/03/26.
//
import Foundation

struct ExercicioNaSessao: Identifiable, Codable, Equatable {
    var id = UUID()
    let exercicioBase: ExercicioLocal
    var series: [SerieDetalhe] = [SerieDetalhe(numeroSerie: 1)]
}

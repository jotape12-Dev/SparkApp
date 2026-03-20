//
//  ExercicioLocal.swift
//  Spark
//
//  Created by Jota Pe on 11/03/26.
//
import Foundation

struct ExercicioLocal: Identifiable, Codable, Equatable {
    var id = UUID()
    let nome: String
    let grupoMuscular: String
    let musculoPrincipal: String
    let musculosSecundarios: [String]?
    let equipamento: String?
    let instrucoes: [String]
    let observacoes: String?
    let gifUrlLocal: String?
}

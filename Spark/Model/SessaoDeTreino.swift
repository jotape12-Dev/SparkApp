//
//  SessaoDeTreino.swift
//  Spark
//
//  Created by Jota Pe on 11/03/26.
//

import Foundation

struct SessaoDeTreino: Identifiable, Codable, Equatable {
    var id: UUID
    var nomeSessao: String
    var exercicios: [ExercicioNaSessao]
    var dataCriacao: Date
    var isModeloIntocado: Bool?
}

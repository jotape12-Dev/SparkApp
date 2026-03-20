//
//  SerieDetalhe.swift
//  Spark
//
//  Created by Jota Pe on 11/03/26.
//

import Foundation

struct SerieDetalhe: Identifiable, Codable, Equatable {
    var id = UUID()
    var numeroSerie: Int = 1
    var reps: String = ""
    var peso: String = ""
    var descanso: String = "2min"
    var concluida: Bool = false
}

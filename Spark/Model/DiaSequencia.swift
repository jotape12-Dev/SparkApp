//
//  DiaSequencia.swift
//  Spark
//
//  Created by Jota Pe on 10/03/26.
//

import Foundation

struct DiaSequencia: Identifiable {
    let id = UUID()
    var letra: String
    var treinoInfo: String? = nil
    var estaDestacado: Bool = false
    var data: Date
    var idSessao: UUID?
}

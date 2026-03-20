//
//  DiaView.swift
//  Spark
//
//  Created by Jota Pe on 10/03/26.
//
import SwiftUI

struct DiaView: View {
    let dia: DiaSequencia
    let corDestaque: Color
    let corTextoPrincipal: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(dia.letra).font(.title3).fontWeight(.bold).foregroundColor(dia.estaDestacado ? corDestaque : corTextoPrincipal)
            if let treinoInfo = dia.treinoInfo, dia.estaDestacado {
                Text(treinoInfo).font(.caption).fontWeight(.medium).foregroundColor(corDestaque).lineLimit(1).truncationMode(.tail)
            } else if !dia.estaDestacado {
                Text(" ").font(.caption).padding(.vertical, 1)
            }
        }
        .frame(width: 60, height: 80)
        .background(Capsule().fill(dia.estaDestacado ? corDestaque.opacity(0.25) : Color("ColorCard")))
    }
}

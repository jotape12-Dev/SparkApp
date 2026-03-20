//
//  ConquistaCardView.swift
//  Spark
//

import SwiftUI

struct ConquistaCardView: View {
    let conquista: Conquista
    
    private let corDestaque = Color(red: 233/255, green: 9/255, blue: 22/255)
    private let corFundoCard = Color(red: 0.13, green: 0.12, blue: 0.12)
    private let corFundoBloqueado = Color(red: 0.10, green: 0.10, blue: 0.10)

    var body: some View {
        HStack(spacing: 16) {
            // — Ícone
            ZStack {
                Circle()
                    .fill(conquista.estaDesbloqueada
                          ? corDestaque.opacity(0.15)
                          : Color.white.opacity(0.05))
                    .frame(width: 56, height: 56)

                Image(systemName: conquista.icone)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        conquista.estaDesbloqueada
                        ? corDestaque
                        : Color.gray.opacity(0.4)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(conquista.titulo)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(conquista.estaDesbloqueada ? .white : .gray)

                    Spacer()

                    if conquista.estaDesbloqueada {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(corDestaque)
                            .font(.system(size: 16))
                    }
                }

                Text(conquista.descricao)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)

                // Barra de progresso
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 5)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(conquista.estaDesbloqueada
                                  ? corDestaque
                                  : corDestaque.opacity(0.5))
                            .frame(width: geo.size.width * conquista.progresso, height: 5)
                            .animation(.easeOut(duration: 0.6), value: conquista.progresso)
                    }
                }
                .frame(height: 5)

                Text(conquista.labelProgresso)
                    .font(.caption2)
                    .foregroundColor(conquista.estaDesbloqueada ? corDestaque : .gray.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(conquista.estaDesbloqueada ? corFundoCard : corFundoBloqueado)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            conquista.estaDesbloqueada
                            ? corDestaque.opacity(0.35)
                            : Color.white.opacity(0.05),
                            lineWidth: 1
                        )
                )
        )
        .opacity(conquista.estaDesbloqueada ? 1.0 : 0.65)
        .scaleEffect(conquista.estaDesbloqueada ? 1.0 : 0.98)
    }
}

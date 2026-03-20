//
//  ConquistaModel.swift
//  Spark
//

import Foundation

enum CategoriaConquista: String, CaseIterable {
    case sequencia    = "Sequência"
    case volume       = "Volume Mensal"
    case treinoCriado = "Treinos Criados"
    case historico    = "Histórico Total"
    case habitosTreino = "Hábitos de Treino"
    case tempoDedicacao = "Tempo de Dedicação"
}

struct Conquista: Identifiable {
    let id: UUID = UUID()
    let titulo: String
    let descricao: String
    let icone: String
    let categoria: CategoriaConquista
    let valorMeta: Double
    let valorAtual: Double
    let unidade: String       

    var estaDesbloqueada: Bool {
        valorAtual >= valorMeta
    }

    var progresso: Double {
        guard valorMeta > 0 else { return 0 }
        return min(valorAtual / valorMeta, 1.0)
    }

    var labelProgresso: String {
        if estaDesbloqueada {
            return "Desbloqueada! ✓"
        }
        // Conquista binária (meta = 1 e sem unidade)
        if valorMeta == 1 && unidade.isEmpty {
            return "Não desbloqueada"
        }
        // Conquista de horas: exibe com 1 casa decimal
        if unidade == "h" {
            return String(format: "%.1f / %.0f h", valorAtual, valorMeta)
        }
        let atual = valorAtual >= 1 ? String(format: "%.0f", valorAtual) : "0"
        let meta  = String(format: "%.0f", valorMeta)
        return "\(atual) / \(meta) \(unidade)"
    }
}

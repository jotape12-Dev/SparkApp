import SwiftUI
import Combine

@MainActor
class ConquistasViewModel: ObservableObject {
    @Published var conquistas: [Conquista] = []
    
    private var gerenciador: GerenciadorSessoesViewModel
    private var cancellables = Set<AnyCancellable>()

    init(gerenciador: GerenciadorSessoesViewModel) {
        self.gerenciador = gerenciador
        calcularConquistas()

        gerenciador.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.calcularConquistas()
            }
            .store(in: &cancellables)
    }

    func calcularConquistas() {
        let streak       = Double(gerenciador.calcularSequenciaAtual())
        let volumeMes    = gerenciador.obterVolumeTotalDoMesAtual()
        let totalCriados = Double(gerenciador.sessoesDeTreinoSalvas.filter { $0.isModeloIntocado != true }.count)
        let totalHist    = Double(gerenciador.historicoTreinosConcluidos.count)
        let totalHoras   = gerenciador.obterTotalHorasTreinadas()

        let madrugada   = gerenciador.temTreinoDeMadrugada()   ? 1.0 : 0.0
        let noturno     = gerenciador.temTreinoNoturno()       ? 1.0 : 0.0
        let fimDeSemana = gerenciador.temGuerreiroFimDeSemana() ? 1.0 : 0.0

        conquistas = [
            Conquista(
                titulo: "Primeira Chama",
                descricao: "Complete um ciclo completo de treinos.",
                icone: "flame",
                categoria: .sequencia,
                valorMeta: 1, valorAtual: streak, unidade: "dias"
            ),
            Conquista(
                titulo: "Semana de Fogo",
                descricao: "Mantenha uma sequência de 7 dias.",
                icone: "flame.fill",
                categoria: .sequencia,
                valorMeta: 7, valorAtual: streak, unidade: "dias"
            ),
            Conquista(
                titulo: "Mês Inabalável",
                descricao: "30 dias consecutivos de treino.",
                icone: "bolt.fill",
                categoria: .sequencia,
                valorMeta: 30, valorAtual: streak, unidade: "dias"
            ),
            Conquista(
                titulo: "Primeira Tonelada",
                descricao: "Levante 1.000 kg em um único mês.",
                icone: "scalemass",
                categoria: .volume,
                valorMeta: 1_000, valorAtual: volumeMes, unidade: "kg"
            ),
            Conquista(
                titulo: "Levantador Sério",
                descricao: "Levante 5.000 kg em um único mês.",
                icone: "scalemass.fill",
                categoria: .volume,
                valorMeta: 5_000, valorAtual: volumeMes, unidade: "kg"
            ),
            Conquista(
                titulo: "Máquina de Guerra",
                descricao: "Levante 10.000 kg em um único mês.",
                icone: "trophy.fill",
                categoria: .volume,
                valorMeta: 10_000, valorAtual: volumeMes, unidade: "kg"
            ),
            Conquista(
                titulo: "Primeiro Passo",
                descricao: "Crie o seu primeiro treino personalizado.",
                icone: "plus.circle",
                categoria: .treinoCriado,
                valorMeta: 1, valorAtual: totalCriados, unidade: "treinos"
            ),
            Conquista(
                titulo: "Rotina Montada",
                descricao: "Crie 3 treinos personalizados.",
                icone: "list.bullet.clipboard",
                categoria: .treinoCriado,
                valorMeta: 3, valorAtual: totalCriados, unidade: "treinos"
            ),
            Conquista(
                titulo: "Atleta Completo",
                descricao: "Monte 6 treinos diferentes.",
                icone: "figure.strengthtraining.traditional",
                categoria: .treinoCriado,
                valorMeta: 6, valorAtual: totalCriados, unidade: "treinos"
            ),
            Conquista(
                titulo: "Dedicado",
                descricao: "Conclua 10 treinos ao longo do tempo.",
                icone: "checkmark.seal",
                categoria: .historico,
                valorMeta: 10, valorAtual: totalHist, unidade: "treinos"
            ),
            Conquista(
                titulo: "Consistente",
                descricao: "Conclua 30 treinos no total.",
                icone: "checkmark.seal.fill",
                categoria: .historico,
                valorMeta: 30, valorAtual: totalHist, unidade: "treinos"
            ),
            Conquista(
                titulo: "Lendário",
                descricao: "100 treinos concluídos. Você é uma lenda!",
                icone: "star.fill",
                categoria: .historico,
                valorMeta: 100, valorAtual: totalHist, unidade: "treinos"
            ),
            Conquista(
                titulo: "Clube da Madrugada",
                descricao: "Conclua um treino antes das 07h da manhã.",
                icone: "moon.stars.fill",
                categoria: .habitosTreino,
                valorMeta: 1, valorAtual: madrugada, unidade: ""
            ),
            Conquista(
                titulo: "Coruja Noturna",
                descricao: "Conclua um treino depois das 21h.",
                icone: "moon.fill",
                categoria: .habitosTreino,
                valorMeta: 1, valorAtual: noturno, unidade: ""
            ),
            Conquista(
                titulo: "Guerreiro de Fim de Semana",
                descricao: "Registre treinos no sábado e no domingo da mesma semana.",
                icone: "calendar.badge.checkmark",
                categoria: .habitosTreino,
                valorMeta: 1, valorAtual: fimDeSemana, unidade: ""
            ),
            Conquista(
                titulo: "Aquecimento Concluído",
                descricao: "Acumule 5 horas totais de treino.",
                icone: "timer",
                categoria: .tempoDedicacao,
                valorMeta: 5, valorAtual: totalHoras, unidade: "h"
            ),
            Conquista(
                titulo: "Relógio de Ponto",
                descricao: "Acumule 24 horas treinando (1 dia inteiro).",
                icone: "clock.fill",
                categoria: .tempoDedicacao,
                valorMeta: 24, valorAtual: totalHoras, unidade: "h"
            ),
            Conquista(
                titulo: "Senhor do Tempo",
                descricao: "Acumule 100 horas totais de treinamento.",
                icone: "hourglass.tophalf.filled",
                categoria: .tempoDedicacao,
                valorMeta: 100, valorAtual: totalHoras, unidade: "h"
            )
        ]
    }
    var totalDesbloqueadas: Int {
        conquistas.filter { $0.estaDesbloqueada }.count
    }
    var conquistasPorCategoria: [(CategoriaConquista, [Conquista])] {
        CategoriaConquista.allCases.compactMap { cat in
            let filtradas = conquistas.filter { $0.categoria == cat }
            return filtradas.isEmpty ? nil : (cat, filtradas)
        }
    }
}

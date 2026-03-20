import SwiftUI
import Combine
import WidgetKit

@MainActor
class GerenciadorSessoesViewModel: ObservableObject {
    @Published var sessoesDeTreinoSalvas: [SessaoDeTreino] = []
    @Published var sessoesParaExibir: [SessaoDeTreino] = []
    let limiteMaximoSessoes = 6
    
    @AppStorage("sessoesConcluidasCicloAtualIDs_Data") private var sessoesConcluidasCicloAtualIDsData: Data = Data()
    @Published var sessoesConcluidasNesteCicloSet: Set<UUID> = []
    
    @AppStorage("usuarioJaTeveSessoesPersonalizadas_v1") var usuarioJaTeveSessoesPersonalizadas: Bool = false
    @AppStorage("dataUltimaSessaoIndividualConcluidaTS") var dataUltimaSessaoIndividualConcluidaTS: Double?
    
    @AppStorage("datasCiclosDeTreinoCompletos_Data") private var datasCiclosDeTreinoCompletosData: Data = Data()
    @Published var datasCiclosDeTreinoCompletosSet: Set<Date> = []
    
    @AppStorage("dataPrimeiroUsoOuTreino") var dataPrimeiroUsoOuTreinoTS: Double?
    @Published var contagemStreakAtual: Int = 0
    
    @AppStorage("objetivoUsuarioApp") var objetivoUsuarioSalvo: String = ""
    @AppStorage("treinosIniciaisAppCriados") var treinosIniciaisCriados: Bool = false

    // MARK: - Propriedades para Histórico Detalhado de Treinos
    struct TreinoConcluidoInfo: Codable, Identifiable {
        var id = UUID()
        var idSessao: UUID
        var nomeSessao: String
        var dataConclusao: Date
        var volumeTotal: Double?
        var exerciciosExecutados: [ExercicioNaSessao]?
        var duracaoSegundos: Double?
    }
    @Published var historicoTreinosConcluidos: [TreinoConcluidoInfo] = []
    @AppStorage("historicoTreinosConcluidos_v1_Data") private var historicoTreinosConcluidosData: Data = Data()

    private let treinosPredefinidos: [String: [String: [String]]] = [
        "Emagrecimento": [
            "Superior Resistência & Cardio": ["Supino Reto na máquina", "Supino Inclinado com Halteres", "Crucifixo máquina (Peck Deck)", "Elevação Frontal com Halteres (Alternada ou Bilateral)", "Elevação Lateral com Halteres", "Tríceps Pulley com Corda", "Tríceps Testa com Barra W"],
            "Aeróbico Geral & Pernas Leve": ["Corrida", "Agachamento Livre com Barra", "Bicicleta Ergométrica"],
            "Circuito HIIT Corporal": ["Burpees", "Mountain Climbers", "Jumping Jacks"]
        ],
        "Ganho de massa muscular": [
            "Peito, Ombros & Tríceps (GM)": ["Supino Reto na máquina", "Supino Inclinado com Halteres", "Crucifixo máquina (Peck Deck)", "Elevação Frontal com Halteres (Alternada ou Bilateral)", "Elevação Lateral com Halteres", "Tríceps Pulley com Corda", "Tríceps Testa com Barra W"],
            "Pernas & Panturrilhas (GM)": ["Agachamento Livre com Barra", "Leg Press 45°", "Cadeira Extensora", "Mesa Flexora", "Cadeira Flexora", "Panturrilha em Pé (Smith ou Máquina de Panturrilha)", "Panturrilha Sentado"],
            "Costas & Bíceps (GM)": ["Puxada Alta Frontal (Pulley)", "Remada Baixa (Remada Sentada na Polia)", "Pulldown com Braços Retos (Polia Alta)", "Remada Curvada com Barra", "Rosca Direta com Barra", "Rosca Inclinada com Halteres"]
        ]
    ]
    
    var podeCriarNovaSessao: Bool {
        sessoesDeTreinoSalvas.count < limiteMaximoSessoes
    }
    
    var podeRealizarSessaoHoje: Bool {
        guard let ultimaSessaoTimestamp = dataUltimaSessaoIndividualConcluidaTS else {
            return true
        }
        let ultimaDataConcluida = Date(timeIntervalSinceReferenceDate: ultimaSessaoTimestamp)
        return !Calendar.current.isDateInToday(ultimaDataConcluida)
    }

    init() {
        carregarSessoesSalvas()
        carregarSessoesConcluidasCiclo()
        carregarDatasCiclosCompletos()
        carregarHistoricoTreinosConcluidos()
        
        atualizarSessoesParaExibir()
        atualizarTreinoDoDiaNoWidget()
    }
    
    private func carregarHistoricoTreinosConcluidos() {
        if let decoded = try? JSONDecoder().decode([TreinoConcluidoInfo].self, from: historicoTreinosConcluidosData) {
            self.historicoTreinosConcluidos = decoded
        } else {
            self.historicoTreinosConcluidos = []
        }
    }
    
    func adotarTemplate(_ template: TemplatePlanoDeTreino) {
        let novasSessoes = template.sessoesDoTemplate.map { sessaoOriginal -> SessaoDeTreino in
            var novaSessao = sessaoOriginal
            novaSessao.id = UUID()
            novaSessao.isModeloIntocado = false
            novaSessao.dataCriacao = Date()
            return novaSessao
        }
        
        self.sessoesDeTreinoSalvas = novasSessoes
        self.sessoesConcluidasNesteCicloSet = []
        
        persistirSessoes(sessoesParaSalvar: self.sessoesDeTreinoSalvas)
        persistirSessoesConcluidasCiclo(setParaSalvar: [])
        atualizarSessoesParaExibir()
    }

    private func persistirHistoricoTreinosConcluidos() {
        let calendario = Calendar.current
        let dataLimite = calendario.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        let historicoRecente = self.historicoTreinosConcluidos.filter { $0.dataConclusao >= dataLimite }
        DispatchQueue.global(qos: .background).async {
            do {
                let encoded = try JSONEncoder().encode(historicoRecente)
                UserDefaults.standard.set(encoded, forKey: "historicoTreinosConcluidos_v1_Data")
            } catch {
            }
        }
    }
    
    func atualizarTreinoDoDiaNoWidget(nomeDoTreino: String) {
        if let sharedDefaults = UserDefaults(suiteName: "group.projetoJotaPe.Spark") {
            sharedDefaults.set(nomeDoTreino, forKey: "widgetNomeTreinoDoDia")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func registrarSessaoIndividualConcluida(idSessaoConcluida: UUID, dataConclusao: Date = Date(), volumeTotalSessao: Double = 0.0, duracaoSegundos: Double = 0.0) {
        let calendario = Calendar.current

        var concluidasAtualmente = self.sessoesConcluidasNesteCicloSet
        concluidasAtualmente.insert(idSessaoConcluida)
        self.sessoesConcluidasNesteCicloSet = concluidasAtualmente
        persistirSessoesConcluidasCiclo(setParaSalvar: Set(self.sessoesConcluidasNesteCicloSet))


        let dataComHora = dataConclusao
        let dataNormalizada = calendario.startOfDay(for: dataConclusao)
        self.dataUltimaSessaoIndividualConcluidaTS = dataNormalizada.timeIntervalSinceReferenceDate
        if self.dataPrimeiroUsoOuTreinoTS == nil {
            self.dataPrimeiroUsoOuTreinoTS = dataNormalizada.timeIntervalSinceReferenceDate
        }

        if let sessaoConcluida = sessoesDeTreinoSalvas.first(where: { $0.id == idSessaoConcluida }) {
            let infoConclusao = TreinoConcluidoInfo(
                idSessao: idSessaoConcluida,
                nomeSessao: sessaoConcluida.nomeSessao,
                dataConclusao: dataComHora,
                volumeTotal: volumeTotalSessao,
                exerciciosExecutados: sessaoConcluida.exercicios,
                duracaoSegundos: duracaoSegundos > 0 ? duracaoSegundos : nil
            )

            self.historicoTreinosConcluidos.append(infoConclusao)
            self.historicoTreinosConcluidos.sort { $0.dataConclusao > $1.dataConclusao }

            persistirHistoricoTreinosConcluidos()
        }
        verificarSeCicloCompleto(dataConclusaoCiclo: dataConclusao)
        
        atualizarTreinoDoDiaNoWidget()
    }

    // MARK: - Queries para Conquistas

    /// Total acumulado de horas treinadas (todos os treinos com duração registrada)
    func obterTotalHorasTreinadas() -> Double {
        let totalSegundos = historicoTreinosConcluidos
            .compactMap { $0.duracaoSegundos }
            .reduce(0, +)
        return totalSegundos / 3600.0
    }

    func temTreinoDeMadrugada() -> Bool {
        let cal = Calendar.current
        return historicoTreinosConcluidos.contains { info in
            let hora = cal.component(.hour, from: info.dataConclusao)
            return hora < 7
        }
    }


    func temTreinoNoturno() -> Bool {
        let cal = Calendar.current
        return historicoTreinosConcluidos.contains { info in
            let hora = cal.component(.hour, from: info.dataConclusao)
            return hora >= 21
        }
    }

    /// true se existe alguma semana em que há treino tanto no sábado (weekday=7) quanto no domingo (weekday=1)
    func temGuerreiroFimDeSemana() -> Bool {
        let cal = Calendar.current
        // agrupa por semana (ano + número da semana)
        var semanas: [String: Set<Int>] = [:]  // chave: "ano-semana", valor: conjunto de weekdays
        for info in historicoTreinosConcluidos {
            let ano    = cal.component(.yearForWeekOfYear, from: info.dataConclusao)
            let semana = cal.component(.weekOfYear, from: info.dataConclusao)
            let dia    = cal.component(.weekday, from: info.dataConclusao)  // 1=Dom, 7=Sáb
            let chave  = "\(ano)-\(semana)"
            semanas[chave, default: []].insert(dia)
        }
        return semanas.values.contains { $0.contains(1) && $0.contains(7) }
    }
    
    // MARK: - Função para TelaPerfil (Dados da Semana Atual FIXA D-S-T-Q-Q-S-S)
    func obterDadosSemanaAtualParaPerfil() -> [InfoDiaTreinoParaPerfil] {
        var dadosDaSemana: [InfoDiaTreinoParaPerfil] = []
        let calendario = Calendar.current
        let hoje = calendario.startOfDay(for: Date())

        let diaDaSemanaDeHoje = calendario.component(.weekday, from: hoje)
        
        
        guard let domingoDaSemanaAtual = calendario.date(byAdding: .day, value: -(diaDaSemanaDeHoje - 1), to: hoje) else {
            return []
        }

        let letrasFixasDaSemana = ["D", "S", "T", "Q", "Q", "S", "S"]

        for i in 0..<7 {
            guard let diaConsiderado = calendario.date(byAdding: .day, value: i, to: domingoDaSemanaAtual) else {
                continue
            }
            
            let letraDoDia = letrasFixasDaSemana[i]
            print("DEBUG ViewModel (Semana Atual): Loop i=\(i), Data: \(diaConsiderado.formatted(date: .numeric, time: .omitted)), Letra Atribuída: \(letraDoDia)")
            let treinoConcluidoNesteDia = historicoTreinosConcluidos.first { info in
                calendario.isDate(info.dataConclusao, inSameDayAs: diaConsiderado)
            }

            if let infoConcluida = treinoConcluidoNesteDia {
                dadosDaSemana.append(InfoDiaTreinoParaPerfil(
                    letraDia: letraDoDia,
                    nomeTreinoConcluido: infoConcluida.nomeSessao,
                    idSessaoConcluida: infoConcluida.idSessao,
                    dataRealDoDia: diaConsiderado,
                    foiConcluido: true
                ))
            } else {
                dadosDaSemana.append(InfoDiaTreinoParaPerfil(
                    letraDia: letraDoDia,
                    nomeTreinoConcluido: nil,
                    idSessaoConcluida: nil,
                    dataRealDoDia: diaConsiderado,
                    foiConcluido: false

                ))
            }
        }
        for item in dadosDaSemana {
            }
            return dadosDaSemana
    }
    
    func atualizarSessoesParaExibir() {
        sessoesParaExibir = sessoesDeTreinoSalvas
        if !usuarioJaTeveSessoesPersonalizadas && sessoesDeTreinoSalvas.contains(where: { $0.isModeloIntocado != true }) {
            usuarioJaTeveSessoesPersonalizadas = true
        }
        atualizarTreinoDoDiaNoWidget()
    }
    func obterVolumeTotalDoMesAtual() -> Double {
        let calendario = Calendar.current
        let mesAtual = calendario.component(.month, from: Date())
        let anoAtual = calendario.component(.year, from: Date())

        return historicoTreinosConcluidos.filter {
            calendario.component(.month, from: $0.dataConclusao) == mesAtual &&
            calendario.component(.year, from: $0.dataConclusao) == anoAtual
        }
        .compactMap { $0.volumeTotal } 
        .reduce(0, +)
    }
    func configurarTreinosIniciaisParaUsuario(objetivoDoUsuario: String) {
        guard !objetivoDoUsuario.isEmpty else {
            return
        }
        self.objetivoUsuarioSalvo = objetivoDoUsuario
        criarTreinosIniciaisSeNecessario()
        atualizarSessoesParaExibir()
    }
    private func criarTreinosIniciaisSeNecessario() {
        guard !treinosIniciaisCriados else {
            return
        }
        guard !objetivoUsuarioSalvo.isEmpty, let treinosParaObjetivo = treinosPredefinidos[objetivoUsuarioSalvo] else {
            return
        }
        var sessoesModeloParaAdicionar: [SessaoDeTreino] = []
        let dataCriacaoModelos = Date()
        for (nomeSessaoModelo, nomesExerciciosNoModelo) in treinosParaObjetivo {
            var exerciciosDaSessaoModelo: [ExercicioNaSessao] = []
            for nomeExercicioString in nomesExerciciosNoModelo {
                var exercicioLocalFinal: ExercicioLocal
                
                if let exercicioDetalhadoEncontrado = dadosExerciciosLocais.first(where: { $0.nome.trimmingCharacters(in: .whitespacesAndNewlines).compare(nomeExercicioString.trimmingCharacters(in: .whitespacesAndNewlines), options: .caseInsensitive) == .orderedSame }) {
                    exercicioLocalFinal = exercicioDetalhadoEncontrado
                } else {
                    exercicioLocalFinal = ExercicioLocal( nome: nomeExercicioString, grupoMuscular: "A definir", musculoPrincipal: "A definir", musculosSecundarios: nil, equipamento: nil, instrucoes: ["Consulte um profissional para instruções detalhadas."], observacoes: nil, gifUrlLocal: nil )
                }
                var seriesParaExercicio: [SerieDetalhe] = []
                if objetivoUsuarioSalvo == "Emagrecimento" && (nomeSessaoModelo == "Aeróbico Geral & Pernas Leve" || nomeSessaoModelo == "Circuito HIIT Corporal") {
                    if nomeExercicioString.lowercased().contains("corrida") || nomeExercicioString.lowercased().contains("bicicleta") {
                        seriesParaExercicio.append(SerieDetalhe(numeroSerie: 1, reps: "20-30 min", descanso: "N/A"))
                    } else {
                        seriesParaExercicio.append(SerieDetalhe(numeroSerie: 1, reps: "3-4 rounds", peso: "Máx. Reps", descanso: "60s entre rounds"))
                    }
                } else {
                    seriesParaExercicio.append(SerieDetalhe(numeroSerie: 1, reps: "8-12", peso: "", descanso: "60s"))
                    seriesParaExercicio.append(SerieDetalhe(numeroSerie: 2, reps: "8-12", peso: "", descanso: "60s"))
                    seriesParaExercicio.append(SerieDetalhe(numeroSerie: 3, reps: "8-12", peso: "", descanso: "60s"))
                }
                let exercicioNaSessao = ExercicioNaSessao(exercicioBase: exercicioLocalFinal, series: seriesParaExercicio.isEmpty ? [SerieDetalhe()] : seriesParaExercicio)
                exerciciosDaSessaoModelo.append(exercicioNaSessao)
            }
            let sessaoModelo = SessaoDeTreino( id: UUID(), nomeSessao: nomeSessaoModelo, exercicios: exerciciosDaSessaoModelo, dataCriacao: dataCriacaoModelos, isModeloIntocado: true )
            sessoesModeloParaAdicionar.append(sessaoModelo)
        }

        if !sessoesModeloParaAdicionar.isEmpty {
            let espacoDisponivel = limiteMaximoSessoes - sessoesDeTreinoSalvas.count
            if sessoesModeloParaAdicionar.count <= espacoDisponivel {
                sessoesDeTreinoSalvas.append(contentsOf: sessoesModeloParaAdicionar)
                persistirSessoes(sessoesParaSalvar: sessoesDeTreinoSalvas)
                self.treinosIniciaisCriados = true
                atualizarSessoesParaExibir()
            }
        }
    }
    func salvarOuAtualizarSessao(idSessao: UUID? = nil, nome: String, exercicios: [ExercicioNaSessao], originadoPeloBotaoMais: Bool = false) -> Bool {
            guard !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
            guard !exercicios.isEmpty else { return false }
            var sessaoModificadaComSucesso = false
            let dataAtual = Date()
            var idAlvoParaOperacao = idSessao
            if idSessao == nil && originadoPeloBotaoMais {
                if let indiceModeloASubstituir = sessoesDeTreinoSalvas.firstIndex(where: { $0.isModeloIntocado == true }) {
                    idAlvoParaOperacao = sessoesDeTreinoSalvas[indiceModeloASubstituir].id
                }
            }
            if let idExistente = idAlvoParaOperacao, let indexNaLista = sessoesDeTreinoSalvas.firstIndex(where: { $0.id == idExistente }) {
                sessoesDeTreinoSalvas[indexNaLista].nomeSessao = nome
                sessoesDeTreinoSalvas[indexNaLista].exercicios = exercicios
                if sessoesDeTreinoSalvas[indexNaLista].isModeloIntocado == true {
                    sessoesDeTreinoSalvas[indexNaLista].dataCriacao = dataAtual
                }
                sessoesDeTreinoSalvas[indexNaLista].isModeloIntocado = false
                sessaoModificadaComSucesso = true
            } else if idAlvoParaOperacao == nil && podeCriarNovaSessao {
                let novaSessao = SessaoDeTreino( id: UUID(), nomeSessao: nome, exercicios: exercicios, dataCriacao: dataAtual, isModeloIntocado: false )
                sessoesDeTreinoSalvas.append(novaSessao)
                sessaoModificadaComSucesso = true
            } else { return false }
            if sessaoModificadaComSucesso {
                persistirSessoes(sessoesParaSalvar: sessoesDeTreinoSalvas)
                if idSessao == nil && idAlvoParaOperacao == nil {
                    self.sessoesConcluidasNesteCicloSet = []
                    persistirSessoesConcluidasCiclo(setParaSalvar: [])
                }
                atualizarSessoesParaExibir()
            }
            return sessaoModificadaComSucesso
        }
    private func persistirSessoes(sessoesParaSalvar: [SessaoDeTreino]) {
        DispatchQueue.global(qos: .background).async {
            do { let encoded = try JSONEncoder().encode(sessoesParaSalvar); UserDefaults.standard.set(encoded, forKey: "sessoesSalvas") } catch { print("DEBUG: ERRO ao persistir sessões: \(error)") }
        }
    }
    private func persistirSessoesConcluidasCiclo(setParaSalvar: Set<UUID>) {
        DispatchQueue.global(qos: .background).async {
            do { let encoded = try JSONEncoder().encode(setParaSalvar); UserDefaults.standard.set(encoded, forKey: "sessoesConcluidasCicloAtualIDs_Data") } catch { print("DEBUG: ERRO ao persistir sessoesConcluidasCiclo: \(error)") }
        }
    }
    private func persistirDatasCiclosCompletos(datasParaSalvar: Set<Date>) {
        DispatchQueue.global(qos: .background).async {
            do { let encoded = try JSONEncoder().encode(datasParaSalvar); UserDefaults.standard.set(encoded, forKey: "datasCiclosDeTreinoCompletos_Data") } catch { print("DEBUG: ERRO ao persistir datasCiclosCompletos: \(error)") }
        }
    }
    func excluirSessao(at offsets: IndexSet) {
            sessoesDeTreinoSalvas.remove(atOffsets: offsets)
            self.sessoesConcluidasNesteCicloSet = []
            persistirSessoes(sessoesParaSalvar: Array(self.sessoesDeTreinoSalvas))
            persistirSessoesConcluidasCiclo(setParaSalvar: [])
            atualizarSessoesParaExibir()
            atualizarContagemStreak()
        }
    private func verificarSeCicloCompleto(dataConclusaoCiclo: Date) {
        guard !sessoesDeTreinoSalvas.isEmpty else { return }
        let todosIDsDasSessoesSalvas = Set(sessoesDeTreinoSalvas.map { $0.id })
        if sessoesConcluidasNesteCicloSet.isSuperset(of: todosIDsDasSessoesSalvas) {
            let dataNormalizada = Calendar.current.startOfDay(for: dataConclusaoCiclo)
            if !self.datasCiclosDeTreinoCompletosSet.contains(dataNormalizada) {
                self.datasCiclosDeTreinoCompletosSet.insert(dataNormalizada)
                persistirDatasCiclosCompletos(datasParaSalvar: self.datasCiclosDeTreinoCompletosSet)
            }
            self.sessoesConcluidasNesteCicloSet = []
            persistirSessoesConcluidasCiclo(setParaSalvar: [])
            atualizarContagemStreak()
        }
    }
    private func carregarSessoesSalvas() {
         if let data = UserDefaults.standard.data(forKey: "sessoesSalvas"), let decoded = try? JSONDecoder().decode([SessaoDeTreino].self, from: data) { sessoesDeTreinoSalvas = decoded }
    }
    private func carregarSessoesConcluidasCiclo() {
        if let data = UserDefaults.standard.data(forKey: "sessoesConcluidasCicloAtualIDs_Data"), let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) { sessoesConcluidasNesteCicloSet = decoded } else { sessoesConcluidasNesteCicloSet = [] }
    }
    private func carregarDatasCiclosCompletos() {
        if let data = UserDefaults.standard.data(forKey: "datasCiclosDeTreinoCompletos_Data"), let decoded = try? JSONDecoder().decode(Set<Date>.self, from: data) { datasCiclosDeTreinoCompletosSet = decoded } else { datasCiclosDeTreinoCompletosSet = [] }
        atualizarContagemStreak()
    }
    func calcularSequenciaAtual() -> Int {
        guard !datasCiclosDeTreinoCompletosSet.isEmpty else { return 0 }
        let calendario = Calendar.current
        var diaVerificando = calendario.startOfDay(for: Date())
        var sequencia = 0
        let datasOrdenadas = datasCiclosDeTreinoCompletosSet.sorted(by: >)
        for dataCiclo in datasOrdenadas {
            let dataCicloNormalizada = calendario.startOfDay(for: dataCiclo)
            if calendario.isDate(dataCicloNormalizada, inSameDayAs: diaVerificando) {
                sequencia += 1
                guard let diaAnterior = calendario.date(byAdding: .day, value: -1, to: diaVerificando) else { break }
                diaVerificando = calendario.startOfDay(for: diaAnterior)
            } else if dataCicloNormalizada < diaVerificando { break }
        }
        return sequencia
    }
    func atualizarContagemStreak() {
        self.contagemStreakAtual = calcularSequenciaAtual()
        
        // Compartilha o número de dias seguidos atual com a extensão do Widget usando App Groups
        if let sharedDefaults = UserDefaults(suiteName: "group.projetoJotaPe.Spark") {
            sharedDefaults.set(self.contagemStreakAtual, forKey: "widgetContagemStreak")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    func atualizarTreinoDoDiaNoWidget() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.SparkApp") else { return }
        
        let treinosPendentes = sessoesDeTreinoSalvas.filter { sessao in
            !sessoesConcluidasNesteCicloSet.contains(sessao.id)
        }
        
        let nomeTreinoHoje = treinosPendentes.first?.nomeSessao ?? "Dia de descanso 🥳"
        
        sharedDefaults.set(nomeTreinoHoje, forKey: "widgetNomeTreinoDoDia")
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}

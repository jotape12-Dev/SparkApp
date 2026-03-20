import Foundation

struct TemplatePlanoDeTreino: Identifiable {
    let id = UUID()
    let nomeTemplate: String
    let objetivoAssociado: String
    let descricao: String
    let sessoesDoTemplate: [SessaoDeTreino]
}

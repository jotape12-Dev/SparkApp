import Foundation
import Combine

struct AITreinoDTO: Decodable {
    let nomeSessao: String
    let exercicios: [AIExercicioNaSessaoDTO]
}

struct AIExercicioNaSessaoDTO: Decodable {
    let exercicioBase: AIExercicioLocalDTO
    let series: [AISerieDetalheDTO]
}

struct AIExercicioLocalDTO: Decodable {
    let nome: String
    let grupoMuscular: String
    let musculoPrincipal: String
    let musculosSecundarios: [String]?
    let equipamento: String?
    let instrucoes: [String]?
    let observacoes: String?
    let gifUrlLocal: String?
}

struct AISerieDetalheDTO: Decodable {
    let numeroSerie: Int
    let reps: String? 
    let peso: String?
    let descanso: String?
}

// MARK: - Extensão para converter DTOs para os Modelos Nativos do App
extension AITreinoDTO {
    func toSessaoDeTreino() -> SessaoDeTreino {
        let exerciciosMapeados = self.exercicios.map { dtoExercicio in
            let instrucoesSeguras = dtoExercicio.exercicioBase.instrucoes ?? []
            let exercicioLocal = ExercicioLocal(
                id: UUID(),
                nome: dtoExercicio.exercicioBase.nome,
                grupoMuscular: dtoExercicio.exercicioBase.grupoMuscular,
                musculoPrincipal: dtoExercicio.exercicioBase.musculoPrincipal,
                musculosSecundarios: dtoExercicio.exercicioBase.musculosSecundarios,
                equipamento: dtoExercicio.exercicioBase.equipamento,
                instrucoes: instrucoesSeguras.isEmpty ? ["Siga a execução correta."] : instrucoesSeguras,
                observacoes: dtoExercicio.exercicioBase.observacoes,
                gifUrlLocal: dtoExercicio.exercicioBase.gifUrlLocal
            )
            
            let seriesMapeadas = dtoExercicio.series.map { dtoSerie in
                let repsFinal = (dtoSerie.reps ?? "").isEmpty ? "10" : dtoSerie.reps!
                let descansoFinal = (dtoSerie.descanso ?? "").isEmpty ? "60s" : dtoSerie.descanso!
                let pesoFinal = dtoSerie.peso ?? ""
                
                return SerieDetalhe(
                    id: UUID(),
                    numeroSerie: dtoSerie.numeroSerie,
                    reps: repsFinal,
                    peso: pesoFinal,
                    descanso: descansoFinal,
                    concluida: false
                )
            }
            
            return ExercicioNaSessao(
                id: UUID(),
                exercicioBase: exercicioLocal,
                series: seriesMapeadas.isEmpty ? [SerieDetalhe(numeroSerie: 1, reps: "10")] : seriesMapeadas
            )
        }
        
        return SessaoDeTreino(
            id: UUID(),
            nomeSessao: self.nomeSessao.isEmpty ? "Treino Gerado por IA" : self.nomeSessao,
            exercicios: exerciciosMapeados,
            dataCriacao: Date(),
            isModeloIntocado: false
        )
    }
}

class AIGeneratorService {
    static let shared = AIGeneratorService()
    
    // A chave agora é lida do Config.xcconfig via Info.plist de forma segura
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String, !key.isEmpty else {
            return ""
        }
        return key
    }
    
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key="
    
    private let systemPrompt = """
    Você é um personal trainer especialista e altamente técnico. O usuário fornecerá um objetivo ou preferência de treino.
    Seu objetivo é criar um treino detalhado e seguro, retornando as informações EXATAMENTE no formato JSON requerido abaixo.
    
    Formato JSON esperado:
    {
      "nomeSessao": "Nome do Treino (ex: Treino de Pernas Focado em Glúteos)",
      "exercicios": [
        {
          "exercicioBase": {
            "nome": "Nome do Exercício",
            "grupoMuscular": "Pernas",
            "musculoPrincipal": "Glúteo Máximo",
            "musculosSecundarios": ["Isquiotibiais"],
            "equipamento": "Halteres",
            "instrucoes": ["Passo 1 de execução", "Passo 2 de execução"],
            "observacoes": "Dica importante (ou null)",
            "gifUrlLocal": null
          },
          "series": [
            {
              "numeroSerie": 1,
              "reps": "10-12",
              "peso": "",
              "descanso": "60s"
            }
          ]
        }
      ]
    }
    
    Regras adicionais:
    - O treino deve conter pelo menos 3 a 5 exercícios baseados no pedido do usuário.
    - Para cada exercício crie a quantidade certa de séries (geralmente 3 ou 4) aumentando o numeroSerie 1, 2, 3...
    - Se o usuário especificar não usar equipamentos, respeite isso no campo 'equipamento'.
    """
    
    func gerarTreino(promptUsuario: String) async throws -> AITreinoDTO {
        let currentKey = apiKey
        guard !currentKey.isEmpty else {
            print("AIGeneratorService [ERRO]: Chave GEMINI_API_KEY ausente. Você vinculou a variável no Info.plist apontando para o arquivo .xcconfig?")
            throw URLError(.userAuthenticationRequired)
        }
        
        let fullEndpoint = "\(endpoint)\(currentKey)"
        guard let url = URL(string: fullEndpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "systemInstruction": [
                "parts": [
                    ["text": systemPrompt]
                ]
            ],
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": promptUsuario]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "responseMimeType": "application/json"
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Erro desconhecido na resposta JSON HTTP."
            print("AIGeneratorService [ERRO DA API GEMINI]: \(errorMsg) | Status Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            throw URLError(.badServerResponse)
        }
        
        struct GeminiResponse: Decodable {
            let candidates: [Candidate]?
            struct Candidate: Decodable {
                let content: Content
            }
            struct Content: Decodable {
                let parts: [Part]
            }
            struct Part: Decodable {
                let text: String
            }
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let jsonString = geminiResponse.candidates?.first?.content.parts.first?.text else {
            throw URLError(.cannotParseResponse)
        }
        
        var cleanedJSON = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedJSON.hasPrefix("```json") {
            cleanedJSON = cleanedJSON.replacingOccurrences(of: "```json\n", with: "")
            cleanedJSON = cleanedJSON.replacingOccurrences(of: "```", with: "")
        } else if cleanedJSON.hasPrefix("```") {
            cleanedJSON = cleanedJSON.replacingOccurrences(of: "```\n", with: "")
            cleanedJSON = cleanedJSON.replacingOccurrences(of: "```", with: "")
        }
        
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }
        
        do {
            let treinoDTO = try JSONDecoder().decode(AITreinoDTO.self, from: jsonData)
            return treinoDTO
        } catch {
            print("AIGeneratorService [ERRO DE DECODIFICAÇÃO]: \(error)")
            throw error
        }
    }
}

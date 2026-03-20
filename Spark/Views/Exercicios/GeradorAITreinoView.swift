import SwiftUI
import UIKit

struct GeradorAITreinoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gerenciadorDeSessoes: GerenciadorSessoesViewModel
    
    @State private var prompt: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    var onTreinoGerado: ((SessaoDeTreino) -> Void)?
    
    init(onTreinoGerado: ((SessaoDeTreino) -> Void)? = nil) {
        self.onTreinoGerado = onTreinoGerado
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Gerador por IA ✨")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top)
                
                Text("Descreva exatamente como quer seu treino. Você pode especificar o grupo muscular, tempo disponível, aparelhos, e mais.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                    
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("CorBotao").opacity(0.3), lineWidth: 1)
                    
                    if prompt.isEmpty {
                        Text("Ex: Quero um treino de pernas rápido de 40 minutos com foco em glúteos e sem usar barra livre...")
                            .foregroundColor(Color.gray.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                    
                    if #available(iOS 16.0, *) {
                        TextEditor(text: $prompt)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.clear)
                            .opacity(prompt.isEmpty ? 0.3 : 1)
                    } else {
                        TextEditor(text: $prompt)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.clear)
                            .opacity(prompt.isEmpty ? 0.3 : 1)
                    }
                }
                .frame(height: 180)
                
                if let error = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                            .font(.footnote)
                    }
                    .foregroundColor(Color("CorBotao"))
                    .padding(.top, 4)
                }
                
                Spacer()
                
                Button(action: {
                    gerarTreinoAction()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                            Text("A magia está acontecendo...")
                                .fontWeight(.semibold)
                        } else {
                            Image(systemName: "sparkles")
                            Text("Gerar Treino")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("CorBotao"))
                    .cornerRadius(12)
                    .shadow(color: Color("CorBotao").opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isLoading || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity((isLoading || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.6 : 1.0)
                .padding(.bottom)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func gerarTreinoAction() {
        let userPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userPrompt.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let dto = try await AIGeneratorService.shared.gerarTreino(promptUsuario: userPrompt)
                
                let novaSessao = dto.toSessaoDeTreino()
                
                await MainActor.run {
                    let sucesso = gerenciadorDeSessoes.salvarOuAtualizarSessao(
                        nome: novaSessao.nomeSessao,
                        exercicios: novaSessao.exercicios,
                        originadoPeloBotaoMais: false
                    )
                    
                    if sucesso {
                        isLoading = false
                        let sessaoSalva = gerenciadorDeSessoes.sessoesDeTreinoSalvas.last ?? novaSessao
                        dismiss() 
                        onTreinoGerado?(sessaoSalva)
                    } else {
                        errorMessage = "Falha ao salvar a sessão automaticamente."
                        isLoading = false
                    }
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Erro ao acessar a IA. Verifique sua chave de internet ou API Key no AIGeneratorService."
                    print("AIGeneratorService Error: \(error)")
                }
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

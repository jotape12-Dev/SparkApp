import SwiftUI

struct TreinosTemplatesView: View {
    @Binding var voltarParaRaiz: Bool
    let corDeFundoPrincipal = Color("BackgroundColor")
    
    init(voltarParaRaiz: Binding<Bool>) {
        self._voltarParaRaiz = voltarParaRaiz
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    
    var body: some View {
        ZStack {
            corDeFundoPrincipal.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(dadosTemplates, id: \.nomeTemplate) { template in
                        NavigationLink(destination: DetalheTemplateView(voltarParaRaiz: $voltarParaRaiz, template: template)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(template.nomeTemplate)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(template.objetivoAssociado)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("CorBotao"))
                                
                                Text("\(template.sessoesDoTemplate.count) treinos na rotina")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("ColorCard"))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Templates")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark)
    }
}

struct DetalheTemplateView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gerenciadorSessoes: GerenciadorSessoesViewModel
    @Binding var voltarParaRaiz: Bool
    
    let template: TemplatePlanoDeTreino
    
    @State private var mostrarAlertaSubstituicao = false
    @State private var navegacaoConcluida = false
    
    let corDeFundoPrincipal = Color("BackgroundColor")
    let corBotaoPrincipal = Color("CorBotao")
    
    var body: some View {
        ZStack {
            corDeFundoPrincipal.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(template.descricao)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        Divider()
                            .background(Color.gray.opacity(0.5))
                        
                        ForEach(template.sessoesDoTemplate) { sessao in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(sessao.nomeSessao)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(corBotaoPrincipal)
                                
                                ForEach(sessao.exercicios) { exercicioNaSessao in
                                    HStack {
                                        Text("• \(exercicioNaSessao.exercicioBase.nome)")
                                            .font(.callout)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(exercicioNaSessao.series.count) séries")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding()
                }
                
                Button(action: {
                    mostrarAlertaSubstituicao = true
                }) {
                    Text("Usar esta Rotina")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(corBotaoPrincipal)
                        .cornerRadius(15)
                }
                .padding()
                .padding(.bottom, 10)
            }
        }
        .navigationTitle(template.nomeTemplate)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Atenção!", isPresented: $mostrarAlertaSubstituicao) {
            Button("Cancelar", role: .cancel) { }
            Button("Substituir", role: .destructive) {
                gerenciadorSessoes.adotarTemplate(template)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    voltarParaRaiz = false
                }
            }
        } message: {
            Text("Adotar este template irá apagar todos os seus treinos atuais e substituí-los por estes. Deseja continuar?")
        }
    }
}

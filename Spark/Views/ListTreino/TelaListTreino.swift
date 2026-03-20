import SwiftUI

struct TelaListTreino: View {
    @State var addModelPresented = false
    @State private var navegarParaEscolha = false
    @EnvironmentObject private var gerenciadorSessoes: GerenciadorSessoesViewModel
    
    @State private var sessoesLocais: [SessaoDeTreino] = []
    
    let corDeFundoPrincipal = Color("BackgroundColor")
    let corTextoPrincipal = Color.white

    private var headerView: some View {
        HStack {
            Text("Seu plano de treino")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(corTextoPrincipal)
            Spacer()

            Button {
                navegarParaEscolha = true
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor(Color("CorBotao"))
                    .padding(8)
            }
        }
        .padding(.horizontal)
        .padding(.top, UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0 > 20 ? 15 : 30)
        .padding(.bottom, 10)
    }

    private var listaDeTreinosView: some View {
        ScrollView {
            VStack(spacing: 12) {
                if sessoesLocais.isEmpty {
                    Text("Nenhum treino personalizado salvo.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 50)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(sessoesLocais, id: \.id) { sessao in
                        NavigationLink(destination:
                            AddModel(idSessaoEditando: sessao.id)
                                .environmentObject(gerenciadorSessoes)
                        ) {
                            CardTreinoEditavel(
                                titulo: sessao.nomeSessao,
                                exercicios: sessao.exercicios.map { $0.exercicioBase.nome }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                corDeFundoPrincipal.edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 0) {
                    headerView
                    listaDeTreinosView
                }
            }
            .navigationDestination(isPresented: $navegarParaEscolha) {
                EscolhaCriacaoTreinoView(voltarParaRaiz: $navegarParaEscolha)
                    .environmentObject(gerenciadorSessoes)
            }
            .sheet(isPresented: $addModelPresented) {
                AddModel()
                    .environmentObject(gerenciadorSessoes)
                    .interactiveDismissDisabled(true)
            }
            .navigationTitle("")
        }
        .navigationBarHidden(true)
        .onReceive(gerenciadorSessoes.$sessoesDeTreinoSalvas) { novasSessoes in
            self.sessoesLocais = novasSessoes
        }
        .onAppear {
            self.sessoesLocais = gerenciadorSessoes.sessoesDeTreinoSalvas
        }
    }
}

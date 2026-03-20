import SwiftUI

struct TelaPerfil: View {
    @EnvironmentObject var gerenciadorSessoes: GerenciadorSessoesViewModel

    @AppStorage("nomeUsuario") var nomeUsuario: String = ""
    @AppStorage("idadeUsuario") var idade: Int = 0
    @AppStorage("alturaUsuario") var alturaCm: Int = 0
    @AppStorage("pesoUsuario") var pesoKg: Double = 0.0
    @AppStorage("profileImageData") private var profileImageData: Data?
    
    @State private var sequenciaDias: [DiaSequencia] = []
    
    let corDeFundoPrincipal = Color("BackgroundColor")
    let corTextoSecundario = Color.gray
    let corDestaque = Color(red: 233/255, green: 9/255, blue: 22/255)
    
    @State private var showingEditSheet = false
    
    @State private var showingDetalheTreinoSheet = false
    @State private var sessaoSelecionadaParaDetalhe: SessaoDeTreino? = nil

    var body: some View {
        ZStack {
            corDeFundoPrincipal.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 30) {
                    HStack(spacing: 20) {
                        if let data = profileImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(corTextoSecundario)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack{
                                Text(nomeUsuario.isEmpty ? "Usuário" : nomeUsuario)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Button(action: { showingEditSheet = true }) {
                                    Image(systemName: "pencil")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                        .padding(.leading)
                                }
                            }
                            Text(idade > 0 ? "\(idade) anos" : "Idade não informada")
                                .font(.subheadline)
                                .foregroundColor(corTextoSecundario)
                            Text(alturaCm > 0 ? "\(String(format: "%.2f", Double(alturaCm)/100.0)) m" : "Altura não informada")
                                .font(.subheadline)
                                .foregroundColor(corTextoSecundario)
                            Text(pesoKg > 0 ? "\(String(format: "%.1f", pesoKg)) kg" : "Peso não informado")
                                .font(.subheadline)
                                .foregroundColor(corTextoSecundario)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    CardResumoMensalView(volumeTotal: gerenciadorSessoes.obterVolumeTotalDoMesAtual())
                        .padding(.horizontal)
                        .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        if sequenciaDias.isEmpty {
                            Text("Carregando dados da semana...")
                                .font(.caption)
                                .foregroundColor(corTextoSecundario)
                                .padding(.horizontal)
                                .padding(.top, 5)
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Histórico Mensal")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                
                                CalendarioMensalView(
                                    sessaoSelecionada: $sessaoSelecionadaParaDetalhe,
                                    mostrarDetalhe: $showingDetalheTreinoSheet
                                )
                                    .environmentObject(gerenciadorSessoes)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                 TelaEditarPerfil(
                    nomeUsuario: $nomeUsuario,
                    idadeUsuario: $idade,
                    alturaUsuarioCm: $alturaCm,
                    pesoUsuarioKg: $pesoKg
                 )
                .interactiveDismissDisabled(true)
            }
            .sheet(item: $sessaoSelecionadaParaDetalhe) { sessao in
                DetalheTreinoConcluidoView(
                    sessao:
                        sessao
                )
                    .environmentObject(gerenciadorSessoes)
            }
            .onAppear {
                carregarDadosDaSequencia()
            }
        }
    func carregarDadosDaSequencia() {
        let infosDaSemanaViewModel = gerenciadorSessoes.obterDadosSemanaAtualParaPerfil()
        
        self.sequenciaDias = infosDaSemanaViewModel.map { infoDiaVM -> DiaSequencia in
            return DiaSequencia(
                    letra: infoDiaVM.letraDia,
                    treinoInfo: infoDiaVM.nomeTreinoConcluido,
                    estaDestacado: infoDiaVM.foiConcluido,
                    data: infoDiaVM.dataRealDoDia,
                    idSessao: infoDiaVM.idSessaoConcluida
                )
        }
        print("TelaPerfil: sequenciaDias atualizada com \(self.sequenciaDias.count) dias da semana ATUAL.")
    }
}


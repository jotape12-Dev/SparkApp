import SwiftUI

struct TelaConquistas: View {
    @EnvironmentObject var gerenciadorSessoes: GerenciadorSessoesViewModel

    var body: some View {
        TelaConquistasConteudo(gerenciador: gerenciadorSessoes)
    }
}

struct TelaConquistasConteudo: View {
    @StateObject private var vm: ConquistasViewModel

    private let corDestaque = Color(red: 233/255, green: 9/255, blue: 22/255)
    private let corFundo = Color("BackgroundColor")

    init(gerenciador: GerenciadorSessoesViewModel) {
        _vm = StateObject(wrappedValue: ConquistasViewModel(gerenciador: gerenciador))
    }

    var body: some View {
        ZStack {
            corFundo.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    headerView

                    ForEach(vm.conquistasPorCategoria, id: \.0) { categoria, lista in
                        seçaoCategoria(categoria: categoria, conquistas: lista)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            vm.calcularConquistas()
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Conquistas")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(corDestaque)
                Text("\(vm.totalDesbloqueadas) de \(vm.conquistas.count) desbloqueadas")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(
                            colors: [corDestaque, corDestaque.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(
                            width: vm.conquistas.isEmpty ? 0
                                : geo.size.width * (CGFloat(vm.totalDesbloqueadas) / CGFloat(vm.conquistas.count)),
                            height: 8
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: vm.totalDesbloqueadas)
                }
            }
            .frame(height: 8)
            .padding(.top, 2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.13, green: 0.12, blue: 0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(corDestaque.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func seçaoCategoria(categoria: CategoriaConquista, conquistas: [Conquista]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: iconeCategoria(categoria))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(corDestaque)
                Text(categoria.rawValue.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .tracking(1.2)
            }
            .padding(.leading, 4)

            VStack(spacing: 10) {
                ForEach(conquistas) { conquista in
                    ConquistaCardView(conquista: conquista)
                }
            }
        }
    }

    private func iconeCategoria(_ cat: CategoriaConquista) -> String {
        switch cat {
        case .sequencia:     return "flame.fill"
        case .volume:        return "scalemass.fill"
        case .treinoCriado:  return "list.bullet.clipboard.fill"
        case .historico:     return "clock.fill"
        case .habitosTreino: return "moon.stars.fill"
        case .tempoDedicacao: return "timer"
        }
    }
}

#Preview {
    TabView {
        TelaConquistas()
            .environmentObject(GerenciadorSessoesViewModel())
            .tabItem {
                Image(systemName: "trophy")
                Text("Conquistas")
            }
    }
    .preferredColorScheme(.dark)
}

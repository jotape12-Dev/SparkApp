import SwiftUI

struct MainTabView: View {
    @State private var abaSelecionada: Int = 0
    
    @StateObject var gerenciadorSessoes = GerenciadorSessoesViewModel()

    var body: some View {
        TabView(selection: $abaSelecionada) {
            
            TelaListTreino()
                .environmentObject(gerenciadorSessoes)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Planos")
                }
                .tag(0)
            
            TelaTreinos()
                .environmentObject(gerenciadorSessoes)
                .tabItem {
                    Image(systemName: "figure.strengthtraining.traditional")
                    Text("Treinar")
                }
                .tag(1)
            
            TelaPerfil()
                .environmentObject(gerenciadorSessoes)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
                .tag(2)
            
            TelaConquistas()
                .environmentObject(gerenciadorSessoes)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Conquistas")
                }
                .tag(3)
        }
        .accentColor(Color("CorBotao"))
        .onOpenURL { url in
            if url.scheme == "sparkapp" && url.host == "telaTreinos" {
                abaSelecionada = 1
            }
        }
    }
}

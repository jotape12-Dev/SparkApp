import SwiftUI

@main
struct SparkApp: App {
    @AppStorage("cadastroConcluido") var cadastroConcluido = false
    @StateObject private var gerenciadorSessoes = GerenciadorSessoesViewModel()
    var body: some Scene {
        WindowGroup {
            if cadastroConcluido {
              MainTabView()
                    .environmentObject(gerenciadorSessoes)
            }else {
                WelcomeView()
                    .environmentObject(gerenciadorSessoes)
            }
        }
    }
}

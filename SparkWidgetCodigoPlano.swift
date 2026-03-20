import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), streak: 5)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), streak: carregarStreak())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Pega a streak baseada no App Group preenchido pelo GerenciadorDeSessoes
        let entry = SimpleEntry(date: Date(), streak: carregarStreak())
        
        // Configura uma atualização agendada se for um novo dia ou atualiza sob demanda
        let nextUpdate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func carregarStreak() -> Int {
        // Lê a UserDefaults do App Group compartilhado com o App Principal
        let sharedDefaults = UserDefaults(suiteName: "group.com.spark.app")
        return sharedDefaults?.integer(forKey: "widgetContagemStreak") ?? 0
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let streak: Int
}

struct SparkWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text("🔥")
                .font(.system(size: 44))
                .shadow(color: Color.orange.opacity(0.8), radius: 10, x: 0, y: 0)
            
            Text("\(entry.streak)")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.86, green: 0.0, blue: 0.08)) // Vermelho/CorBotao do app
            
            Text(entry.streak == 1 ? "dia seguido" : "dias seguidos")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        // Fundo escuro igual o app principal
        .background(Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea())
    }
}

@main
struct SparkWidget: Widget {
    let kind: String = "SparkWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SparkWidgetEntryView(entry: entry)
                    .containerBackground(Color(red: 0.08, green: 0.08, blue: 0.08), for: .widget)
            } else {
                SparkWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Sequência (Streak)")
        .description("Acompanhe o quão longe você chegou na sua rotina de treinos diretamente da tela inicial.")
        .supportedFamilies([.systemSmall])
    }
}

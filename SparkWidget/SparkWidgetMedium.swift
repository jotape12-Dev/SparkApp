//
//  SparkWidgetMedium.swift
//  Spark
//
//  Created by Jota Pe on 20/03/26.
//

import WidgetKit
import SwiftUI

struct TreinoDoDiaEntry: TimelineEntry {
    let date: Date
    let nomeTreino: String
}

struct TreinoDoDiaProvider: TimelineProvider {
    func placeholder(in context: Context) -> TreinoDoDiaEntry {
        TreinoDoDiaEntry(date: Date(), nomeTreino: "Treino de Peito e Tríceps")
    }

    func getSnapshot(in context: Context, completion: @escaping (TreinoDoDiaEntry) -> ()) {
        let entry = TreinoDoDiaEntry(date: Date(), nomeTreino: "Treino de Costas")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.projetoJotaPe.Spark")
        let nomeSalvo = sharedDefaults?.string(forKey: "widgetNomeTreinoDoDia") ?? "Descanso ou Livre"
        
        let entry = TreinoDoDiaEntry(date: Date(), nomeTreino: nomeSalvo)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct TreinoDoDiaWidgetView : View {
    var entry: TreinoDoDiaProvider.Entry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundColor(Color("CorBotao"))
                    Text("TREINO DE HOJE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Text(entry.nomeTreino)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Spacer()
                
                Text("Começar Treino")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("CorBotao"))
                    .cornerRadius(8)
            }
            Spacer()
        }
        .widgetURL(URL(string: "sparkapp://telaTreinos"))
    }
}

struct TreinoDoDiaWidget: Widget {
    let kind: String = "TreinoDoDiaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TreinoDoDiaProvider()) { entry in
            if #available(iOS 17.0, *) {
                TreinoDoDiaWidgetView(entry: entry)
                    .containerBackground(Color("BackgroundColor"), for: .widget)
            } else {
                TreinoDoDiaWidgetView(entry: entry)
                    .padding()
                    .background(Color("BackgroundColor"))
            }
        }
        .configurationDisplayName("Treino do Dia")
        .description("Veja rapidamente qual é o seu treino de hoje.")
        .supportedFamilies([.systemMedium])
    }
}

//
//  SparkWidget.swift
//  SparkWidget
//
//  Created by Jota Pe on 20/03/26.
//

import WidgetKit
import SwiftUI

struct StreakEntry: TimelineEntry {
    let date: Date
    let streakCount: Int
}

struct StreakProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streakCount: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> ()) {
        let entry = StreakEntry(date: Date(), streakCount: 5)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.projetoJotaPe.Spark")
        let currentStreak = sharedDefaults?.integer(forKey: "widgetContagemStreak") ?? 0
        
        let entry = StreakEntry(date: Date(), streakCount: currentStreak)
        
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct StreakWidgetEntryView : View {
    var entry: StreakProvider.Entry

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundColor(Color("CorBotao"))
            
            Text("Sequência")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(entry.streakCount) dias")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(entry.streakCount > 0 ? Color("CorBotao") : .white)
        }
    }
}

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            if #available(iOS 17.0, *) {
                StreakWidgetEntryView(entry: entry)
                    .containerBackground(Color("BackgroundColor"), for: .widget)
            } else {
                StreakWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color("BackgroundColor"))
            }
        }
        .configurationDisplayName("Sua Sequência")
        .description("Acompanhe seus dias de treino seguidos.")
        .supportedFamilies([.systemSmall])
    }
}

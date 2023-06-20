//
//  FoodFlare_Widget.swift
//  FoodFlare Widget
//
//  Created by Jan Pink on 20.06.23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), calories: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), calories: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        DataFetcher.shared.fetchTodayCalories() { calories in
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, calories: calories)
            let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(60*60)))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let calories: Int
}

struct FoodFlare_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Calories:")
            Text("\(entry.calories)")
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct FoodFlare_Widget: Widget {
    let kind: String = "FoodFlare_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FoodFlare_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This widget shows today's calorie intake.")
    }
}

struct FoodFlare_Widget_Previews: PreviewProvider {
    static var previews: some View {
        FoodFlare_WidgetEntryView(entry: SimpleEntry(date: .now, calories: 1200))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

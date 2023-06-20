//
//  FoodFlare_WidgetLiveActivity.swift
//  FoodFlare Widget
//
//  Created by Jan Pink on 20.06.23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FoodFlare_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FoodFlare_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FoodFlare_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FoodFlare_WidgetAttributes {
    fileprivate static var preview: FoodFlare_WidgetAttributes {
        FoodFlare_WidgetAttributes(name: "World")
    }
}

extension FoodFlare_WidgetAttributes.ContentState {
    fileprivate static var smiley: FoodFlare_WidgetAttributes.ContentState {
        FoodFlare_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FoodFlare_WidgetAttributes.ContentState {
         FoodFlare_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FoodFlare_WidgetAttributes.preview) {
   FoodFlare_WidgetLiveActivity()
} contentStates: {
    FoodFlare_WidgetAttributes.ContentState.smiley
    FoodFlare_WidgetAttributes.ContentState.starEyes
}

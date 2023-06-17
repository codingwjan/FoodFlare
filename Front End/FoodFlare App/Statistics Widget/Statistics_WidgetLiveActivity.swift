//
//  Statistics_WidgetLiveActivity.swift
//  Statistics Widget
//
//  Created by Jan Pink on 17.06.23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Statistics_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Statistics_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Statistics_WidgetAttributes.self) { context in
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

extension Statistics_WidgetAttributes {
    fileprivate static var preview: Statistics_WidgetAttributes {
        Statistics_WidgetAttributes(name: "World")
    }
}

extension Statistics_WidgetAttributes.ContentState {
    fileprivate static var smiley: Statistics_WidgetAttributes.ContentState {
        Statistics_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Statistics_WidgetAttributes.ContentState {
         Statistics_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Statistics_WidgetAttributes.preview) {
   Statistics_WidgetLiveActivity()
} contentStates: {
    Statistics_WidgetAttributes.ContentState.smiley
    Statistics_WidgetAttributes.ContentState.starEyes
}

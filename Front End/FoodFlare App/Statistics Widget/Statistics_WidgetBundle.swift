//
//  Statistics_WidgetBundle.swift
//  Statistics Widget
//
//  Created by Jan Pink on 17.06.23.
//

import WidgetKit
import SwiftUI

@main
struct Statistics_WidgetBundle: WidgetBundle {
    var body: some Widget {
        Statistics_Widget()
        Statistics_WidgetLiveActivity()
    }
}

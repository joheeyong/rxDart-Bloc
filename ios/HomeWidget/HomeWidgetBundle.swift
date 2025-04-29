//
//  HomeWidgetBundle.swift
//  HomeWidget
//
//  Created by 조희용 on 4/29/25.
//

import WidgetKit
import SwiftUI

@main
struct HomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeWidget()
        HomeWidgetControl()
        HomeWidgetLiveActivity()
    }
}

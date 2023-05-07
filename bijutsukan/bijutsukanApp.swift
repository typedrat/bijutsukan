//
//  bijutsukanApp.swift
//  bijutsukan
//
//  Created by Alexis Williams on 4/15/23.
//

import SwiftUI

@main
struct bijutsukanApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                BooruListView()
            } detail: {
                EmptyView()
            }
        }
    }
}

//
//  bijutsukanApp.swift
//  bijutsukan
//
//  Created by Alexis Williams on 4/15/23.
//

import SwiftUI

@main
struct bijutsukanApp: App {
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                BooruListView() { booru in
                    Text(booru.name)
                }
            } detail: {
                EmptyView()
            }
        }
    }
}

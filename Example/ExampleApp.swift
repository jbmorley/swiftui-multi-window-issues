//
//  ExampleApp.swift
//  Example
//
//  Created by Jason Barrie Morley on 26/03/2024.
//

import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            // The `.handlesExternalEvents` view modifier with an empty `allowing` set causes launches from the
            // iPadOS application library to open new windows. This implies that iPadOS is sending us a different kind
            // of continuation event which our view is ignoring.
            ContentView()
                .handlesExternalEvents(preferring: [], allowing: [])
        }
    }
}

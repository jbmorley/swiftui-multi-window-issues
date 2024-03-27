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

        WindowGroup(id: "main") {
            // The `.handlesExternalEvents` view modifier with an empty `allowing` set causes launches from the
            // iPadOS App Library to open new windows. Pasing a wildcard to the `allowing` parameter causes the app to
            // work 'normally', foregrounding the app when launche from the App Library. This implies that iPadOS is
            // sending us a different kind of continuation event which our view is (incorrectly?) ignoring.
            // When allowing the wildcard, the event is not passed to an `.onOpenURL` modifier.
            ContentView(name: "Main")
                .background(.pink)
                .onOpenURL { url in
                    print("Main: \(url)")
                }
                .handlesExternalEvents(preferring: [URL.main.absoluteString], allowing: [])
                // .handlesExternalEvents(preferring: [URL.main.absoluteString], allowing: ["*"])  <-- this works 'normally'
                //
                // The above line of code (including the wildcard in `allowing` ensures that we don't end up with a new
                // window every time the app is opened from the App Library on iPadOS, but it also breaks the openURL
                // behavior as our foreground window now accepts any incoming URL. *facepalm*
        }
        .handlesExternalEvents(matching: [URL.main.absoluteString])

        WindowGroup(id: "info") {
            ContentView(name: "Info")
                .background(.cyan)
                .onOpenURL { url in
                    print("Info: \(url)")
                }
                .handlesExternalEvents(preferring: [URL.info.absoluteString], allowing: [])
        }
        .handlesExternalEvents(matching: [URL.info.absoluteString])

    }
}

//
//  ContentView.swift
//  Example
//
//  Created by Jason Barrie Morley on 26/03/2024.
//

import SwiftUI

struct ContentView: View {

    @Environment(\.openURL) private var openURL

    let name: String

    var body: some View {
        VStack {
            Text(name)
            Button {
                openURL(.main)
            } label: {
                Text("Open Main Window")
            }
            Button {
                openURL(.info)
            } label: {
                Text("Open Info Window")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView(name: "Name")
}

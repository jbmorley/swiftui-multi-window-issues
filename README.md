# SwiftUI Multi-Window Issues

Minimal app demonstrating unexpected multi-window behavior on iPadOS

## Discussion

I'm using `handlesExternalEvents(matching:)` and `handlesExternalEvents(preferring:allowing:)` to handle OAuth authentication and user activity continuation (especially opening and foregrounding windows on macOS).

My production app looks something like this:

```swift
extension URL {
  static let auth = URL(string: "x-example-auth://oauth")!
  static let main = URL(string: "x-example://main")!
}

struct ExampleApp: App {
    var body: some Scene {
      WindowGroup(id: "main") {
        ContentView()
          .onOpenURL { url in
            /* ... */
          }
          .handlesExternalEvents(preferring: [
                                   URL.auth.absoluteString,
                                   URL.main.absoluteString,
                                 ],
                                 allowing: [])
        }
        .handlesExternalEvents(matching: [
                                 URL.auth.absoluteString,
                                 URL.main.absoluteString
                              ])
      }
    }
  }
}
```

This ensures my app receives OAuth callbacks and allows me to foreground an existing window on Mac, iPhone and iPad using `openURL(.main)`. 🥳

**But!** It also introduces a curious side effect on iPadOS...

On iPadOS, launching the application from the App Library, will always create a new window. I've pinned this down to passing an empty set to the `allowing` parameter of `handlesExternalEvents(preferring:allowing:)`.

Specifically, the following will cause a new window to be opened on iPadOS when launching the app from the App Library:

```swift
WindowGroup {
  ContentView()
    .handlesExternalEvents(preferring: [], allowing: [])
}
```

While this ensures the window is foregrounded:

```swift
WindowGroup {
  ContentView()
    .handlesExternalEvents(preferring: [], allowing: ["*"])
}
```

This implies that we're launched with a magic event on iPadOS when the user opens the app from the App Library. This makes some sense, but I can't find any documentation about this anywhere and it's not passed to an `.onOpenURL` modifier. I cannot see if it's passed to `.onContinueUserActivity` as I don't know what the activity type is to test.

Unfortunately, while passing a wildcard to `allowing` ensures our main window is correctly foregrounded, it breaks the behavior where a `WindowGroup` is able to filter based on URL, since the main window is always opened.

Consider this more complete example (closely matching 'Example.xcodeproj'):

```swift
@main
struct ExampleApp: App {
  var body: some Scene {

    WindowGroup(id: "main") {
      ContentView(name: "Main")
        .background(.pink)
        .onOpenURL { url in
          print("Main: \(url)")
        }
        .handlesExternalEvents(preferring: [URL.main.absoluteString], allowing: [])
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

```

This correctly handles `URL.main` (`x-example://main`) and `URL.info`  (`x-example://info`), creating or foregrounding the appropriate `WindowGroup`. However, since neither window allows wildcard events, launching the app from the App Library will always create a new window. If we 'fix' this by adding allowing the wildcard in the main window, info URLs will always be routed to the main window, breaking the model.

## Extra Credit

Interestingly enough, this app also fails to restore the correct window instances. If you open a main window and an info window, it will always restore two main windows on next launch. 🧐


import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    
    @State private var showNigger = false
    
    var body: some View {
        ZStack {
            Color.gray
            VStack {
                Text("Hello, world!")
                Spacer()
                VStack() {
                    Button("Say N Word", role: .destructive) { print("Nigger") }
                    Button("Say R Word", role: .destructive) { print("Retarded") }
                    Toggle("Show Twitter", isOn: $showNigger)
                }
                Spacer()
                if showNigger {
                    Text("**Connect** on [Twitter](https:www.twitter.com)!")
                }
            }
            .frame(width: 320, height: 200)
            .padding()
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())

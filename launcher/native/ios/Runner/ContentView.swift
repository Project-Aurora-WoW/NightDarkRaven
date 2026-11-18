import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 15/255, green: 13/255, blue: 26/255).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Ночь темного Ворона — Лаунчер")
                    .font(.headline)
                    .foregroundColor(Color(red: 167/255, green: 139/255, blue: 250/255))
                    .padding()

                // WebView с локальным лаунчером будет вставлен через UIViewRepresentable
                LauncherWebView()
            }
        }
    }
}

struct LauncherWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "iOSLauncher")
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "www") {
            let url = URL(fileURLWithPath: htmlPath)
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            print("JS message: \(message.body)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
import UIKit
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ContentViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

class ContentViewController: UIViewController, WKScriptMessageHandler {
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 15/255, green: 13/255, blue: 26/255, alpha: 1)

        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "iOSLauncher")

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        // Загружаем локальный HTML-лаунчер из пакета приложения
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html",
                                           inDirectory: "www") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    // JS-интерфейс для вызова из веб-лаунчера
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }

        switch message.name {
        case "iOSLauncher":
            if let action = body["action"] as? String {
                handleAction(action, params: body)
            }
        default:
            break
        }
    }

    private func handleAction(_ action: String, params: [String: Any]) {
        DispatchQueue.main.async {
            switch action {
            case "patchRealmlist":
                if let realm = params["realm"] as? String,
                   let path = params["path"] as? String {
                    self.patchRealmlist(realm: realm, path: path)
                }
            case "launchWow":
                if let path = params["path"] as? String,
                   let realm = params["realm"] as? String {
                    self.launchWow(path: path, realm: realm)
                }
            case "openUrl":
                if let urlString = params["url"] as? String,
                   let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            default:
                break
            }
        }
    }

    private func patchRealmlist(realm: String, path: String) {
        let wtfDir = path.appending("/WTF")
        let fileManager = FileManager.default
        try? fileManager.createDirectory(atPath: wtfDir, withIntermediateDirectories: true)
        let realmFile = wtfDir.appending("/realmlist.wtf")
        try? "set realmlist \(realm)\n".write(toFile: realmFile, atomically: true, encoding: .utf8)
        print("realmlist.wtf обновлён: \(realm)")
    }

    private func launchWow(path: String, realm: String) {
        print("Запуск WoW: \(path), realmlist: \(realm)")
        // На iOS запуск WoW.exe напрямую невозможен без эмулятора Windows
        // Здесь можно открыть App Store или веб-версию
    }
}
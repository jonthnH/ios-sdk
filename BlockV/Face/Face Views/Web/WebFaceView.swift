//
//  BlockV AG. Copyright (c) 2018, all rights reserved.
//
//  Licensed under the BlockV SDK License (the "License"); you may not use this file or
//  the BlockV SDK except in compliance with the License accompanying it. Unless
//  required by applicable law or agreed to in writing, the BlockV SDK distributed under
//  the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
//  ANY KIND, either express or implied. See the License for the specific language
//  governing permissions and limitations under the License.
//

import Foundation
import WebKit

/*
 Goals:
 
 Communication between the Web App and the Web face is bidirectional.
 
 1. Face View > Web App
 - Vatom Update (e.g. off the back of the Web socket).
 - This is the only message that goes in this direction.
 
 2. Web App > Face View
 - The bulk of the communication is initiated by the Web app.
 
 There 2 categories of messages:
 
 2A. Messages intended to be handled by the Face View.
 That is, messages that the face view will need need to respond to by calling into Core. E.g getVatom.
 
 2B. Messages intended to be handled by the Viewer (that are passed via the Face View). That is, messages that
 must be forwarded to the viewer, e.g. Open scanner.
 
 */

/// Web face view.
///
/// Displays webage where the url is specified by the display URL of the face model.
class WebFaceView: FaceView {

    class var displayURL: String { return "https://*" }

    // MARK: - Properties

    private let navigationDelegate: WKNavigationDelegate = WebNavigationDelegate()
    private let uiDelegate: WKUIDelegate = WebUIDelegate()

    /// Web view to display remote face code.
    private lazy var webView: WKWebView = {

        // config
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.dataDetectorTypes = .all
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.allowsAirPlayForMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.userContentController.add(self, name: "vatomicBridge")
        webConfiguration.userContentController.add(self, name: "blockvBridge")

        // content controller
        let webView = WKWebView(frame: self.bounds, configuration: webConfiguration)
        webView.navigationDelegate = navigationDelegate
        webView.uiDelegate = uiDelegate
        webView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        return webView

    }()

    /// Bridge into core
    private var coreBridge: FaceBridge?

    // MARK: - Initialization

    required init(vatom: VatomModel, faceModel: FaceModel, host: VatomView) {
        super.init(vatom: vatom, faceModel: faceModel, host: host)

        self.addSubview(webView)

        //        let url = URL.init(string: "https://www.google.com")!
        let url = URL.init(string: faceModel.properties.displayURL)!
        self.showURL(url)

        self.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        self.webView.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be called on Face Views. Please use VatomView.")
    }

    // MARK: - Face View Life cycle

    var isLoaded: Bool = false

    var timer: Timer?

    func load(completion: ((Error?) -> Void)?) {

        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
            // FIXME: Fire completion once the `init` call has completed.
            completion?(nil)
        })

    }

    func vatomChanged(_ vatom: VatomModel) {
        //
    }

    func unload() {
        self.webView.stopLoading()
    }

    // MARK: - Methods

    func showURL(_ url: URL) {

        let request = URLRequest(url: url)
        self.webView.load(request)

    }

}

// MARK: - Extension WKScriptMessageHandler

extension WebFaceView: WKScriptMessageHandler {

    /// Invoked when a script message is received from a webpage.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        // extract payload
        guard let payload = message.body as? [String: Any] else {
            //FIXME: Post an error invalid_payload
            return
        }
        // create script message
        do {
            let scriptMessage = try FaceScriptMessage(descriptor: payload)
            try routeMessage(scriptMessage)
        } catch {
            //FIXME: Post an error invalid_script_message
        }

    }

    /// Sends a script message to the webpage.
    ///
    ///
    func postMessage(_ name: String, withJSONobject object: [String: Any]? = nil) {

        // create script
        var script = "(window.vatomicEventReceiver || window.blockvEventReceiver).trigger('message', \(name)"
        if let object = object {
            script += ", "
            //FIXME: How to handle encoding failure
            script += ((try? JSONSerialization.string(withJSONObject: object)) ?? "null")
        }
        script += ");"

        printBV(info: script)

        // inject JavaScript into the webpage
        webView.evaluateJavaScript(script) { (_, error) in

            guard error == nil else {
                printBV(error: "WebFaceView: Script failed to be evaluated: \(error!.localizedDescription)")
                return
            }

        }

    }

}

extension WebFaceView {

    /// Routes the message from the webpage to the appropriate face bridge.
    ///
    /// - Parameters:
    ///   - name: Unique identifier of the message.
    ///   - data: Data payload from webpage.
    ///   - completion: Completion handler to call pasing the data to be forwarded to the webpage.
    private func routeMessage(_ message: FaceScriptMessage) throws {

        print(#function)
        print("Message name: \(message.name)")
        print("Object: \(message.object)")

        // create bridge
        switch message.version {
        case "1.0.0": // original Face SDK
            self.coreBridge = CoreBridge_1(faceView: self)
        case "2.0.0":
            self.coreBridge = CoreBridge_2(faceView: self)
        default:
            throw BridgeError.caller("Unsupported Bridge version: \(message.version)")
        }

        /*
         There are 2 classes of messages:
         1. Core messages which relate to API functionality (used only by the Web face)
         2. Viewer messages which request actions from the viewer, e.g.
         Here the message must be routed to the Core Bridge or the Face Bridge.
         */

        // process message

        /*
         Note
         */
        if coreBridge!.canProcessMessage(message.name) {
//            self.coreBridge!.processMessage(message, completion: { (object, error) in
//                print("Object: \(String(describing: object)) | Error: \(String(describing: error))")
//            }
        } else {

        }

    }

}

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

// MARK: - Errors

/// Models the errors which may arise during bridge message communication.
enum BridgeError: Error {
    /// An error casued by an issue on the viewer (native) app side.
    case viewer(_ message: String)
    /// An error caused by an issue on the caller (web face) side.
    case caller(_ message: String)

    /// Returns the error formatted as a dictionary. This dictionary may be serialized into JSON data to be posted
    /// over the web bridge.
    var bridgeFormat: [String: String] {
        switch self {
        case let .viewer(message): return ["errorCode": "viewer_error", "errorMessage": message]
        case let .caller(message): return ["errorCode": "caller_error", "errorMessage": message]
        }
    }
}

/*
 Web Bridge
 
 The web bridge is a layer which manages communication between the native code (viewer and/or SDK) and the webpage
 being rendered by the WebFaceView. This allows the webpage to have context of the current vAtom and allow scoped
 access to functionality on the native side.
 
 Error
 - The errors are communicated using an JSON Object:
 
 {
 "errorCode": "<some_code>",
 "errorMessage": "<some_message>"
 }
 
 Success
 
 ...
 
 */

/// Protocol to which face bridges should conform.
protocol FaceBridge {

//    /// Reference to the face view.
//    var faceView: FaceView? { get set }
//
//    /// Initialize using a face view (typically WebFaceView).
//    init(faceView: FaceView)

    /// Completion type used by by message handlers.
    typealias Completion = (_ object: [String: Any]?, _ error: BridgeError?) -> Void

    /// Processes the message and calls the completion handler once the output is known.
    ///
    /// - Parameters:
    ///   - scriptMessage: The face script message from the webpage.
    ///   - completion: The completion handler that is called once the message has been processed.
    /// - Returns: `true` is the bridge is capable of processing the message. `false` otherwise.
    func processMessage(_ scriptMessage: FaceScriptMessage, completion: Completion)

    /// Returns `true` if the bridge is capable of processing the message and `false` otherwise.
    func canProcessMessage(_ message: String) -> Bool

}

/// Core Bridge Version 1.0.0
class CoreBridge_1: FaceBridge { // swiftlint:disable:this type_name

    /// Reference to the face view which the bridge is interacting with.
    weak var faceView: FaceView?

    required init(faceView: FaceView) {
        self.faceView = faceView
    }

    // MARK: - <#Section#>

    func canProcessMessage(_ message: String) -> Bool {
        return true
    }

    func processMessage(_ scriptMessage: FaceScriptMessage,
                        completion: ([String: Any]?, BridgeError?) -> Void) {
        print(#function)

        // check if can process
//        guard let message = BridgeMessage(rawValue: scriptMessage.name) else {
//            // cannot process
//           
//        }

    }

    // MARK: - Message Handling

    /// Invoked when a face would like to create the web bridge.
    ///
    /// Creates the bridge initializtion JSON object.
    ///
    /// - Parameter completion: Completion handler to call with JSON object to be passed to the webpage.
    private func setupBridge(_ completion: Completion?) {

        var dict: [String: Any] = [:]
        dict["viewMode"] = self.faceView?.faceModel.properties.constraints.viewMode ?? ""

        /*
         FIXME:
         BLOCKv.cachedUser // fetches the cached user (must be set as nil on logout).
         */

        // async fetch current user
        BLOCKv.getCurrentUser { (user, error) in

            // ensure not error
            guard let user = user, error == nil else {
                let error = BridgeError.viewer(error?.localizedDescription ?? "Unable to fetch current user.")
                completion?(nil, error)
                return
            }

            let userDict: [String: Any] = [
                "id": user.id,
                "firstName": user.firstName,
                "lastName": user.lastName,
                "avatarURL": user.avatarURL?.absoluteString ?? "" //FIXME: Encode resource
            ]
            dict["user"] = userDict

            print(#function)
            printBV(info: dict.description)

            // call completion with dictionary
            completion?(dict, nil)

        }

    }

    /*
     This may be legacy and no longer needed.
     */
    /// Returns a dictionary of properties describing the current platform.
    private var viewerInformation: [String: Any] {
        var dict: [String: Any] = [:]
        dict["viewer"] = [
            "name": (Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String) ?? "",
            "id": Bundle.main.bundleIdentifier ?? "",
            "os": [
                "name": UIDevice.current.systemName,
                "version": UIDevice.current.systemVersion
            ]
        ]
        return dict
    }

}

/// Core Bridge (Version 2.0.0)
///
/// Bridges into the Core module.
class CoreBridge_2: FaceBridge { // swiftlint:disable:this type_name

    var faceView: FaceView?

    required init(faceView: FaceView) {
        self.faceView = faceView
    }

    func canProcessMessage(_ message: String) -> Bool {
        return true
    }

    func processMessage(_ scriptMessage: FaceScriptMessage, completion: ([String: Any]?, BridgeError?) -> Void) {
        print(#function)
    }

}

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

// MARK: - Enum

/// Represents the contract for the Web bridge (version 1).
enum BridgeMessageV1: String {

    case initialize         = "vatom.init"
    case getVatomChildren   = "vatom.children.get"
    case performAction      = "vatom.performAction"
    case getUserProfile     = "user.profile.fetch"
    case getUserAvatar      = "user.avatar.fetch"
    case getVatom           = "vatom.get"

    /// Unique identifier of the response message.
    var responseMessageID: String {
        switch self {
        case .initialize:       return "vatom.init-complete"
        case .getVatomChildren: return "vatom.children.get-response"
        case .performAction:    return ""
        case .getUserProfile:   return ""
        case .getUserAvatar:    return ""
        case .getVatom:         return ""
        }
    }

}

/// Represents the contract for the Web bridge (version 2).
enum BridgeMessageV2: String {
    case initialize         = "init"
    case getVatomChildren   = "vatom.children.get"
    case performAction      = "vatom.performAction"
    case getUserProfile     = "user.profile.fetch"
    case getVatom           = "vatom.get"
}

/// Class responsible for routing the bridge messages to the appropriate bridge verion.
///
/// - Route to the appropriate brige
/// - Route to the corresponding function
//class CoreBridgeRouter {
//
//    // MARK: - Properties
//
//    private var coreBridge: CoreBridgeRouter?
//    
//    // MARK: - Init
//
//    // MARK: - Methods
//
//    /// Routes the message from the webpage to the appropriate face bridge.
//    ///
//    /// - Parameters:
//    ///   - name: Unique identifier of the message.
//    ///   - data: Data payload from webpage.
//    ///   - completion: Completion handler to call pasing the data to be forwarded to the webpage.
//    func routeMessage(_ message: FaceScriptMessage) -> Bool {
//
//        print(#function)
//        print("Message name: \(message.name)")
//        print("Object: \(message.object)")
//
//        // create bridge
//        switch message.version {
//        case "1.0.0": // original Face SDK
//            self.coreBridge = CoreBridge_1(faceView: self)
//        case "2.0.0":
//            self.coreBridge = CoreBridge_2(faceView: self)
//            print("TODO")
//        default:
//            //FIXME: How to handle this? Error out or use latest SDK version
//            assertionFailure("Unsupported Bridge version: (message.version)")
//            return
//        }
//
//        /*
//         There are 2 classes of messages:
//         1. Core messages which relate to API functionality (used only by the Web face)
//         2. Viewer messages which request actions from the viewer, e.g.
//         Here the message must be routed to the Core Bridge or the Face Bridge.
//         */
//
//        // process message
//        if !self.faceBridge!.processMessage(message, completion: { (object, error) in
//            print("Object: \(String(describing: object)) | Error: \(String(describing: error))")
//        }) {
//            // forward on to viewer
//        }
//
//    }
//
//
//
//}

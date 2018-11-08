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

struct FaceScriptMessage {
    /// Unique identifier of the incomming message.
    let name: String
    /// Unique indentifier for the outgoing response.
    let responseID: String
    /// Origin of the message.
    let source: String
    /// Interface version being requested from the FaceSDK.
    ///
    /// If a "version" key is not present in the message it will default to 1.0.0. This fallback is the intendend to be
    /// used by first Face SDK only – all newer version MUST supply a version key-pair.
    let version: String
    /// Object containg data from the FaceSDK.
    let object: [String: Any]

    /// Initializes using parameters.
    init(source: String, name: String, responseID: String?, version: String?, object: [String: Any]?) {
        self.source = source
        self.name = name
        self.responseID = responseID ?? ""
        self.version = version ?? "1.0.0" // default specifies the version used by the original Face SDK.
        self.object = object ?? [:]
    }

    /// Initializes using a JSON object.
    init(descriptor: [String: Any]) throws {
        // extract source
        guard let source = descriptor["source"] as? String, source == "Vatom" else {
            throw FaceScriptError.invalidSource
        }
        // extract name
        guard let name = descriptor["name"] as? String else {
            throw FaceScriptError.invalidName
        }
        // extract info
        let version = descriptor["version"] as? String
        let responseID = descriptor["responseID"] as? String ?? ""
        let object = descriptor["data"] as? [String: Any]

        self.init(source: source, name: name, responseID: responseID, version: version, object: object)
    }

    enum FaceScriptError: Error {
        case invalidName
        case invalidSource
        case invalidVersion
    }
}

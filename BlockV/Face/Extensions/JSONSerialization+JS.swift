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

extension JSONSerialization {

    /// Models the errors that may occur when coverting data into an encoded string.
    enum JSONSerializationStringConversion: Error {
        case failed
    }

    /// Returns a JSON string.
    static func string(withJSONObject obj: [String: Any], encoding: String.Encoding = .utf8) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: obj, options: [])
        guard let jsonString = String(data: data, encoding: encoding) else {
            throw JSONSerializationStringConversion.failed
        }
        return jsonString
    }

}

extension JSONSerialization {

    /*
     NOTE:
     I am not sure if this is needed anymore. AFAIK the native app will never pass anything but a JSON object over the
     bridge to the webpage. This means no hacks for top-level primatives are needed.
     */

    /// Returns JavaScript compatible JSON string from a Foundation object.
    ///
    /// This function allows JavaScript encoding of top-level primatives. It does this by converting top-level
    /// primatives into JavaScript compatible string (which JSONSerialization does not handle).
    static func javascriptString(withJSONObject obj: Any?) throws -> String {

        guard let obj = obj else {
            // return null
            return "null"
        }

        if let data = obj as? String {
            // escape the string
            return "\"" + data
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\r", with: "\\r")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\"", with: "\\\"")
                + "\""

        } else if let data = obj as? Int {
            // encoded directly
            return String(data)

        } else if let data = obj as? Double {
            // encoded directly
            return String(data)

        } else if let data = obj as? Bool {
            // encode using true and false
            return data ? "true" : "false"

        } else {
            // use standard JSONSerialization data conversion
            guard let data = try? JSONSerialization.data(withJSONObject: obj, options: []) else {
                throw JSONSerializationStringConversion.failed
            }
            return String(data: data, encoding: .utf8)!

        }

    }

}

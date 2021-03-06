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

/// Full token response model.
public struct FullTokenModel: Codable, Equatable {

    public let id: String
    public let meta: MetaModel
    public let properties: Properties

    public struct Properties: Codable, Equatable {
        public let appID: String
        public let isConfirmed: Bool
        public let isDefault: Bool
        public let token: String
        public let tokenType: String
        public let userID: String
        public let verifyCodeExpires: Date

        enum CodingKeys: String, CodingKey {
            case appID             = "app_id"
            case isConfirmed       = "confirmed"
            case isDefault         = "is_default"
            case token             = "token"
            case tokenType         = "token_type"
            case userID            = "user_id"
            case verifyCodeExpires = "verify_code_expires"
        }
    }

}

//
//  BlockvAPI.swift
//  API
//
//  Created by Cameron McOnie on 2018/02/19.
//

import Foundation
import Alamofire

/// Consolidates all BlockV API endpoints.
///
/// Endpoints are namespaced to furture proof.
///
/// Endpoints closely match their server counterparts where possible.
/// If appropriate, some endpoints may represent a single server endpoint.
///
/// The goal is to abstract endpoint specific details. The networking client should
/// not need to taylor requests for the specific of an endpoint.
enum API { }

extension API {
    
    /*
     All Session, Current User, and Public User endpoints are wrapped in a (unnecessary)
     container object. This is modelled here using a `BaseModel`.
     */
    
    /// Consolidates all session related endpoints.
    enum Session {
        
        // MARK: Register
        
        private static let registerPath = "/v1/users"
        
        /// Returns the endpoint for new user registration.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func register(tokens: [RegisterTokenParams], userInfo: UserInfo? = nil) -> Endpoint<BaseModel<AuthModel>> {
            
            precondition(!tokens.isEmpty, "One or more tokens must be supplied for this endpoint.")
            
            // dictionary of user information
            var params = [String : Any]()
            if let userInfo = userInfo {
                params = userInfo.toDictionary()
            }
            
            // create an array of tokens in their dictionary representation
            let tokens = tokens.map { $0.toDictionary() }
            params["user_tokens"] = tokens
            
            return Endpoint(method: .post,
                            path: registerPath,
                            parameters: params)
            
        }
        
        // MARK: Login
        
        private static let loginPath = "/v1/user/login"
        
        /// Returns endpoint for user login.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func login(tokenParams: LoginTokenParams) -> Endpoint<BaseModel<AuthModel>> {
            return Endpoint(method: .post,
                            path: loginPath,
                            parameters: tokenParams.toDictionary())
        }
        
    }
    
    /// Consolidates all current user endpoints.
    enum CurrentUser {
        
        private static let currentUserPath = "/v1/user"
        
        /// Returns the endpoint to get the current user's properties.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func get() -> Endpoint<BaseModel<UserModel>> {
            return Endpoint(path: currentUserPath)
        }
        
        /// Endpoint to get the current user's tokens.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func getTokens() -> Endpoint<BaseModel<[FullTokenModel]>> {
            return Endpoint(path: currentUserPath + "/tokens")
        }
        
        /// Endpoint to log out the current user.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func logOut() -> Endpoint<BaseModel<GeneralModel>> {
            return Endpoint(method: .post, path: currentUserPath + "/logout")
        }
        
        /// Endpoint to update current user's information.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func update(userInfo: UserInfo) -> Endpoint<BaseModel<UserModel>> {
            return Endpoint(method: .patch,
                            path: currentUserPath,
                            parameters: userInfo.toSafeDictionary()
            )
        }
        
        /// Endpoint to verify a token with an OTP code.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func verifyToken(_ token: UserToken, code: String) -> Endpoint<BaseModel<UserToken>> {
            return Endpoint(method: .post,
                            path: currentUserPath + "/verify_token",
                            parameters: [
                                "token": token.value,
                                "token_type": token.type.rawValue,
                                "verify_code": code
                ]
            )
        }
        
        /// Endpoint to reset a user token.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func resetToken(_ token: UserToken) -> Endpoint<BaseModel<UserToken>> {
            return Endpoint(method: .post,
                            path: currentUserPath + "/reset_token",
                            parameters: token.toDictionary()
            )
        }
        
        /// Endpoint to send a verification request for a specific token.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func resetTokenVerification(forToken token: UserToken) -> Endpoint<BaseModel<UserToken>> {
            return Endpoint(method: .post,
                            path: currentUserPath + "/reset_token_verification",
                            parameters: token.toDictionary()
            )
        }
        
        /* POST Beta 0.5
         
         /// Endpoint to add a token to the current user.
         public static func addToken(_ token: UserToken, isPrimary: Bool) -> Endpoint<Void> {
         return Endpoint(method: .post,
         path: currentUserPath + "/user/tokens",
         parameters: [
         "token": token.value,
         "token_type": token.type.rawValue,
         "is_primary": isPrimary
         ]
         )
         }
         
         /// Endpoint to delete a token.
         public static func deleteToken(id: String) -> Endpoint<Void> {
         return Endpoint(method: .delete,
         path: currentUserPath + "/tokens/\(id)")
         }
         
         /// Endpoint to set a default token.
         public static func setDefaultToken(id: String) -> Endpoint<Void> {
         return Endpoint(method: .put,
         path: currentUserPath + "/tokens/\(id)/default")
         }
         
         /// Endpoint to fetch redeemables.
         public static func getRedeemables() -> Endpoint<Void> {
         return Endpoint(path: currentUserPath + "/redeemables")
         }
         */
        
        /// Upload endpoint for the user's avatar.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func uploadAvatar(_ imageData: Data) -> UploadEndpoint<BaseModel<GeneralModel>> {
            
            let bodyPart = MultiformBodyPart(data: imageData, name: "avatar", fileName: "avatar.png", mimeType: "image/png")
            return UploadEndpoint(path: "/v1/user/avatar",
                                  bodyPart: bodyPart)
            
        }
        
    }
    
    /// Consolidates all public user endpoints.
    enum PublicUser {
        
        /// Endpoint to get a public user's details.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func get(id: String) -> Endpoint<BaseModel<PublicUserModel>> {
            return Endpoint(path: "/v1/users/\(id)")
        }
        
    }
    
    /// Consolidates all user vatom endpoints.
    enum UserVatom {
        
        private static let userVatomPath = "/v1/user/vatom"
        
        //TODO: Parameterise parameters.
        
        /// Returns the endpoint to get the current user's inventory.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func getInventory(parentID: String = "*",
                                 page: Int = 0,
                                 limit: Int = 0) -> Endpoint<BaseModel<GroupModel>> {
            return Endpoint(method: .post,
                            path: userVatomPath + "/inventory",
                            parameters: [
                                "parent_id": ".",
                                "page": page,
                                "limit": limit
                ]
            )
        }
        
        /// Returns the endpoint to get a vAtom by its unique identifier.
        ///
        /// The endpoint is generic over a response model. This model is parsed on success responses (200...299).
        static func getVatoms(withIDs ids: [String]) -> Endpoint<BaseModel<GroupModel>> {
            return Endpoint(method: .post,
                            path: userVatomPath + "/get",
                            parameters: ["ids": ids]
            )
        }
        
    }
    
    enum Discover {
        
        // This needs a discover builder or something rather?
        
        // Filter field (if it is there) will mess things up. How to decode a limited payload?
        
        /// Returns the endpoint to search for vatoms using a discover query.
        ///
        ///
        static func discover() -> Endpoint<BaseModel<GroupModel>> {
            
            return Endpoint(method: .post,
                            path: "/v1/vatom/discover",
                            parameters: [
                                "":""
                ]
            )
        }
        
    }
    
    //    enum Action {
    //
    //        private static let actionPath = "/v1/user/vatom/action/"
    //
    //        static func perform(name: Stirng) -> Endpoint
    //
    //    }
    
}



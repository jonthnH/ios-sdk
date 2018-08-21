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

// MARK: - Typealias

/// A Face Selection Procedure (FSP) is an algorithm used to select the best face model from the (potentially) many
/// faces associated with the vatom's template. It is an algorithm that assists a vAtom in selecting the best face for
/// a specific visual context.
///
/// An FSP gives the Viewer optional control over the face selection procedure.
///
/// Closure inputs:
/// - vAtom to be displayed.
/// - Actions associated with the vAtom's template.
/// - Faces associated with the vAtom's template.
/// - Installed display URLs. This is the set of native face display URLs (i.e. unique identifiers of the installed
///   native faces).
///
/// Closure ouput:
/// - Optional face model. The closure should return the 'best' face given the inputs, or `nil` if no face is selected.
///
/// - Parameters:
///   - vatomPack: vAtom pack from which the best face should be selected.
///   - displayURLs: Set of displayURLs of the installed native faces.
public typealias FaceSelectionProcedure = (_ vatomPack: VatomPackModel, _ displayURLs: Set<String>)
    -> FaceModel?

/// Models the embedded face selection procedures (FSP)s. This is a set of pre-built face selection procedures defined
/// by the SDK to meet common use cases.
///
/// It important to think of the cases simply as unique identifiers of stored face selection procedures. Cases loosely
/// map to the server's 'view_mode' simply because the 'view_mode' is generally the predominant selection criteria.
public enum EmbeddedProcedure: String {

    /// Selects based on 'icon' view mode.
    case icon
    /// Selects based on 'activated' view mode.
    case activated
    /// Selects based on 'fullscreen' view mode.
    case fullscreen
    /// Selects based on 'card' view mode.
    case card

    //TODO: The generic viewer will likely specify it's own stored procedures. This means the whole fallback concept
    // should be removed. Rather, the generic viewer should specify its own procedures with its own fallbacks since this
    // is not something the SDK should be offering as a 'common' solution.

    /// A fallback allows one procedure to fallback on antoher in the event the first procedure fails to select a
    /// face model.
    var fallback: EmbeddedProcedure? {
        switch self {
        case .icon:         return nil
        case .activated:    return .icon
        case .fullscreen:   return .icon
        case .card:         return .icon
        }
    }

    /// Returns the face selection procedure.
    var selectionProcedure: FaceSelectionProcedure {
        switch self {
        case .icon:         return EmbeddedProcedureBuilder.iconProcedure
        case .activated:    return EmbeddedProcedureBuilder.activatedProcedure
        case .fullscreen:   return EmbeddedProcedureBuilder.fullscreenProcedure
        case .card:         return EmbeddedProcedureBuilder.cardProcedure
        }
    }

    // MARK: - Face selection

    /// Selects the 'best' face using this procedure's stored Face Selection Procedure (FSP).
    ///
    /// - Parameters:
    ///   - vatomPack: vAtom pack from which the best face should be selected.
    ///   - displayURLs: Set of display URLs of the installed native faces.
    ///   - useFallback: Determines whether the fallback procedure should be used. If `true` the fallback is used,
    ///   `false` otherwise.
    /// - Returns: The selected face model, or `nil` if no face model is selected.
    func selectBestFace(vatomPack: VatomPackModel, displayURLs: Set<String>, useFallback: Bool = true)
        -> FaceModel? {
        // execute this procedure, use fallback if necessary
        return self.selectionProcedure(vatomPack, displayURLs) ??
            self.fallback?.selectionProcedure(vatomPack, displayURLs)
    }

    // MARK: Constraints

    /// Constraints associated with this embedded procedure.
    var constraints: SelectionConstraints {
        return SelectionConstraints(viewMode: self.rawValue)
    }

    /// Constraints used as the selection criteria when choosing the best face for this procedure.
    struct SelectionConstraints {
        /// The view_mode of the face.
        let viewMode: String
        // let quality: String // e.g. of futher constraints
    }

}

///
private struct EmbeddedProcedureBuilder {

    // MARK: - Stored Face Selection Procedure (FSP)

    static let iconProcedure: FaceSelectionProcedure = { (vatomPack, displayURLs) in
        EmbeddedProcedureBuilder.defaultSelectionProcedure(vatomPack.faces, displayURLs,
                                                         EmbeddedProcedure.icon.constraints)
    }

    static let activatedProcedure: FaceSelectionProcedure = { (vatomPack, displayURLs)  in
        EmbeddedProcedureBuilder.defaultSelectionProcedure(vatomPack.faces, displayURLs,
                                                         EmbeddedProcedure.activated.constraints)
    }

    static let fullscreenProcedure: FaceSelectionProcedure = { (vatomPack, displayURLs)  in
        EmbeddedProcedureBuilder.defaultSelectionProcedure(vatomPack.faces, displayURLs,
                                                         EmbeddedProcedure.fullscreen.constraints)
    }

    static let cardProcedure: FaceSelectionProcedure = { (vatomPack, displayURLs)  in
        EmbeddedProcedureBuilder.defaultSelectionProcedure(vatomPack.faces, displayURLs,
                                                         EmbeddedProcedure.card.constraints)
    }

    // MARK: - Stored Procedure

    /// Embedded procedures take in only face models, display urls, and a set of constraints (as this is all they need).
    ///
    /// - Parameters:
    ///   - faceModels: Array of face models to be used by the selection procedure.
    ///   - displayURLs: Set of display URLs of the installed native faces.
    ///   - constraints: Struct holding face contraints to be used by the selection procedure.
    typealias EmbeddedFaceSelectionProcedure = (_ faceModels: [FaceModel],
        _ displayURLs: Set<String>,
        _ constraints: EmbeddedProcedure.SelectionConstraints)
        -> FaceModel?

    /// Default selection procedure.
    ///
    ///
    /// This closure defines a procedure that is common to most embedded FSPs. The logic is therefor consoldated here.
    static let defaultSelectionProcedure: EmbeddedFaceSelectionProcedure = { (faceModels, displayURLs, constraints) in

        var bestFace: FaceModel?
        var bestRank = -1

        for face in faceModels {
            
            /*
             The question here is:
             - Does this face meet the requirements of the FSP, if so how does it compare to it's peers.
             */

            var rank = 0

            // ensure 'view mode' is supported
            if face.properties.constraints.viewMode != constraints.viewMode {
                continue
            }

            // rank 'ios' faces over 'generic'
            if face.properties.constraints.platform == "ios" {
                rank += 2
            } else if face.properties.constraints.platform == "generic" {
                rank += 1
            } else {
                continue
            }

            // rank 'native' over 'web'
            if face.isNative {
                // enusrue the native face is supported (i.e. the face code is installed)
                if displayURLs.contains(where: { $0.caseInsensitiveCompare("") != .orderedSame }) { //FIXME: Add face display url
                    continue
                }
                rank += 1
            }

            // compare to best rank
            if rank > bestRank {
                bestRank = rank // update rank
                bestFace = face // update best face
            }

        }

        return bestFace

    }

}
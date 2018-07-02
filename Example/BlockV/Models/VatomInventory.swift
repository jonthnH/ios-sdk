//
//  VatomInventory.swift
//  BlockV_Example
//
//  Created by Cameron McOnie on 2018/07/01.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import BLOCKv

/*
 
 Design:
 - How to show vAtom addition/removal.
 - How to indicate vAtom state update (if visual/pretinent).
 - Allow sort by order of received (moving the vAtom last modified to the top is silly).
 -
 
 Engineering:
 
 Challenges
 - How to deal with a large remote inventory - say 1000 vAtoms? Impractical to store all locally.
 -
 
 Goals
 - Local inventory: Local store of vAtoms (representing the user's inventory).
 - Dynamic updates:  Respond to inventory changes (addition & deletion).
 - Filters: Allow consumer to pass in an array of filters to apply.
 - Pagination: Caller must be able to paginate the inventory.
 - Local search: Search/filter vAtoms within the local inventory.
 
 Nice to have
 - Remote search: Consumer may wish to search for vAtoms beyond what is available locally.
 - vAtom offload: vAtoms that have not been accessed in a while should have their resources purged.
 
 Non-goals
 -
 
 Backend requirements:
 - Inventory count: Total size of the inventory.
 - Date recevived: Time stamp of when a user received a vAtom - this will allow the inventory to be sorted.
 
 */

/// This model class is responsible for manging a vAtom Inventory.
///
/// Features:
/// 1. Respondes to the update stream (so you don't have to).
/// 2. Designed to allow paging. (does it make sense to have it also handle discover queries)? Maybe that's a feature of the higher-level VatomStore?
///
/// Broadcasts when a vAtom is added, removed, or update. How? Observer pattern? Single-shot delegate?
///
class VatomInventory {
    
    // MARK: - Properties
    
    typealias VatomFilter = (VatomModel) -> Bool
    
    /// Array of filters to apply to the before populating the `filteredVatoms` array.
    ///
    /// Allow the caller to
    var filters: [VatomFilter] = []
    
    /// TEMP - I'm not sure if this is the best notificaton strategy.
    var onUpdate: (() -> Void)?
    
    /// Unique identifier of the parent vAtom. Defaults to "." (i.e. the root inventory).
    private var parentID: String
    
    // MARK: Paging
    
    private var pageSize: Int = 20
    private var pageIndex: Int = 0
    private var
    
    /// Model holding the inventory vatoms.
    fileprivate var vatoms: [VatomModel] = [] {
        didSet {
            filteredVatoms = vatoms.filter {
                
                //TODO: Run over the `filters` array...
                (!$0.isDropped) && ($0.templateID != "vatomic::v1::vAtom::CoinWallet")
            }
        }
    }
    
    /// Model holding the filtered vAtoms.
    ///
    /// Typically, only filtered vAtoms are visually presented to the user.
    fileprivate var filteredVatoms: [VatomModel] = [] {
        didSet {
            // notify listeners of update...
            self.onUpdate?() // maybe pass through the diff (old vs new value)?
        }
    }
    
    // MARK: - Initializer
    
    init(parentID: String = ".") {
        
        self.parentID = parentID
        
        // filter out dropped vAtoms & coin wallet
        let filters: [VatomFilter] = [{!$0.isDropped}, {$0.templateID != "vatomic::v1::vAtom::CoinWallet"}]
        self.filters.append(contentsOf: filters)
    }
    
    // MARK: - Paging
    
    /*
     What should be returned here? PackModel of just an array of vAtoms?
     
     This raises the larger question of where/when to process the package (vatoms, faces, actions)?
     
     The Inventory Grid should not be handling an array of vatoms, that is, calling out to fetch vatoms should
     not return the vatoms. Rather, internally the vAtoms should be updated. But the how do I notify the Inventory
     Grid?
    */
    
    func fetchVatoms(page: Int, pageSize: Int, completion: @escaping (BVError?) -> Void) {
        
        BLOCKv.getInventory(parentID: parentID, page: page, limit: pageSize) { (packModel, error) in
            
            guard let pack = packModel, error == nil else {
                completion(error)
                return
            }
            
            self.vatoms = pack.vatoms //FIXME: This is a overwite operation
            
            // inform
            completion(nil)
            
        }
        
    }
    
}

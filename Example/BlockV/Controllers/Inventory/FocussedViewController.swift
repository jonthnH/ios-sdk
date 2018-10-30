//
//  FocussedViewController.swift
//  BlockV_Example
//
//  Created by Cameron McOnie on 2018/10/30.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import BLOCKv

class FocussedViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Backing vAtom for display.
    var vatom: VatomModel?
    
    @IBOutlet weak var vatomView: LiveVatomView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         This has some interesting challenges. The two VatomViews need to be synchornised. That is, the VatomView in the inventory and this VatomView must display some continuity. If the VVLC is triggered, there will be a loss in continuity since the face may need to fetch remote data before it's visual state will reflect the latest vatom state.
         */

        // Do any additional setup after loading the view.
        if let vatom = self.vatom {
        vatomView.update(usingVatom: vatom, procedure: EmbeddedProcedure.engaged.procedure)
        } else {
            // show error view
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

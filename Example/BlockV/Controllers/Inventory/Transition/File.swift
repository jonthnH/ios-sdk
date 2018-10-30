////
////  File.swift
////  BlockV_Example
////
////  Created by Cameron McOnie on 2018/10/29.
////  Copyright © 2018 CocoaPods. All rights reserved.
////
///
// http://zappdesigntemplates.com/uiviewcontroller-transition-from-uicollectionviewcell/
//
//import UIKit
//
///// Object that vends the animation controllers.
//class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
//
//    // This is the new view controller's starting frame (this was invented by this tutorial dude).
//    var openingFrame: CGRect?
//
//    // Vends the aimation controller for the presentation
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let presentationAnimator = PresentationAnimator()
//        presentationAnimator.openingFrame = openingFrame
//        return presentationAnimator
//    }
//
//    // Vend the animation controller for the dismissal
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let dismissAnimator = DisimissalAnimator()
//        dismissAnimator.openingFrame = openingFrame
//        return dismissAnimator
//    }
//
//}
//
//
//class PresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//
//    var openingFrame: CGRect?
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.5
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//
//        // usefull props
//        let fromViewController = transitionContext.viewController(forKey: .from)
//        let toViewController = transitionContext.viewController(forKey: .to)
//        let containerView = transitionContext.containerView
//
//        let animationDuration = self.transitionDuration(using: transitionContext)
//
//
//
//    }
//
//}
//
//class DisimissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//
//    var openingFrame: CGRect?
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        0.3
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        <#code#>
//    }
//
//}

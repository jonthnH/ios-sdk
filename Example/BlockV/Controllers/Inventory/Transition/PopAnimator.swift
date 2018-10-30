
// https://www.raywenderlich.com/359-ios-animation-tutorial-custom-view-controller-presentation-transitions

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    
    let duration = 1.0
    var presenting = true
    var originFrame = CGRect.zero
    
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    /*
     Transitioning view controllers is essentially about transitioning between the root view's of the view controller.
     */
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        /*
         Transition context:
         - Adds the 'from' view
         - Init's the 'to' view but makes alpha 0
         
         My Goals:
         - Add the 'to' view to the transition container
         - Animate in its apperance
         - Animate out the 'from' view (if no longer required)
         */
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        /*
         Simple animation
         */
        
//        containerView.addSubview(toView)
//        toView.alpha = 0
//        UIView.animate(withDuration: duration, animations: {
//            toView.alpha = 1
//        }) { _ in
//            transitionContext.completeTransition(true)
//        }
        
        
        // During presentation this is the 'to' view
        // During dismissal this is the 'from' view
        let animatingView = presenting ? toView : fromView
        
        let initialFrame = presenting ? originFrame : animatingView.frame
        let finalFrame = presenting ? animatingView.frame : originFrame
        
        // calculate the scale factor to apply to each axis
        let xScaleFactor = presenting ?
        
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
        
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            animatingView.transform = scaleTransform
            animatingView.center = CGPoint(x: initialFrame.midX, y: initialFrame.minY)
            animatingView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: animatingView)
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.0,
                       animations: {
                        animatingView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
                        animatingView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { _ in
            transitionContext.completeTransition(true)
        }
        
    }
    
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containerView = transitionContext.containerView
//        let toView = transitionContext.view(forKey: .to)!
//        let herbView = presenting ? toView : transitionContext.view(forKey: .from)!
//
//        let initialFrame = presenting ? originFrame : herbView.frame
//        let finalFrame = presenting ? herbView.frame : originFrame
//
//        let xScaleFactor = presenting ?
//            initialFrame.width / finalFrame.width :
//            finalFrame.width / initialFrame.width
//
//        let yScaleFactor = presenting ?
//            initialFrame.height / finalFrame.height :
//            finalFrame.height / initialFrame.height
//
//        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
//
//        if presenting {
//            herbView.transform = scaleTransform
//            herbView.center = CGPoint(
//                x: initialFrame.midX,
//                y: initialFrame.midY)
//            herbView.clipsToBounds = true
//        }
//
//        containerView.addSubview(toView)
//        containerView.bringSubview(toFront: herbView)
//
//        UIView.animate(withDuration: duration, delay:0.0,
//                       usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0,
//                       animations: {
//                        herbView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
//                        herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
//        }, completion: { _ in
//            if !self.presenting {
//                self.dismissCompletion?()
//            }
//            transitionContext.completeTransition(true)
//        })
//    }
}

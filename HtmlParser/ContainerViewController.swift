//
//  ContainerViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
//    case RightPanelExpanded
}

class ContainerViewController: UIViewController, CenterViewControllerDelegate, UIGestureRecognizerDelegate {
    var centerNavigationController: UINavigationController!
    var centerViewController: ListMovieController!
    
    var currentState: SlideOutState = .BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .BothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    var leftViewController: SidePanelViewController?
//    var rightViewController : SidePanelViewController?
    
    let centerPanelExpandedOffset: CGFloat = 60
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
//        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: CenterViewController delegate methods
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func toggleRightPanel() {
//        let notAlreadyExpanded = (currentState != .RightPanelExpanded)
//        if notAlreadyExpanded {
//            addLeftPanelViewController()
//        }
//        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }

    func animateRightPanel(#shouldExpand: Bool) {
//        if shouldExpand {
//            currentState = .RightPanelExpanded
//            animateCenterPanelXPosition(targetPosition: centerPanelExpandedOffset - CGRectGetWidth(centerNavigationController.view.frame))
//        } else {
            animateCenterPanelXPosition(targetPosition: 0, completion: {finished in
                self.currentState = .BothCollapsed
//                self.rightViewController!.view.removeFromSuperview()
//                self.rightViewController = nil
            })
//        }
    }

    func collapseSidePanels() {
        switch (currentState) {
        case .LeftPanelExpanded:
            toggleLeftPanel()
//        case .RightPanelExpanded:
//            toggleRightPanel()
        default:
            break
        }
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
//            leftViewController = SidePanelViewController(nibName: "SidePanelViewController", bundle: nil)
            
           leftViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SidePanelViewController") as? SidePanelViewController

       //     leftViewController!.animals = Animal.allCats()
            
            addChildSidePanelController(leftViewController!)
        }
    }
    
    
    func addChildSidePanelController(sidePanelController: SidePanelViewController) {
        sidePanelController.delegate = centerViewController
        
        view.insertSubview(sidePanelController.view, atIndex: 0)
        view.addConstraint(NSLayoutConstraint(
            item: sidePanelController.view,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 0)
            )
        
        view.addConstraint(NSLayoutConstraint(
            item: sidePanelController.view,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: sidePanelController.view,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        )
        
        sidePanelController.view.addConstraint(NSLayoutConstraint(
            item: sidePanelController.view,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: 250)
        )
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func animateLeftPanel(#shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: 250)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .BothCollapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func addRightPanelViewController() {
//        if (rightViewController == nil) {
            leftViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SidePanelViewController") as? SidePanelViewController

//            addChildSidePanelController(rightViewController!)
//        }
    }
    



    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    // MARK: Gesture recognizer
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        // we can determine whether the user is revealing the left or right
        // panel by looking at the velocity of the gesture
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        if (!gestureIsDraggingFromLeftToRight && currentState == .BothCollapsed) {
            return
        }
        switch(recognizer.state) {
        case .Began:
            if (currentState == .BothCollapsed) {
                // If the user starts panning, and neither panel is visible
                // then show the correct panel based on the pan direction
                
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                }
//                else if (currentState == .LeftPanelExpanded) {
//                    addRightPanelViewController()
//                }
                
                showShadowForCenterViewController(true)
            }
        case .Changed:
            // If the user is already panning, translate the center view controller's
            // view by the amount that the user has panned
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            // When the pan ends, check whether the left or right view controller is visible
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
//             else if (rightViewController != nil) {
//                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
//                animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
//            }
        default:
            break
        }
    }
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    class func centerViewController() -> ListMovieController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ListMovieController") as? ListMovieController
    }
    
//    class func rightViewController() -> SidePanelViewController? {
//        return mainStoryboard().instantiateViewControllerWithIdentifier("ListMovieController") as? SidePanelViewController
//        
//    }
}
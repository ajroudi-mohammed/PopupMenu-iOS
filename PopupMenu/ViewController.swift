//
//  ViewController.swift
//  PopupMenu
//
//  Created by Ajroudi Mohammed on 09/09/2019.
//  Copyright © 2019 Ajroudi Mohammed. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class ViewController: UIViewController {
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        layout();
        
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    private var bottomConstraint = NSLayoutConstraint()

    private func layout(){
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 400)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 500).isActive = true
    }
    

    private var currentState: State = .closed
    
    private var transitionAnimator : UIViewPropertyAnimator! = nil
    
    private var animationProgress: CGFloat = 0
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer){
        switch recognizer.state {
            case .began:
                
                if transitionAnimator == nil {
                    let state = currentState.opposite
                    transitionAnimator = UIViewPropertyAnimator(duration: 3, dampingRatio: 1, animations: {
                        switch state {
                            case .open:
                                self.bottomConstraint.constant = 0
                            case .closed:
                                self.bottomConstraint.constant = 400
                        }
                        self.view.layoutIfNeeded()
                    })
                    transitionAnimator.addCompletion { position in
                        
                        switch position {
                            case .start:
                                self.currentState = state.opposite
                            case .end:
                                self.currentState = state
                            case .current:
                                ()
                        }
                        
                        switch self.currentState {
                            case .open:
                                self.bottomConstraint.constant = 0
                            case .closed:
                                self.bottomConstraint.constant = 400
                        }
                        
                        self.transitionAnimator = nil
                        
                    }
                    transitionAnimator.startAnimation()
                }
                transitionAnimator.pauseAnimation()
                animationProgress = transitionAnimator.fractionComplete
            
            case .changed:
                 
                let translation = recognizer.translation(in: popupView)
                var fraction = -translation.y / 400
                
                if currentState == .open { fraction *= -1 }
                if transitionAnimator.isReversed { fraction *= -1 }
                
                transitionAnimator.fractionComplete = fraction + animationProgress
            
            
            case .ended:
                
                let yVelocity = recognizer.velocity(in: popupView).y
                let shouldClose = yVelocity > 0
                
                if yVelocity == 0 {
                    transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    break
                }
                
                switch currentState {
                    
                    case .open:
                        
                        if !shouldClose && !transitionAnimator.isReversed {
                            transitionAnimator.isReversed = !transitionAnimator.isReversed
                        }
                        if shouldClose && transitionAnimator.isReversed {
                            transitionAnimator.isReversed = !transitionAnimator.isReversed
                        }
                    
                    case .closed:
                        
                        if shouldClose && !transitionAnimator.isReversed {
                            transitionAnimator.isReversed = !transitionAnimator.isReversed
                        }
                        if !shouldClose && transitionAnimator.isReversed {
                            transitionAnimator.isReversed = !transitionAnimator.isReversed
                        }
                }
                
                transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            default:
                ()
        }
    }
    

}

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizerState.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizerState.began
    }
    
}


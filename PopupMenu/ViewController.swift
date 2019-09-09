//
//  ViewController.swift
//  PopupMenu
//
//  Created by Ajroudi Mohammed on 09/09/2019.
//  Copyright © 2019 Ajroudi Mohammed. All rights reserved.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        layout();
        popupView.addGestureRecognizer(tapRecognizer)
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    private var bottomConstraint = NSLayoutConstraint()

    private func layout(){
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 440)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 500).isActive = true
    }
    
    private lazy var tapRecognizer : UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewTapped(recognizer:)))
        return recognizer
    }()
    
    private lazy var panRecognizer : UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()

    private var currentState: State = .closed
    
    private var transitionAnimator : UIViewPropertyAnimator! = nil
    
    @objc private func popupViewTapped(recognizer: UITapGestureRecognizer){
        let state = currentState.opposite
        transitionAnimator = UIViewPropertyAnimator(duration: 3, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = 440
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
                self.bottomConstraint.constant = 440
            }
        }
        transitionAnimator.startAnimation()
    }
    
    private var animationProgress: CGFloat = 0
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer){
        switch recognizer.state {
            case .began:
                
                let state = currentState.opposite
                transitionAnimator = UIViewPropertyAnimator(duration: 3, dampingRatio: 1, animations: {
                    switch state {
                        case .open:
                            self.bottomConstraint.constant = 0
                        case .closed:
                            self.bottomConstraint.constant = 440
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
                            self.bottomConstraint.constant = 440
                    }
                }
                transitionAnimator.startAnimation()
                transitionAnimator.pauseAnimation()
                animationProgress = transitionAnimator.fractionComplete
            
            case .changed:
                let translation = recognizer.translation(in: popupView)
                var fraction = -translation.y / 440
                if currentState == .open { fraction *= -1 }
                transitionAnimator.fractionComplete = fraction + animationProgress
            case .ended:
                transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            default:
                ()
        }
    }
    

}


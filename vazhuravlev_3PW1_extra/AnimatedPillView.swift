//
//  AnimatedPillView.swift
//  vazhuravlev_3PW1_extra
//
//  Created by valeriy.zhuravlev on 16.09.2022.
//

import UIKit

class AnimatedPillView: UIView {
    
    private var state: State = .still
    
    private let view = UIView()
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    
    init(color: UIColor, topPadding: CGFloat, bottomPadding: CGFloat) {
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        view.backgroundColor = color
        addSubview(view)
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 7.0
        view.layer.shadowOpacity = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        view.layer.cornerRadius = min(view.frame.width, view.frame.height) / 2
        view.frame.size = .init(width: bounds.width, height: bounds.height - topPadding - bottomPadding)
        
        switch state {
        case .still:
            view.frame.origin = .init(x: bounds.minX, y: bounds.minY + topPadding)
        case .bumpedUp:
            view.frame.origin = .init(x: bounds.minX, y: bounds.minY)
        case .bumpedDown:
            view.frame.origin = .init(x: bounds.minX, y: bounds.minY + topPadding + bottomPadding)
        }
    }
    
    func bump(direction: BumpDirection, duration: TimeInterval, completion: (() -> (Void))?) {
        UIView.animate(withDuration: duration / 2, animations: {
            switch direction {
            case .up:
                self.state = .bumpedUp
            case .down:
                self.state = .bumpedDown
            }
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: duration / 2, animations: {
                self.state = .still
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }, completion: { _ in
                completion?()
            })
        })
    }
}


extension AnimatedPillView {
    
    enum BumpDirection {
        case up
        case down
    }
    
    private enum State {
        case bumpedUp
        case bumpedDown
        case still
    }
    
}

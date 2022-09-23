//
//  ViewController.swift
//  vazhuravlev_3PW1_extra
//
//  Created by valeriy.zhuravlev on 16.09.2022.
//

import UIKit

extension ViewController {
    private enum Constants {
        static let carHeight: CGFloat = 225.0
        static let buttonHeight: CGFloat = 64.0
        static let buttonWidth: CGFloat = 128.0
        static let buttonBottomOffset: CGFloat = 128.0
        static let buttonsSpacing = 36.0
    }
}

class ViewController: UIViewController {
    
    let carView = CarView(viewModel: .defaultCar)
    let turnButton = UIButton()
    let moveButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(carView)
        
        turnButton.backgroundColor = .blue
        turnButton.setTitleColor(.white, for: .normal)
        turnButton.setTitle("Повернуть", for: .normal)
        turnButton.addTarget(self, action: #selector(reverseCar), for: .touchUpInside)
        view.addSubview(turnButton)
        
        moveButton.backgroundColor = .blue
        moveButton.setTitleColor(.white, for: .normal)
        moveButton.setTitle("Подвинуть", for: .normal)
        moveButton.addTarget(self, action: #selector(moveCar), for: .touchUpInside)
        view.addSubview(moveButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        carView.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        carView.frame = .init(
            x: 0,
            y: (view.bounds.height - Constants.carHeight) / 2,
            width: view.bounds.width,
            height: Constants.carHeight
        )
        
        turnButton.frame = .init(
            x: (view.bounds.width - Constants.buttonsSpacing) / 2 - Constants.buttonWidth,
            y: view.bounds.height - Constants.buttonHeight - Constants.buttonBottomOffset,
            width: Constants.buttonWidth,
            height: Constants.buttonHeight
        )
        
        moveButton.frame = .init(
            x: (view.bounds.width + Constants.buttonsSpacing) / 2,
            y: view.bounds.height - Constants.buttonHeight - Constants.buttonBottomOffset,
            width: Constants.buttonWidth,
            height: Constants.buttonHeight
        )
    }
    
    @objc private func reverseCar() {
        carView.reverse(completion: nil)
    }
    
    @objc private func moveCar() {
        if carView.reversed {
            moveCarToLeft(completion: { [weak self] in
                self?.moveCarFromRight(completion: { [weak self] in
                    self?.moveCarToLeft(completion: { [weak self] in
                        self?.moveCarFromRight()
                    })
                })
            })
        } else {
            moveCarToRight(completion: { [weak self] in
                self?.moveCarFromLeft(completion: { [weak self] in
                    self?.moveCarToRight(completion: { [weak self] in
                        self?.moveCarFromLeft()
                    })
                })
            })
        }
    }
    
    private func moveCarFromLeft(completion: (() -> Void)? = nil) {
        self.carView.frame.origin = .init(
            x: -self.view.bounds.width,
            y: self.carView.frame.origin.y
        )
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.carView.frame.origin = .init(
                x: 0,
                y: self.carView.frame.origin.y
            )
        }, completion: { _ in
            completion?()
        })
    }
    
    private func moveCarToLeft(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.carView.frame.origin = .init(
                x: -self.view.bounds.width,
                y: self.carView.frame.origin.y
            )
        }, completion: { _ in
            completion?()
        })
    }
    
    private func moveCarFromRight(completion: (() -> Void)? = nil) {
        self.carView.frame.origin = .init(
            x: self.view.bounds.width,
            y: self.carView.frame.origin.y
        )
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.carView.frame.origin = .init(
                x: 0,
                y: self.carView.frame.origin.y
            )
        }, completion: { _ in
            completion?()
        })
    }
    
    private func moveCarToRight(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.carView.frame.origin = .init(
                x: self.view.bounds.width,
                y: self.carView.frame.origin.y
            )
        }, completion: { _ in
            completion?()
        })
    }

}


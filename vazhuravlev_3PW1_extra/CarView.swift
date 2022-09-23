//
//  CarView.swift
//  vazhuravlev_3PW1_extra
//
//  Created by valeriy.zhuravlev on 16.09.2022.
//

import UIKit

class CarView: UIView {
    
    private let viewModel: ViewModel
    private var pills: [AnimatedPillView]
    private let rearWheel: AnimatedPillView
    private let frontWheel: AnimatedPillView
    private let frontDisc: UIView
    private let rearDisc: UIView
    
    var reversed = false
    private var shouldBeReversed = false
    private var onReverseCompletion: (() -> Void)?
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        rearDisc = UIView()
        rearWheel = AnimatedPillView(color: viewModel.pillColor, topPadding: 0, bottomPadding: 0)
        frontDisc = UIView()
        frontWheel = AnimatedPillView(color: viewModel.pillColor, topPadding: 0, bottomPadding: 0)
        pills = []
        
        super.init(frame: .zero)
        
        for _ in 0 ..< viewModel.pillCoordinates.count {
            let pillView = AnimatedPillView(
                color: viewModel.pillColor,
                topPadding: viewModel.pillPaddinds,
                bottomPadding: viewModel.pillPaddinds
            )
            addSubview(pillView)
            pills.append(pillView)
        }
        
        addSubview(rearWheel)
        rearWheel.addSubview(rearDisc)
        addSubview(frontWheel)
        frontWheel.addSubview(frontDisc)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutPills()
        layoutWheels()
    }
    
    private func layoutPills() {
        let height = bounds.height
        let width = bounds.width
        
        let pillCount = viewModel.pillCoordinates.count
        let pillWidth: CGFloat = (width - CGFloat(pillCount - 1) * viewModel.pillSpacing) / CGFloat(pillCount)
        
        for i in 0 ..< pillCount {
            if reversed {
                let back = pillCount - i - 1
                pills[back].frame = .init(
                    x: CGFloat(i) * (pillWidth + viewModel.pillSpacing),
                    y: viewModel.pillCoordinates[back].pillStart * height,
                    width: pillWidth,
                    height: (viewModel.pillCoordinates[back].pillEnd - viewModel.pillCoordinates[back].pillStart) * height
                )
            } else {
                pills[i].frame = .init(
                    x: CGFloat(i) * (pillWidth + viewModel.pillSpacing),
                    y: viewModel.pillCoordinates[i].pillStart * height,
                    width: pillWidth,
                    height: (viewModel.pillCoordinates[i].pillEnd - viewModel.pillCoordinates[i].pillStart) * height
                )
            }
        }
    }
    
    private func layoutWheels() {
        let height = bounds.height
        let width = bounds.width
        let frontWheelRadius: CGFloat = height * (viewModel.frontWheelParameters.wheelBottom - viewModel.frontWheelParameters.wheelTop) / 2
        let rearWheelRadius: CGFloat = height * (viewModel.rearWheelParameters.wheelBottom - viewModel.rearWheelParameters.wheelTop) / 2
        
        let frontWheelX = width * viewModel.frontWheelParameters.wheelXCoordinate - frontWheelRadius
        let rearWheelX = width * viewModel.rearWheelParameters.wheelXCoordinate - rearWheelRadius
        frontWheel.frame.size = .init(width: frontWheelRadius * 2, height: frontWheelRadius * 2)
        rearWheel.frame.size = .init(width: rearWheelRadius * 2, height: rearWheelRadius * 2)
        
        if reversed {
            frontWheel.frame.origin = .init(x: width - frontWheelX - 2 * frontWheelRadius,
                                            y: height * viewModel.frontWheelParameters.wheelTop)
            rearWheel.frame.origin = .init(x: width - rearWheelX - 2 * frontWheelRadius,
                                           y: height * viewModel.rearWheelParameters.wheelTop)
        } else {
            frontWheel.frame.origin = .init(x: frontWheelX, y: height * viewModel.frontWheelParameters.wheelTop)
            rearWheel.frame.origin = .init(x: rearWheelX, y: height * viewModel.rearWheelParameters.wheelTop)
        }
        
        layoutDiscs()
    }
    
    private func layoutDiscs() {
        let frontDiscRadius = (frontWheel.frame.width / 2 - viewModel.frontWheelParameters.discOffset) / sqrt(2)
        frontDisc.backgroundColor = .white
        frontDisc.center = .init(x: frontWheel.bounds.width / 2, y: frontWheel.bounds.height / 2)
        frontDisc.frame.size = .init(width: frontDiscRadius * 2, height: frontDiscRadius * 2)
        frontDisc.layer.cornerRadius = viewModel.frontWheelParameters.discCornerRadius
        
        let rearDiscRadius = (rearWheel.frame.width / 2 - viewModel.rearWheelParameters.discOffset) / sqrt(2)
        rearDisc.backgroundColor = .white
        rearDisc.center = .init(x: rearWheel.bounds.width / 2, y: rearWheel.bounds.height / 2)
        rearDisc.frame.size = .init(width: rearDiscRadius * 2, height: rearDiscRadius * 2)
        rearDisc.layer.cornerRadius = viewModel.rearWheelParameters.discCornerRadius
    }
    
    func reverse(completion: (() -> Void)?) {
        onReverseCompletion = completion
        shouldBeReversed = true
    }
    
    func startAnimating() {
        startWheelRotation(direction: self.reversed ? .left : .right)
        playAnimationFor(pillIndex: 0)
    }
    
    private func _reverse(completion: (() -> Void)?) {
        UIView.animate(withDuration: viewModel.reverseDuration, animations: {
            self.shouldBeReversed = false
            self.reversed = !self.reversed
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    
    private func playAnimationFor(pillIndex: Int) {
        guard pillIndex != pills.count else {
            playAnimationFor(pillIndex: 0)
            return
        }
        
        if shouldBeReversed {
            stopWheelRotation()
            _reverse {
                self.startWheelRotation(direction: self.reversed ? .left : .right)
                self.playAnimationFor(pillIndex: pillIndex)
            }
        } else {
            if reversed {
                pills[pillIndex].bump(direction: .down, duration: viewModel.bumpDuration) {
                    self.playAnimationFor(pillIndex: pillIndex + 1)
                }
            } else {
                pills[pillIndex].bump(direction: .up, duration: viewModel.bumpDuration) {
                    self.playAnimationFor(pillIndex: pillIndex + 1)
                }
            }
        }
    }
    
    private func startWheelRotation(direction: WheelRotationDirection) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        switch direction {
        case .left:
            rotation.toValue = -CGFloat.pi * 2
        case .right:
            rotation.toValue = CGFloat.pi * 2
        }
        rotation.duration = viewModel.wheelRotateDuration
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        frontWheel.layer.add(rotation, forKey: "rotationAnimation")
        rearWheel.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    private func stopWheelRotation() {
        frontWheel.layer.removeAnimation(forKey: "rotationAnimation")
        rearWheel.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    private enum WheelRotationDirection {
        case left
        case right
    }
    
}

extension CarView {
    struct ViewModel {
        static let defaultCar: ViewModel = .init(
            pillSpacing: 7.0,
            pillPaddinds: 12.0,
            pillCoordinates: [
                .init(pillStart: 0.5, pillEnd: 0.80),
                .init(pillStart: 0.38, pillEnd: 0.87),
                .init(pillStart: 0.18, pillEnd: 0.92),
                .init(pillStart: 0.13, pillEnd: 0.72),
                .init(pillStart: 0.13, pillEnd: 0.70),
                .init(pillStart: 0.13, pillEnd: 0.72),
                .init(pillStart: 0.13, pillEnd: 0.92),
                .init(pillStart: 0.16, pillEnd: 0.92),
                .init(pillStart: 0.2, pillEnd: 0.92),
                .init(pillStart: 0.25, pillEnd: 0.92),
                .init(pillStart: 0.33, pillEnd: 0.92),
                .init(pillStart: 0.4, pillEnd: 0.92),
                .init(pillStart: 0.45, pillEnd: 0.92),
                .init(pillStart: 0.5, pillEnd: 0.72),
                .init(pillStart: 0.53, pillEnd: 0.70),
                .init(pillStart: 0.55, pillEnd: 0.72),
                .init(pillStart: 0.58, pillEnd: 0.82)
            ],
            pillColor: .blue,
            
            frontWheelParameters: .init(
                wheelTop: 0.71,
                wheelBottom: 1,
                wheelXCoordinate: 0.26,
                discOffset: 5.0,
                discCornerRadius: 10.0
            ),
            
            rearWheelParameters: .init(
                wheelTop: 0.71,
                wheelBottom: 1,
                wheelXCoordinate: 0.855,
                discOffset: 5.0,
                discCornerRadius: 10.0
            ),
            
            reverseDuration: 1.0,
            bumpDuration: 0.2,
            wheelRotateDuration: 2.0
        )
        
        let pillSpacing: CGFloat
        let pillPaddinds: CGFloat
        let pillCoordinates: [PillCoordinate]
        let pillColor: UIColor
        
        let frontWheelParameters: WheelParameters
        let rearWheelParameters: WheelParameters
        
        let reverseDuration: TimeInterval
        let bumpDuration: TimeInterval
        let wheelRotateDuration: CGFloat
        
        struct PillCoordinate {
            let pillStart: CGFloat
            let pillEnd: CGFloat
        }
        
        struct WheelParameters {
            let wheelTop: CGFloat
            let wheelBottom: CGFloat
            let wheelXCoordinate: CGFloat
            let discOffset: CGFloat
            let discCornerRadius: CGFloat
        }
    }
}

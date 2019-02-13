//
//  CircleView.swift
//  CreditScore
//
//  Created by krawiecp-home on 12/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import UIKit

final class CircleView: UIView {
    private let outerCircleLayer = CAShapeLayer()
    private let innerCircleLayer = CAShapeLayer()
    private let innerCircleGradientLayer = CAGradientLayer()
    private let topLabel = UILabel()
    private let centerLabel = UILabel()
    private let bottomLabel = UILabel()
    private var range: ClosedRange<Int>?
    
    // Constants
    private let outerCircleLineWidth: CGFloat = 2.0
    private let innerCircleLineWidth: CGFloat = 7.0
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buildLayers()
    }
    
    func startAnimating() {
        let duration: CFTimeInterval = 1.3
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.duration = duration / 0.4
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * Double.pi
        rotationAnimation.repeatCount = .infinity
        outerCircleLayer.add(rotationAnimation, forKey: "rotationAnimation")
        
        let headAnimation = CABasicAnimation(keyPath: "strokeStart")
        headAnimation.duration = duration / 1.5
        headAnimation.fromValue = 0
        headAnimation.toValue = 0.25
        
        let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailAnimation.duration = duration / 1.5
        tailAnimation.fromValue = 0
        tailAnimation.toValue = 1
        
        let endHeadAnimation = CABasicAnimation(keyPath: "strokeStart")
        endHeadAnimation.duration = duration / 3
        endHeadAnimation.beginTime = duration / 1.5
        endHeadAnimation.fromValue = 0.25
        endHeadAnimation.toValue = 1
        
        let endTailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endTailAnimation.duration = duration / 3
        endTailAnimation.beginTime = duration / 1.5
        endTailAnimation.fromValue = 1
        endTailAnimation.toValue = 1
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animationGroup.animations = [headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]
        animationGroup.repeatCount = .infinity
        animationGroup.isRemovedOnCompletion = false;
        outerCircleLayer.add(animationGroup, forKey: "animationGroup")
    }
    
    func stopAnimating() {
        outerCircleLayer.removeAllAnimations()
        outerCircleLayer.strokeStart = 0
        outerCircleLayer.strokeEnd = 1
    }
    
    func setValue(_ value: Int, range: ClosedRange<Int> = 0...700) {
        self.range = range
        let clampedValue: CGFloat  = CGFloat(min(max(value, range.lowerBound), range.upperBound)) / CGFloat(range.upperBound)
        
        let innerCircleAnimation = CABasicAnimation(keyPath: "strokeEnd")
        innerCircleAnimation.duration = 0.7
        innerCircleAnimation.fromValue = 0
        innerCircleAnimation.toValue = clampedValue
        innerCircleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        innerCircleLayer.strokeEnd = clampedValue
        innerCircleLayer.add(innerCircleAnimation, forKey: "outerCircleAnimation")
        
        // hardcoded some random colors
        innerCircleGradientLayer.colors =  [UIColor.green.cgColor,
                                            UIColor.orange.cgColor,
                                            UIColor.red.cgColor]
        innerCircleGradientLayer.locations = [0, 0.5, 1]
        buildLabel(with: value)
    }
    
    private func buildLayers() {
        let arcCenter = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let startAngle = CGFloat(-0.5 * Double.pi)
        let endAngle =  CGFloat(1.5 * Double.pi)
        
        let circlePath = UIBezierPath(arcCenter: arcCenter,
                                      radius: (frame.size.width - outerCircleLineWidth) / 2.0,
                                      startAngle: startAngle,
                                      endAngle: endAngle,
                                      clockwise: true)
        setupOuterCircle(outerCirclePath: circlePath)
        layer.addSublayer(outerCircleLayer)

        
        let innerCirclePath = UIBezierPath(arcCenter: arcCenter,
                                           radius: (frame.size.width - outerCircleLineWidth * 12) / 2.0,
                                           startAngle: startAngle,
                                           endAngle: endAngle,
                                           clockwise: true)
        setupInnerCircle(innerCirclePath: innerCirclePath)
        layer.addSublayer(innerCircleGradientLayer)
    }
    
    private func setupOuterCircle(outerCirclePath: UIBezierPath) {
        outerCircleLayer.path = outerCirclePath.cgPath
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.strokeColor = UIColor.black.cgColor
        outerCircleLayer.lineWidth = outerCircleLineWidth
        outerCircleLayer.lineCap = CAShapeLayerLineCap.round
        outerCircleLayer.frame = bounds
        outerCircleLayer.strokeStart = 0
        outerCircleLayer.strokeEnd = 1
    }
    
    private func setupInnerCircle(innerCirclePath: UIBezierPath) {
        innerCircleLayer.path = innerCirclePath.cgPath
        innerCircleLayer.fillColor = UIColor.clear.cgColor
        innerCircleLayer.strokeColor = UIColor.black.cgColor
        innerCircleLayer.lineWidth = innerCircleLineWidth
        innerCircleLayer.lineCap = CAShapeLayerLineCap.round
        innerCircleGradientLayer.opacity = 0.3
        innerCircleGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        innerCircleGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        innerCircleGradientLayer.frame = bounds
        innerCircleGradientLayer.mask = innerCircleLayer
    }
    
    private func buildLabel(with value: Int) {
        // there are some harcoded strings and duplicated code
        // but I think it;s fine for exercise purposes
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topLabel)
        topLabel.text = "Your credit score is"
        topLabel.textAlignment = .center

        centerLabel.textAlignment = .center
        centerLabel.adjustsFontSizeToFitWidth = true
        centerLabel.numberOfLines = 1
        centerLabel.font = UIFont.systemFont(ofSize: 42, weight: .light)
        centerLabel.minimumScaleFactor = 0.1
        centerLabel.text = "\(value)"
        
        addSubview(centerLabel)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomLabel)
        bottomLabel.text = "out of \(range?.upperBound ?? 0)"
        bottomLabel.textAlignment = .center
        
        centerLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        centerLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        centerLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        topLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topLabel.bottomAnchor.constraint(equalTo: centerLabel.topAnchor, constant: -10).isActive = true
        
        bottomLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomLabel.topAnchor.constraint(equalTo: centerLabel.bottomAnchor, constant: 10).isActive = true
    }
}

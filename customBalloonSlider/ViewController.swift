//
//  ViewController.swift
//  ballonSlider
//
//  Created by ABBAS on 10/28/19.
//  Copyright © 2019 ABBAS. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, UpdateTimer {
    
    private var canvasLine: LineCanvas!
    private var passedCanvasLine: LineCanvas!
    private var balloon: UIImageView!
    private var circleuar: UIImageView!
    private var timer: Timer!
    private var thumbTimer: Timer!
    private var translationX: CGFloat = 0
    private var currentPosition:CGFloat = 0;
    private var updateListener: UpdateTimer!
    private var valueCount: UILabel!
    private var screenPercent: CGFloat!
    private var allowToAnimate: Bool = true
    private var radians: CGFloat = 0
    private var position: CGFloat = 0
    private var isTouching = false
    private var balloonAnimationUpdater: CFloat = 0
    private var isThumbVisible = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateListener = self
        screenPercent = (self.view.frame.size.width - 40) / 100
        
        valueCount = UILabel(frame: CGRect(x: 0, y: 10, width: 60, height: 21))
        valueCount.text = "0"
        valueCount.font = UIFont.boldSystemFont(ofSize: 18.0)
        valueCount.textColor = .white
        valueCount.textAlignment = .center
        
        canvasLine = LineCanvas(frame: CGRect(x: 20, y: 200, width: self.view.frame.width - 40, height: 4))
        canvasLine.setStyle(color: UIColor(red: 106/255.0, green: 90/255.0, blue: 205/255.0, alpha: 1), width: 4)
        canvasLine.backgroundColor = .white
        self.view.addSubview(canvasLine)
        
        passedCanvasLine = LineCanvas(frame: CGRect(x: 20, y: 200, width: 1, height: 4))
        passedCanvasLine.setStyle(color: UIColor(red: 0, green: 0, blue: 255/255.0, alpha: 1), width: 5)
        passedCanvasLine.backgroundColor = .white
        self.view.addSubview(passedCanvasLine)
        
        circleuar = UIImageView(frame: CGRect(x: 20, y: 190, width: 20, height: 20))
        circleuar.image = UIImage(named: "circle")
        self.view.addSubview(circleuar)
        self.view.backgroundColor = .white
        
        balloon = UIImageView(frame: CGRect(x: 20, y: 70, width: 60, height: 85))
        balloon.image = UIImage(named: "balloon")
        self.view.addSubview(balloon)
        balloon.addSubview(valueCount)
        balloon.contentMode = .scaleAspectFit
        valueCount.frame.origin = CGPoint(x: 0, y: 10)
        balloon.alpha = 0
        balloon.transform = CGAffineTransform(translationX: 0, y: 110)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(gestureRecognizer:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        
        timer = Timer.scheduledTimer(timeInterval: 0.033, target:self, selector:  #selector(updateProgress), userInfo: nil, repeats: true)
        
    }
    
    private func startThumbTimer(isVisible: Bool) {
        isThumbVisible = isVisible
        thumbTimer?.invalidate()
        balloonAnimationUpdater = isThumbVisible ? 0 : 100
        allowToAnimate = false
        thumbTimer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:  #selector(updateThumbState), userInfo: nil, repeats: true)
    }
    
    func onUpdate(position: CGFloat, rotation: CGFloat, side: Int8) {
        self.position = position
        radians = rotation / 180.0 * CGFloat.pi
        if !allowToAnimate {
            return
        }
        let rot = CGAffineTransform(translationX: position, y: 0).rotated(by: radians)
        self.balloon.transform = rot
    }
    
    @objc func updateThumbState() {
        if isThumbVisible {
            balloonAnimationUpdater += 3
        } else {
            balloonAnimationUpdater -= 3
        }
        
        if balloonAnimationUpdater > 100 {
            balloonAnimationUpdater = 100
        }
        
        if balloonAnimationUpdater < 0 {
            balloonAnimationUpdater = 0
        }
        
        let rot = CGAffineTransform(translationX: position, y: CGFloat((110 * (1 - (balloonAnimationUpdater / 100)))))
            .rotated(by: radians)
            .scaledBy(x: CGFloat(balloonAnimationUpdater / 100), y: CGFloat(balloonAnimationUpdater / 100))
        self.balloon.alpha = CGFloat(balloonAnimationUpdater / 100)
        self.valueCount.alpha = CGFloat(balloonAnimationUpdater / 100)
        self.balloon.transform = rot
        
        if balloonAnimationUpdater == 100 || balloonAnimationUpdater == 0 {
            allowToAnimate = true
            isThumbVisible = !isThumbVisible
            thumbTimer.invalidate()
        }
        
    }
    
    @objc func updateProgress() {
        let targetPosition = translationX - 35;
        let maxNumber: CGFloat = 2;
        var valueToAdd: CGFloat = 12;
        let calcVal: CGFloat = currentPosition - targetPosition;
        
        if (calcVal > maxNumber){
            if (calcVal > 170) {
                valueToAdd = 34;
            } else if (calcVal < 100) {
                valueToAdd = 7;
                if (calcVal < 20) {
                    valueToAdd = 2;
                }
            }
            currentPosition -= valueToAdd;
            let rotation: CGFloat = ((calcVal > 100 ? 100 : calcVal) / 100) * 26;
            updateListener.onUpdate(position: currentPosition, rotation: rotation, side: 1);
            
        } else if (calcVal < -maxNumber){
            if (calcVal < -170){
                valueToAdd = 34;
            }else if (calcVal > -100) {
                valueToAdd = 7;
                if (calcVal > -20) {
                    valueToAdd = 2;
                }
            }
            currentPosition += valueToAdd;
            let rotation: CGFloat = ((calcVal < -100 ? 100 : abs(calcVal)) / 100) * 26;
            
            updateListener.onUpdate(position: currentPosition, rotation: -rotation, side: -1);
        } else {
            if (currentPosition != targetPosition){
                currentPosition = targetPosition;
                updateListener.onUpdate(position: currentPosition, rotation: 0, side: 0);
            }
        }
        
    }
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        let touchLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        if touchLocation.x > 0 && touchLocation.x < self.view.frame.size.width - 40 {
            translationX = touchLocation.x
            valueCount.text = "\(Int(round(translationX / screenPercent)))"
            if gestureRecognizer.state == .changed {
                self.passedCanvasLine.frame = CGRect(x: 20, y: 200, width: self.translationX, height: 4)
                UIView.animate(withDuration: 0.01, animations: {
                    self.circleuar.transform = CGAffineTransform(translationX: self.translationX, y: 0)
                })
                
                UIView.animate(withDuration: 0.3) {
                    self.circleuar.frame = CGRect(x: self.translationX - 5, y:180, width: 40, height: 40)
                }
                if !isTouching {
                    startThumbTimer(isVisible: true)
                    isTouching = !isTouching
                }
            }
        }
        if touchLocation.x < self.view.frame.size.width - 20 {
            if gestureRecognizer.state == .ended {
                
                UIView.animate(withDuration: 0.3) {
                    self.circleuar.frame = CGRect(x: self.translationX + 5, y: 190, width: 20, height: 20)
                }
                startThumbTimer(isVisible: false)
                isTouching = false
            }
        }
    }
    
}

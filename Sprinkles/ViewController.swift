//
//  ViewController.swift
//  Sprinkles
//
//  Created by Michael Tang on 1/1/17.
//  Copyright © 2017 Michael Tang. All rights reserved.
//

import UIKit
import CoreMotion


class ViewController: UIViewController {
    
    var sprinkleSet:[UIView] = []
    var animator:UIDynamicAnimator? = UIDynamicAnimator()
    var collider = UICollisionBehavior()
    let gravity = UIGravityBehavior()
    
    let SPRITE_WIDTH = 25
    let SPRITE_HEIGHT = 25
    let SPRITE_COUNT = 100 //Pushing passed 100 causes device to lag

    let manager:CMMotionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateSprinklesView()
        gravityOnSprinklesView()
        gyroscopeEffect()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        manager.stopAccelerometerUpdates()
        // Dispose of any resources that can be recreated.
    }
    


    override func viewWillDisappear(_ animated: Bool) {
        manager.stopAccelerometerUpdates()
    }
    func populateSprinklesView() -> Void {
        let bound = UIScreen.main.bounds
        let x = bound.maxX
        let y = bound.maxY
        
        //Create sprinkles
        for _ in 0..<SPRITE_COUNT {
            //Random position on screen
            let ranLocx = Int(arc4random_uniform(UInt32(x)))
            let ranLocy = Int(arc4random_uniform(UInt32(y)))-SPRITE_WIDTH
            //Random color
            let r = Float(arc4random_uniform(UInt32(256)))
            let g = Float(arc4random_uniform(UInt32(256)))
            let b = Float(arc4random_uniform(UInt32(256)))
            
            let sprite = UIView(frame:CGRect(x: ranLocx, y: ranLocy, width:SPRITE_WIDTH, height: SPRITE_HEIGHT))
            sprite.backgroundColor = UIColor.init(red: CGFloat(r/230), green: CGFloat(g/230), blue: CGFloat(b/230), alpha: CGFloat(1.0))
            sprite.layer.cornerRadius = CGFloat(SPRITE_HEIGHT/2)
            //Touch drag gesture recognizer
            sprite.isUserInteractionEnabled = true
            let p = UIPanGestureRecognizer(target: self, action: #selector(dragging))
            //let t = UITapGestureRecognizer(target: self, action: #selector(touch))
            //sprite.addGestureRecognizer(t)
            sprite.addGestureRecognizer(p)
            
            
            self.view.addSubview(sprite)
            self.sprinkleSet.append(sprite)
        }
    }
    
    func gravityOnSprinklesView() -> Void {
        animator = UIDynamicAnimator(referenceView:self.view);
        animator?.addBehavior(collider)
        collider.translatesReferenceBoundsIntoBoundary = true
        
        for i in 0..<SPRITE_COUNT{
            gravity.addItem(sprinkleSet[i])
            collider.addItem(sprinkleSet[i])
        }
        
        gravity.gravityDirection = CGVector(dx: 0.0, dy: 0.5)

        animator?.addBehavior(gravity)
        animator?.addBehavior(collider)
    }
    
    func dragging(_ p : UIPanGestureRecognizer){
        let v = p.view!
        switch p.state {
        case .began, .changed:
            let delta = p.translation(in: v.superview)
            var c = v.center
            c.x += delta.x
            c.y += delta.y
            v.center = c
            p.setTranslation(.zero, in: v.superview)
        default:
            break
        }
    }
    
    func touch(_ p : UIPanGestureRecognizer){
        let dx = gravity.gravityDirection.dx * -1
        let dy = gravity.gravityDirection.dy * -1
        gravity.gravityDirection = CGVector(dx: dx, dy: dy)
    }
    
    func gyroscopeEffect() -> Void {
        manager.accelerometerUpdateInterval = 0.2
        manager.startAccelerometerUpdates(to: OperationQueue.main){(data, error) in
            if let accelerometerData = self.manager.accelerometerData {
                self.gravity.gravityDirection = CGVector(dx: Double(accelerometerData.acceleration.x), dy: Double(accelerometerData.acceleration.y)*(-1))
            }
        }
    }
    
}


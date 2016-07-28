//
//  ViewController.swift
//  Breakout
//
//  Created by Saurav Desai on 7/28/16.
//  Copyright © 2016 Saurav Desai. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    var dynamicAnimator = UIDynamicAnimator()
    var collisionBehavior = UICollisionBehavior()
    var paddle = UIView()
    var ball = UIView()
    var bricks = [UIView]()
    var lives = 5
    var numBricks = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add a ball to the frame
        ball = UIView(frame: CGRectMake(view.center.x - 10, view.center.y, 20, 20))
        ball.backgroundColor = UIColor.blackColor()
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        // Add a red paddle object to the view
        paddle = UIView(frame: CGRectMake(view.center.x - 40, view.center.y * 1.7, 80, 20))
        paddle.backgroundColor = UIColor.redColor()
        view.addSubview(paddle)
        
        for j in 0..<8{
            for i in 0..<10{
                bricks.append(UIView(frame: CGRectMake(CGFloat(40*i), CGFloat(20*j), 39, 19)))
                numBricks += 1
                bricks[numBricks-1].backgroundColor = UIColor.redColor()
                view.addSubview(bricks[numBricks-1])
                if CGFloat(40*(i+1)+39) > view.frame.width{
                    break
                }
                
            }
        }
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        // Create dynamic behavior for the ball
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0  // Collision resistance
        ballDynamicBehavior.resistance = 0  // deceleration over time
        ballDynamicBehavior.elasticity = 1.0  // Bounce factor
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
    }
    
    
}


//
//  ViewController.swift
//  Breakout
//
//  Created by Saurav Desai on 7/28/16.
//  Copyright © 2016 Saurav Desai. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playAgainView: UIView!
    
    var dynamicAnimator = UIDynamicAnimator()
    var collisionBehavior = UICollisionBehavior()
    var paddle = UIView()
    var ball = UIView()
    var bricks = [UIView]()
    var lives = 5
    var numBricks = 0
    var bricksDestroyed = 0
    var isFirst : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livesLabel.text = "Lives: 5"
        timerLabel.text = "Ready?"
        playAgainView.isHidden = true
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        // add a ball to the frame
        ball = UIView(frame: CGRect(x: view.center.x - 10, y: view.center.y, width: 20, height: 20))
        ball.backgroundColor = UIColor.black
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        // Add a red paddle object to the view
        paddle = UIView(frame: CGRect(x: view.center.x - 40, y: view.center.y * 1.7, width: 80, height: 20))
        paddle.backgroundColor = UIColor.red
        view.addSubview(paddle)
        
        for j in 0..<10{
            for i in 0..<10{
                let brick = UIView(frame: CGRect(x: CGFloat(i) * self.view.frame.width / 10, y: CGFloat(20*j), width: self.view.frame.width / 10, height: 20))
                brick.layer.borderColor = UIColor.white.cgColor
                brick.layer.borderWidth = 1
                if j < 5{
                    brick.alpha = 1
                }
                else{
                    brick.alpha = 0.5
                }
                bricks.append(brick)
                numBricks += 1
                bricks[numBricks-1].backgroundColor = UIColor.blue
                view.addSubview(bricks[numBricks-1])
            }
        }
        
        for brick in bricks{
            let brickDynamicBehavior = UIDynamicItemBehavior(items: [brick])
            brickDynamicBehavior.density = 10000
            brickDynamicBehavior.resistance = 100
            brickDynamicBehavior.allowsRotation = false
            dynamicAnimator.addBehavior(brickDynamicBehavior)
        }
        
        // Create dynamic behavior for the ball
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0  // Collision resistance
        ballDynamicBehavior.resistance = -0.01 // acceleration over time
        ballDynamicBehavior.elasticity = 1.0  // Bounce factor
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        // Create dynamic behavior for the paddle
        let paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.density = 10000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        // Create a push behavior to get the ball moving
        let pushBehavior = UIPushBehavior(items: [ball], mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 0.3, dy: -1.0)
        pushBehavior.magnitude = 0.25
        
        timerLabel.text = "Ready?"
        let triggerTime1 = (Int64(NSEC_PER_SEC) * 2)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime1) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.timerLabel.text = "Go!"
        })
        
        
        var item = bricks
        item.append(paddle)
        item.append(ball)
        
        // Create collision behaviors so ball can bounce off of other objects
        collisionBehavior = UICollisionBehavior(items: item)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        let triggerTime = (Int64(NSEC_PER_SEC) * 2)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.dynamicAnimator.addBehavior(pushBehavior)
        })
        
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint){
        if item.isEqual(ball) && p.y > paddle.center.y{
            lives -= 1
            if lives > 0{
                livesLabel.text = "Lives: \(lives)"
                self.ball.center = self.view.center
                self.dynamicAnimator.updateItem(usingCurrentState: self.ball)
            } 
            else{
                livesLabel.text = "😞GAME OVER😞"
                ball.removeFromSuperview()
                collisionBehavior.removeItem(ball)
                dynamicAnimator.updateItem(usingCurrentState: ball)
                ball.removeFromSuperview()
                collisionBehavior.removeItem(ball)
                dynamicAnimator.updateItem(usingCurrentState: ball)
                let triggerTime = (Int64(NSEC_PER_SEC) * 2)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                    self.playAgainView.isHidden = false
                })
                
            }
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint){
        for brick in bricks{
            if (item1.isEqual(ball) && item2.isEqual(brick)) || (item1.isEqual(brick) && item2.isEqual(ball)){
                timerLabel.text = ""
                if brick.alpha == 1.0{
                    brick.alpha = 0.5
                } 
                else{
                    brick.isHidden = true
                    collisionBehavior.removeItem(brick)
                    bricksDestroyed += 1
                }
            }
        }
        if bricksDestroyed == numBricks{
            livesLabel.text = "😃YOU WIN😃"
            sleep(2)
            self.playAgainView.isHidden = false
            ball.removeFromSuperview()
            collisionBehavior.removeItem(ball)
            dynamicAnimator.updateItem(usingCurrentState: ball)
        }
        
    }
    
    func reNew(){
        UIApplication.shared.keyWindow?.rootViewController = storyboard!.instantiateViewController(withIdentifier: "ViewController")
    }
    
    @IBAction func dragPaddle(_ sender: UIPanGestureRecognizer){
        let panGesture = sender.location(in: view)
        paddle.center.x = panGesture.x
        dynamicAnimator.updateItem(usingCurrentState: paddle)
    }
    
    @IBAction func onTappedYesButton(_ sender: UIButton) {
        reNew()
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        reNew()
    }
}

























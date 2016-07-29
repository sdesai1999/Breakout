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
        playAgainView.hidden = true
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
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
        
        for j in 0..<10{
            for i in 0..<10{
                let brick = UIView(frame: CGRectMake(CGFloat(i) * self.view.frame.width / 10, CGFloat(20*j), self.view.frame.width / 10, 20))
                brick.layer.borderColor = UIColor.whiteColor().CGColor
                brick.layer.borderWidth = 1
                if j < 5{
                    brick.alpha = 1
                }
                else{
                    brick.alpha = 0.5
                }
                bricks.append(brick)
                numBricks += 1
                bricks[numBricks-1].backgroundColor = UIColor.blueColor()
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
        let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.3, -1.0)
        pushBehavior.magnitude = 0.25
        
        timerLabel.text = "Ready?"
        let triggerTime1 = (Int64(NSEC_PER_SEC) * 2)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime1), dispatch_get_main_queue(), { () -> Void in
            self.timerLabel.text = "Go!"
        })
        
        
        var item = bricks
        item.append(paddle)
        item.append(ball)
        
        // Create collision behaviors so ball can bounce off of other objects
        collisionBehavior = UICollisionBehavior(items: item)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .Everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        let triggerTime = (Int64(NSEC_PER_SEC) * 2)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.dynamicAnimator.addBehavior(pushBehavior)
        })
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint){
        if item.isEqual(ball) && p.y > paddle.center.y{
            lives -= 1
            if lives > 0{
                livesLabel.text = "Lives: \(lives)"
                sleep(1)
                self.ball.center = self.view.center
                self.dynamicAnimator.updateItemUsingCurrentState(self.ball)
            } 
            else{
                livesLabel.text = "😞GAME OVER😞"
                ball.removeFromSuperview()
                collisionBehavior.removeItem(ball)
                dynamicAnimator.updateItemUsingCurrentState(ball)
                ball.removeFromSuperview()
                collisionBehavior.removeItem(ball)
                dynamicAnimator.updateItemUsingCurrentState(ball)
                let triggerTime = (Int64(NSEC_PER_SEC) * 2)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    self.playAgainView.hidden = false
                })
                
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint){
        for brick in bricks{
            if (item1.isEqual(ball) && item2.isEqual(brick)) || (item1.isEqual(brick) && item2.isEqual(ball)){
                timerLabel.text = ""
                if brick.alpha == 1.0{
                    brick.alpha = 0.5
                } 
                else{
                    brick.hidden = true
                    collisionBehavior.removeItem(brick)
                    bricksDestroyed += 1
                }
            }
        }
        if bricksDestroyed == numBricks{
            livesLabel.text = "😃YOU WIN😃"
            sleep(2)
            self.playAgainView.hidden = false
            ball.removeFromSuperview()
            collisionBehavior.removeItem(ball)
            dynamicAnimator.updateItemUsingCurrentState(ball)
        }
        
    }
    
    func reNew(){
        UIApplication.sharedApplication().keyWindow?.rootViewController = storyboard!.instantiateViewControllerWithIdentifier("ViewController")
    }
    
    @IBAction func dragPaddle(sender: UIPanGestureRecognizer){
        let panGesture = sender.locationInView(view)
        paddle.center.x = panGesture.x
        dynamicAnimator.updateItemUsingCurrentState(paddle)
    }
    
    @IBAction func onTappedYesButton(sender: UIButton) {
        reNew()
    }
    
}

























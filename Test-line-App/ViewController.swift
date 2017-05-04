//
//  ViewController.swift
//  Test-line-App
//
//  Created by Radian on 04/05/2017.
//  Copyright © 2017 Radian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        createButton()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func createButton() {
        let button = UIButton( type: .custom)
        
        button.frame = CGRect(x: 50.0, y: 50.0, width: 300.0, height: 300.0)
//        button.setTitle(NSLocalizedString("Button", comment: "Button"), for: .normal)
//        let image = UIImage(named: "black")!
        
        let image = getSketchImg(button.frame)
        
        button.setImage(image,for:.normal)
        button.imageView?.contentMode = .scaleAspectFill
        
        
//        button.layer.borderWidth = 2.0
//        button.layer.borderColor = UIColor.green.cgColor
        
//        button.backgroundColor = .green
        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        view.addSubview(button)
        
        

        
    }

    
    @objc func buttonAction(sender: UIButton) {
        print("Button pushed")
    }

    func getSketchImg (_ frame :CGRect ) -> UIImage{
        print(frame.size)
        
        
        UIGraphicsBeginImageContextWithOptions(frame.size,false,0.0)
        
//        frame.
        
        print(frame)
        
        let p  = 5 // padding
        
        let w = Int(frame.size.width) -  2 * p
        let h = Int(frame.size.height) - 2 * p
        
        
        let mainPath = UIBezierPath()
        mainPath.move(to:CGPoint(x:p, y:p))
        handToPoint(mainPath,(p + w, p ))
        handToPoint(mainPath,(p + w, p + h))
        handToPoint(mainPath,(p, p + h))
        handToPoint(mainPath,(p, p))
        
//        mainPath
//        print(mainPath)

        
        UIColor.clear.setFill()
        UIColor.black.setStroke()
        
        let  lPath = UIBezierPath()
        lPath.move(to:CGPoint(x:p, y:p))
        handToPoint(lPath,(p+w,p+h))
        
        
        let  rPath = UIBezierPath()
        rPath.move(to:CGPoint(x:p+w, y:p))
        handToPoint(rPath,(p,p+h))

        mainPath.lineWidth = 2.0
        lPath.lineWidth = 2.0
        rPath.lineWidth = 2.0
        

        mainPath.stroke()
        lPath.stroke()
        rPath.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
        
        
    }
    
    func handToPoint (_ path: UIBezierPath , _ pointTuple: (Int,Int)){
        
        let interval = CGFloat(100)
        
        let (x,y) = pointTuple
        let point = CGPoint(x: x, y: y)
        let currentPoint = path.currentPoint
        
        let count = (ceil(CGPointDistance(point,currentPoint) / interval))
        
    
        let xInterval = (point.x - currentPoint.x) / count
        let yInterval = (point.y - currentPoint.y) / count
        
        
        let s = Scalar(2)
        
        let v = Vector2( Scalar(xInterval) / interval * s, Scalar(yInterval) / interval * s)
        print(v)
        

        
        for i in 1...Int(count){
            
            let preI = CGFloat(i - 1)
            
            let v1 = v.rotated(by: Scalar.pi * Scalar(Float(arc4random() % 100) / 100.0) - Scalar.halfPi )
            let v2 = v.rotated(by: Scalar.pi * Scalar(Float(arc4random() % 100) / 100.0) - Scalar.halfPi)
            print(v1,v2)
            
            
            let p = CGPoint(
                x: currentPoint.x + xInterval * CGFloat( i ),
                y: currentPoint.y + yInterval * CGFloat( i )
            )
            
            let c1 = CGPoint(
                x: currentPoint.x + xInterval * (preI + CGFloat(0.33) ) + v1.x,
                y: currentPoint.y + yInterval * (preI + CGFloat(0.33) ) + v1.y
                
            )
            
            let c2 = CGPoint(
                x: currentPoint.x + xInterval * (preI + CGFloat(0.66) ) + v2.x,
                y: currentPoint.y + yInterval * (preI + CGFloat(0.66) ) + v2.y
                
            )
            
            path.addCurve(
                to: p,
                controlPoint1: c1,
                controlPoint2: c2
            )
        }
        
        
        
    }
    
    func CGPointDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    
    
}


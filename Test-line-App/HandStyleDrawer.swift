//
//  HandSketchDrawer.swift
//  Test-line-App
//
//  Created by Radian on 08/05/2017.
//  Copyright © 2017 Radian. All rights reserved.
//

import UIKit
import CoreGraphics
import Darwin





typealias ScalarP = CGPoint

extension Vector2 {
    static func random ()-> Vector2{
        return Vector2(1,0).rotated(
            by: Scalar.twoPi * Scalar(Float(arc4random() % 100) / 100.0)
        )
    }
    func toPoint () -> ScalarP {
        return ScalarP (x: self.x , y:self.y)
    }
}

extension CGPoint {

    init (_ x:CGFloat , _ y:CGFloat){
        self.x = x
        self.y = y
    }
    
    func dist (_ target : CGPoint)-> CGFloat{
        let a = self
        let b = target
        
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }

    var vector : Vector2 {
        return Vector2(self.x ,self.y)
    }
}




class UIHandBezierPath : UIBezierPath {
    
    var style : Style
    override init (){
        self.style = Style()
        super.init()
        
    }
    
    func addLine(_ tuple:(CGFloat,CGFloat)) {
        self.addLine(to: CGPoint(x :tuple.0 , y :tuple.1))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func start (_ to:CGPoint){
        self.move(to:to)
        
    }

    func lineTo (_ pointTuple: (CGFloat,CGFloat)){
        let p = pointTuple
        lineTo( CGPoint(x:p.0,y:p.1))
    }
    func lineTo (_ target: CGPoint){
        
        let interval = CGFloat(100)
        
        let currentPoint = self.currentPoint
        
        let count = (ceil(target.dist(currentPoint) / interval))
        
        
        let xInterval = (target.x - currentPoint.x) / count
        let yInterval = (target.y - currentPoint.y) / count
        
        
        let s = Scalar(3)
        
        //        let v = Vector2( Scalar(xInterval) / interval * s, Scalar(yInterval) / interval * s)
        let v = Vector2( xInterval , yInterval).normalized() * s
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
            
            self.addCurve(
                to: p,
                controlPoint1: c1,
                controlPoint2: c2
            )
        }
    }
    
    
    
    enum ArcType {
        case Quater , Half
    }
    
    func arcTo (
        _ toP : CGPoint = CGPoint(x:0,y:0) ,
        _ arcType : ArcType = .Quater
    ){
        switch(arcType){
        case .Half :
            
            let from = self.currentPoint.vector
            let to = toP.vector
            let sub = to - from
            
            let middlePoint = from + (sub.rotated(by: -Scalar.quarterPi) / Scalar(sqrt(2)))
            
            arcTo(middlePoint.toPoint())
            arcTo(toP)
        
            break
        
        case .Quater :
            
            arcTo(toP)
            break
        }
        
    }

    func arcTo (_ toP : CGPoint  ){
        
        
        
        
        let from = self.currentPoint.vector
        let to = toP.vector
        
        let sub = to - from
        
        
        // ㄥ 找到圓心點
        let toCenterV = sub.rotated( by: Scalar.quarterPi) / Scalar(sqrt(2))
        let r = toCenterV.length
        
        
        let controlScale:Scalar = 0.552284749831
        // ref:http://stackoverflow.com/questions/24012511/mathematical-functions-in-swift
        
        let randScale = Scalar(10)
        
        let rand1 = Vector2.random() * randScale
        let rand2 = Vector2.random() * randScale
        
        let c1 = from + toCenterV.rotated(by: -Scalar.halfPi) * controlScale + rand1
        let c2 = to   + toCenterV.rotated(by: -Scalar.pi)     * controlScale + rand2
        
        
        
        self.addCurve(
            to: to.toPoint(),
            controlPoint1: c1.toPoint(),
            controlPoint2: c2.toPoint()
        )
    }
 

    
    enum DashType {
        case Dot , Line , Custom , None
    }
    
    public struct Style {
        var fill : UIColor = UIColor.white
        var stroke : UIColor = UIColor.black
        var weight : CGFloat = 2.0
        var dashT : DashType = .None
        var dashP : [CGFloat] = []
        
        mutating func update (
            fill:UIColor? = nil,
            stroke:UIColor? = nil,
            weight:CGFloat? = nil,
            dashT:DashType? = nil,
            dashP:[CGFloat]? = nil
        ){
            if (fill != nil){ self.fill = fill!}
            if (stroke != nil){ self.stroke = stroke!}
            if (weight != nil){ self.weight = weight!}
            if (dashT != nil){ self.dashT = dashT!}
            if (dashP != nil){ self.dashP = dashP!}
        }
    }
    
    
    
    func draw (){
        
        let s = style
        
        
        
        var v :[CGFloat] = [1,1]
        
        if (s.dashT != .None){
            let dashT = s.dashT

            switch (dashT){
            case .Custom :
                v = s.dashP
            case .Dot :
                v = [10,10]
            case .Line:
                v = [20,10]
            default :
                break
            }
            
            self.setLineDash(&v, count: 2, phase: 0)
            
        }
        
        
        s.fill.setFill()
        self.fill()
        
        s.stroke.setStroke()
        self.lineWidth = s.weight
        self.stroke()
        
        
    }

  
}


struct FrameData {
    let p, w, h, cx, cy : CGFloat
    let px , py , pw , ph : CGFloat // padding
    
    init (_ frame : CGRect ){
        w = frame.size.width
        h = frame.size.height
        p = 5
        cx = w/2
        cy = h/2
        
        px = p
        py = p
        pw = w -  p * 2
        ph = h -  p * 2
    }
}


class BaseSketcher {
    var frame : CGRect
    var paths : [UIHandBezierPath]
    
    init (_ frame : CGRect){
        self.frame = frame
        self.paths = []
    }
    
    
    func render ()-> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(frame.size,false,0.0)
        
        for path in paths {
            path.draw()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    func append(_ otherSketcher : BaseSketcher){
        self.paths.append(contentsOf: otherSketcher.paths)
    }
}


class HandSketcher : BaseSketcher  {
    
    func drawLine (_ frame : CGRect) -> UIHandBezierPath{
        let f = FrameData(frame)
        let y = CGFloat(f.ph) / CGFloat(2.0)
        let from = CGPoint(0 , y )
        let to   = CGPoint(x:CGFloat(f.pw) , y:y)
        
        return drawLine(from,to)
        
        
    }
    
    func drawLine (_ from : CGPoint , _ to : CGPoint) -> UIHandBezierPath{
        
        let path = UIHandBezierPath()
        path.start(from)
        path.lineTo(to)
//        path.close()
        paths.append(path)
        return path
        
    }
    

    func drawCircle (_ frame : CGRect)-> UIHandBezierPath{
        
        let f = FrameData(frame)
        
        
        let leftPoint = Vector2(f.px,f.cy).toPoint()
        let rightPoint = Vector2(f.px + f.pw ,f.cy).toPoint()
        
        let path = UIHandBezierPath()
        path.start( leftPoint)
        path.arcTo(rightPoint, .Half)
        path.arcTo(leftPoint, .Half)
        path.close()
        paths.append(path)
        return path
        
    }
    
    func drawRect (_ frame : CGRect) -> UIHandBezierPath{
        
        let f = FrameData(frame)
        let path = UIHandBezierPath()
        
        path.start(CGPoint(x:f.px, y:f.py))
        path.lineTo((f.px + f.pw, f.py ))
        path.lineTo((f.px + f.pw, f.py + f.ph))
        path.lineTo((f.px, f.py + f.ph))
        path.lineTo((f.px, f.py))
        path.close()
        paths.append(path)
        return path
        
    }

}

class Sketcher : BaseSketcher {
    
    func drawLine (_ from : CGPoint , _ to : CGPoint) -> UIHandBezierPath{
        
        let path = UIHandBezierPath()
        path.move(to:from)
        path.addLine(to: to)
//        path.close()
        
        paths.append(path)
        
        return path
        
        
    }

    func drawLine(_ frame : CGRect)-> UIHandBezierPath{
        let f = FrameData(frame)
        let from = CGPoint(x:0   , y:f.cy )
        let to   = CGPoint(x:f.w , y:f.cy)
        
        return drawLine(from,to)
    }
    
    func drawRect (_ frame : CGRect) -> UIHandBezierPath{
        
        let f = FrameData(frame)
        let path = UIHandBezierPath()
        
        path.start(CGPoint(x:f.px, y:f.py))
        path.addLine((f.px + f.pw, f.py ))
        path.addLine((f.px + f.pw, f.py + f.ph))
        path.addLine((f.px, f.py + f.ph))
        path.addLine((f.px, f.py))
        path.close()
        paths.append(path)
        return path
        
    }
}




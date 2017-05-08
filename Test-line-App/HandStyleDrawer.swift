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
        case .Quater :
            
            let from = self.currentPoint.vector
            let to = toP.vector
            let sub = to - from
            
            let middlePoint = from + (sub.rotated(by: -Scalar.quarterPi) / Scalar(sqrt(2)))
            
            arcTo(middlePoint.toPoint())
            arcTo(toP)
        
            break
        
        case .Half :
            arcTo(toP)
            break
        }
        
    }

    func arcTo (_ toP : CGPoint  ){
        
        
        
        
        let from = self.currentPoint.vector
        let to = toP.vector
        
        var sub = to - from
        
        
        // ㄥ 找到圓心點
        let toCenterV = sub.rotated( by: Scalar.quarterPi) / Scalar(sqrt(2))
        let rCenter = toCenterV + from
        let r = toCenterV.length
        
        
        let controlScale:Scalar = 0.552284749831
        // ref:http://stackoverflow.com/questions/24012511/mathematical-functions-in-swift
        
        let randScale = Scalar(r/10)
        
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
 

    
    
    public struct Style {
        var fill : UIColor
        var stroke : UIColor
        var weight : CGFloat
        
        init (
            _ f:UIColor = UIColor.white ,
            _ s:UIColor = UIColor.black ,
            _ w:CGFloat = 2.0
            ){
            fill = f
            stroke = s
            weight = w
        }
    }
    
    var style : Style?
    
    func style (
        _ fill :UIColor = .white,
        _ stroke : UIColor = .black ,
        _ weight : CGFloat = 2.0
        ){
        self.style = Style(fill,stroke,weight)
    }
    
    func draw (){
        
        if (self.style == nil){
            self.style()
        }
        
        let s = style!
        
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


class HandSketch {
    

    
    static func render (frame : CGRect , paths : [UIHandBezierPath] )-> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(frame.size,false,0.0)
        
        for path in paths {
            path.draw()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    static func drawLine (_ frame : CGRect) -> UIHandBezierPath{
        let f = FrameData(frame)
        let y = CGFloat(f.ph) / CGFloat(2.0)
        let from = CGPoint(0 , y )
        let to   = CGPoint(x:CGFloat(f.pw) , y:y)
        
        return drawLine(from,to)
        
    }
    
    static func drawLine (_ from : CGPoint , _ to : CGPoint) -> UIHandBezierPath{
        
        let path = UIHandBezierPath()
        path.start(from)
        path.lineTo(to)
        path.close()
        return path
        
    }
    

    static func drawCircle (_ frame : CGRect)-> UIHandBezierPath{
        
        let f = FrameData(frame)
        
        
        let leftPoint = Vector2(f.px,f.cy).toPoint()
        let rightPoint = Vector2(f.px + f.pw ,f.cy).toPoint()
        
        let path = UIHandBezierPath()
        path.start( leftPoint)
        path.arcTo(rightPoint, .Half)
        path.arcTo(leftPoint, .Half)
        path.close()
        return path
        
    }
    
    static func drawRect (_ frame : CGRect) -> UIHandBezierPath{
        
        let f = FrameData(frame)
        let path = UIHandBezierPath()
        
        path.start(CGPoint(x:f.px, y:f.py))
        path.lineTo((f.px + f.pw, f.py ))
        path.lineTo((f.px + f.pw, f.py + f.ph))
        path.lineTo((f.px, f.py + f.ph))
        path.lineTo((f.px, f.py))
        path.close()
        
        return path
        
    }
}



class SketchMgr {
    
    let frame : CGRect
    
    private var paths : [UIHandBezierPath]
    
    enum DashType {
        case Dot , Line , Custom
    }
    
    init (_ frame : CGRect){
        self.frame = frame
        self.paths = []
    }
    
    
    
    
    
    func addDash (_ frame : CGRect ,  _ dashType : DashType , _ style : UIHandBezierPath.Style? = nil ) -> UIHandBezierPath {
        
        var s = style ?? UIHandBezierPath.Style()
        
        let f = FrameData (frame)
        
        
        
        var v :[CGFloat] = [1,1]
        
        let path = UIHandBezierPath() ;
        s.weight = f.cy
        
        switch (dashType){
        case .Dot :
            v = [s.weight,s.weight]
        case .Line:
            v = [s.weight * 3,s.weight]
        default :
            break
        }
        
        path.move(to: CGPoint(x:0 , y:f.cy))
        path.addLine(to: CGPoint(x:f.w, y:f.cy))
        path.setLineDash(&v, count: 2, phase: 0)
        path.close()
        path.style = s
        
        paths.append( path )
        return path
        
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
    

}

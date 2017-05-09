//
//  ViewController.swift
//  Test-line-App
//
//  Created by Radian on 04/05/2017.
//  Copyright © 2017 Radian. All rights reserved.
//

import Darwin
import UIKit



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        createOther()
//        createButton()
        
    }

    
    func createOther (){
        let switchView = UISwitch(frame: CGRect(x: 50.0, y: 50.0, width: 300.0, height: 300.0))
        
        let hs = HandSketcher(switchView.frame)
        _ = hs.drawCircle(switchView.frame)

//        switchView.addTarget(self, action: #selector(buttonAction(sender:)), for: .)
        view.addSubview(switchView)
    
    }
    
    
    func createButton() {
        let button = UIButton( type: .custom)
        
        button.frame = CGRect(x: 50.0, y: 50.0, width: 300.0, height: 300.0)
        button.imageView?.contentMode = .scaleAspectFill
        
        
        let hs = HandSketcher(button.frame)
            hs.drawCircle(button.frame).style.update(weight: 2, dashT: .Dot )
            hs.drawLine(button.frame).style.update(weight: 2, dashT: .Dot)
        
        button.setBackgroundImage( hs.render() , for: .normal)
        

        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        view.addSubview(button)
        
        
        
        let button2 = UIButton( type: .custom)
        button2.frame = CGRect(x: 50, y: 450.0, width: 300, height: 30)
//        button2.setTitle("✸", for: .normal)
    
        let s = Sketcher(button2.frame)
        
        _ = s.drawRect(button2.frame).style.update(weight: 2, dashT: .Dot )
        s.drawLine(button2.frame).style.update(weight: 2, dashT: .Dot)
        
        let img = s.render()
    
        button2.setBackgroundImage(img, for: .normal)
        view.addSubview(button2)
        
    
        
    }

    
    @objc func buttonAction(sender: UIButton) {
        print("Button pushed")
    }
  
    
}


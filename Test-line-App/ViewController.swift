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
        createButton()
        
    }

    
    func createOther (){
        let switchView = UISwitch(frame: CGRect(x: 50.0, y: 50.0, width: 300.0, height: 300.0))
        
        

//        switchView.addTarget(self, action: #selector(buttonAction(sender:)), for: .)
        view.addSubview(switchView)
    
    }
    
    
    func createButton() {
        let button = UIButton( type: .custom)
        
        button.frame = CGRect(x: 50.0, y: 50.0, width: 300.0, height: 300.0)
        button.imageView?.contentMode = .scaleAspectFill
        
        let img = HandSketch.render(frame: button.frame, paths: [
            HandSketch.drawRect(button.frame)
        ])
        
        button.setBackgroundImage(img, for: .normal)
        

        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        
        
        
        let button2 = UIButton( type: .custom)
        button2.frame = CGRect(x: 50, y: 450.0, width: 100, height: 10)
        button2.setTitle("✸", for: .normal)
        let s = SketchMgr(button2.frame)
        s.addDash(button2.frame, .Dot)
        
    

        
//        button2.setBackgroundImage(s.render(), for: .normal)
        view.addSubview(button)
        
    
        
    }

    
    @objc func buttonAction(sender: UIButton) {
        print("Button pushed")
    }
  
    
}


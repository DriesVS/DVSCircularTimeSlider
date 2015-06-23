//
//  ViewController.swift
//  DVSCircularTimeSlider
//
//  Created by Dries Van Schevensteen on 19/06/15.
//  Copyright (c) 2015 Dries Van Schevensteen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: DVSCircularTimeSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.addTarget(self, action: "circularTimeSliderValueChanged:", forControlEvents: .ValueChanged)
        
//        slider.primaryCircleColor = UIColor(red: 242/255, green: 94/255, blue: 94/255, alpha: 1.0)
//        slider.primaryCircleStrokeSize = 5
//        slider.primaryCircleHandleRadius = 15
//        slider.shadowCircleColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
//        slider.shadowCircleStrokeSize = 3

//        slider.fontSize = 40
//        slider.fontName = "HelveticaNeue-UltraLight"

        let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let components = NSDateComponents()
        components.hour = 7
        components.minute = 30
        if let date = cal?.dateFromComponents(components) {
            slider.time = date
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func circularTimeSliderValueChanged(slider: DVSCircularTimeSlider) {
        println("Current time: \(slider.timeString)")
    }
    
}

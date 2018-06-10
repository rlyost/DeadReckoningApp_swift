//
//  PaceVC.swift
//  DeadReckoning
//
//  Created by Amandeep Singh on 5/10/18.
//  Copyright © 2018 Echelon Front. All rights reserved.
//

import UIKit
import CoreMotion

class PaceVC: UIViewController {
    
    weak var delegate:PaceItemLableDelegate?
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stepCount: UILabel!
    @IBOutlet weak var distanceTravelled: UILabel!
    
    var pedometer = CMPedometer()
    
    var numberOfSteps:Int! = nil
    var distance:Double! = nil
    var pace:Double! = nil
    
    var timer = Timer()
    var timerInterval = 1.0
    var timeElapsed:TimeInterval = 1.0
    
    @IBAction func startButtonPress(_ sender: UIButton) {
        pedometer = CMPedometer()
        startTimer()
        pedometer.startUpdates(from:Date(), withHandler: {( data, error ) in
            
            if let pedData = data{
                self.numberOfSteps = Int(truncating: data!.numberOfSteps)
                
                if let distance = pedData.distance{
                    self.distance = Double(truncating: distance)
                }
                if #available(iOS 9.0, *) {
                    if let currentPace = pedData.currentPace{
                        self.pace = Double(truncating: currentPace)
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            else {
                self.numberOfSteps = nil
            }
        })
    }
    
    @IBAction func stopButtonPress(_ sender: UIButton) {
        pedometer.stopUpdates()
        stopTimer()
        timerLabel.text = timeIntervalFormat(interval: timeElapsed)
    }
    
    @IBAction func submitPress(_ sender: UIButton) {
        let num = (Double(numberOfSteps) / distance) * 100.0
        delegate?.itemPrint(by: self, with:String(Int(num)) )
    }
    
    func displayData(){
        
        timeElapsed += 1.0
        timerLabel.text =   timeIntervalFormat(interval: timeElapsed)
        
        if let numberOfSteps = self.numberOfSteps{
            stepCount.text = String(format:"%i", numberOfSteps)
        }
        
        if let distance = self.distance{
            distanceTravelled.text = String(format:"%02.02f meters \n %02.02fmi", distance,miles(meters: distance))
        }
        else{
            distanceTravelled.text = "Distance: N/A"
        }
    }
    
    func paceString(title:String,pace:Double) -> String{
        var minPerMile = 0.0
        let factor = 26.8224 //conversion factor
        if pace != 0 {
            minPerMile = factor / pace
        }
        let minutes = Int(minPerMile)
        let seconds = Int(minPerMile * 60) % 60
        return String(format: "%@ %02.2f m/s",title,pace,minutes,seconds)
    }
    
    func miles(meters:Double)-> Double{
        let mile = 0.000621371192
        return meters * mile
    }
    func startTimer(){
        if timer.isValid { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector:#selector(timerAction(timer:)), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        timer.invalidate()
        displayData()
    }
    
    @objc func timerAction(timer:Timer){
        displayData()
    }
    
    func timeIntervalFormat(interval:TimeInterval)-> String{
        var seconds = Int(interval + 0.5) //round up seconds
        let hours = seconds / 3600
        let minutes = (seconds / 60) % 60
        seconds = seconds % 60
        return String(format:"%02i:%02i:%02i",hours,minutes,seconds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

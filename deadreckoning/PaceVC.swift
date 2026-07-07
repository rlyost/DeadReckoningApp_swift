//
//  PaceVC.swift
//  DeadReckoning
//
//  Created by Yost Group LLC on 5/10/18.
//  Copyright © 2018-2026 Yost Group LLC. All rights reserved.
//

import UIKit
import CoreMotion

class PaceVC: UIViewController {
    
    weak var delegate:PaceItemLableDelegate?
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stepCount: UILabel!
    @IBOutlet weak var distanceTravelled: UILabel!
    
    var pedometer = CMPedometer()
    
    var numberOfSteps: Int?
    var distance: Double?
    var pace: Double?

    var timer = Timer()
    var timerInterval = 1.0
    var timeElapsed:TimeInterval = 1.0
    
    @IBAction func startButtonPress(_ sender: UIButton) {
        guard CMPedometer.isStepCountingAvailable() else {
            let alert = UIAlertController(
                title: "Step Counting Unavailable",
                message: "This device can't count steps, so a pace count can't be measured.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        pedometer = CMPedometer()
        startTimer()
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            // Pedometer callbacks arrive off the main thread; hop back before
            // mutating state that the UI timer reads.
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let pedData = data {
                    self.numberOfSteps = Int(truncating: pedData.numberOfSteps)
                    if let distance = pedData.distance {
                        self.distance = Double(truncating: distance)
                    }
                    if let currentPace = pedData.currentPace {
                        self.pace = Double(truncating: currentPace)
                    }
                } else {
                    self.numberOfSteps = nil
                }
            }
        }
    }
    
    @IBAction func stopButtonPress(_ sender: UIButton) {
        pedometer.stopUpdates()
        stopTimer()
        timerLabel.text = timeIntervalFormat(interval: timeElapsed)
    }
    
    @IBAction func submitPress(_ sender: UIButton) {
        guard let steps = numberOfSteps, let distance, distance > 0 else { return }
        let num = (Double(steps) / distance) * 100.0
        delegate?.itemPrint(by: self, with: String(Int(num)))
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Break the Timer's retain of self and stop the pedometer if the
        // user leaves without pressing Stop.
        timer.invalidate()
        pedometer.stopUpdates()
    }
}

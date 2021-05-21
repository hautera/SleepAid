//
//  Timer.swift
//  SleepAid
//
//  Created by Austin Hauter on 5/20/21.
//

import Foundation
import SwiftUI
import AVFoundation

//manages the time remaining, and the timer state
class TimerManager: ObservableObject {
    //accelerometer to measure if the user has shaken the device
    private var accelerationManager: AccelerationManager
    var timer: Timer
    //tracks the current state of the timer
    @Published var state: TimerState
    @Published var secondsRemaining: Int
    
    init() {
        self.accelerationManager = AccelerationManager()
        self.timer = Timer()
        self.state = .initial
        self.secondsRemaining = 0
        
    }
    
    //handles the press of the main button
    func buttonPress(userSelection: NapTimes) {
        // pauses the timer if it is running
        if self.state == .running {
            //we set state to prePause so the manager has time to stop the timer
            self.state = .prePause
        } else if self.state == .prePause {
            //do nothing until the timer can be stopped
            return
        } else {
            //only other case is the user wants the timer to run 
            self.start(userSelection: userSelection)
        }
        
        
    }
    
    //returns a string format of the minutes remaining
    //for the UI
    func minutesRemainingAsText() -> String {
        let hours: Int = self.secondsRemaining / 3600
        let minutes: Int = (self.secondsRemaining / 60)  % 60
        let seconds: Int = self.secondsRemaining % 60
        let hString = "\(hours)"
        let mSting = minutes >= 10 ? ":\(minutes)" : ":0\(minutes)"
        let sString = seconds >= 10 ? ":\(seconds)" : ":0\(seconds)"
        
        return hString + mSting + sString
    }
    
    //starts the countdown
    func start(userSelection: NapTimes) {
        //set minutes remaining IF That there state is initial :)
        if self.state == .initial {
            self.secondsRemaining = userSelection.rawValue * 60 //comment out 60 for testing/debugging
        }
        
        //change the timer's state
        self.state = .running
        
        //set timer
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { t in
            //stop the timer if the user has paused it
            if self.state == .prePause {
                t.invalidate()
                self.state = .paused
            }
            
            self.secondsRemaining -= 1
            
            if self.secondsRemaining == 0 {
                t.invalidate()
                self.stop()
            }
        })
    }
    
    
    
    //resets the the timer to the initial state
    func reset() {
        self.state = .initial
    }
    
    //stops the timer
    func stop() {
        //make sure we aren't reading the state from a previous alarm
        self.accelerationManager.reset()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: {t in
            AudioServicesPlayAlertSound(1005)
            
            if self.accelerationManager.accelerationThreshold {
                t.invalidate()
                self.reset()
            }
        })
    }
}


//Tracks the current state of the timer
enum TimerState {
    case running
    case paused
    //prepause catches an error in which the timer does not stop before the
    //the timer does not stop before the ui is updated
    case prePause
    case initial
    
    var pictureName : String {
        switch self {
        case .running:
            return "pause.circle.fill"
        case .paused:
            return "play.circle.fill"
        case .prePause:
            return "play.circle.fill"
        case .initial:
            return "play.circle.fill"
        }
    }
}

//Possible times the user can set the timer
enum NapTimes: Int, CaseIterable, Identifiable {
    //these names are not intuitive, perhaps they should be changed
    //thirty minute nap
    case short = 30
    //hour nap
    case medium = 60
    //four hour nap
    case long = 240
    //eight hour nap
    case extraLong = 480
    
    var id: Int { self.rawValue }
    
    var readable: String {
        //covers all cases except 30 minutes
        if self.rawValue % 60 == 0 {
            let numHours = self.rawValue / 60
            //we want to not have plural if there is only one hour
            if numHours == 1 {
                return "1 hour"
            }
            
            return "\(numHours) hours"
        }
        
        //edge case :)
        return "30 minutes"
    }
}

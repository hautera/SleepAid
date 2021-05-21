//
//  AccelerationManager.swift
//  SleepAid
//
//  Created by Austin Hauter on 5/20/21.
//

import Foundation
import CoreMotion

class AccelerationManager: ObservableObject {
    private var manager: CMMotionManager
    private var listening: Bool = false
    
    
    @Published
    var accelerationThreshold: Bool = false
    
    init() {
        self.manager = CMMotionManager()
        
        self.manager.accelerometerUpdateInterval = 1/60
        self.manager.startAccelerometerUpdates(to: .main) {
            (accelerometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let acc = accelerometerData?.acceleration {
                let x = acc.x
                let y = acc.y
                let z = acc.z
                
                //check if magnitude exceeds threshold
                if self.magnitude(x: x, y: y, z: z) > 10 {
                    self.accelerationThreshold = true
                }
            }
            
        }
    }
    
    func reset() {
        self.accelerationThreshold = false
    }
    
    func magnitude(x: Double, y: Double, z: Double) -> Double {
        return pow(x,2) + pow(y,2) + pow(z,2)
    }
}

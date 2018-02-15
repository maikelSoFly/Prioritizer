//
//  RocketManager.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 13/02/2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

class RocketManager {
    private var rockets:Dictionary<String, Rocket>
    
    init() {
        self.rockets = Dictionary<String, Rocket>()
    }
    
    func getRocketWithTask(_ task:Task) -> Rocket? {
        if let rocket = rockets[task.uuid] {
            return rocket
        }
        return nil
    }
    
    func addRocket(key:String, rocket:Rocket) {
        rockets[key] = rocket
    }
    
    func removeRocket(_ key:String) {
        if let index = rockets.index(forKey: key) {
            rockets.remove(at: index)
            rockets[key] = nil
            print("Rocket of key \(key) removed")
        }
    }
    
}

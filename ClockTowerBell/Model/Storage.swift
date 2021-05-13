//
//  Storage.swift
//  ClockTowerBell
//
//  Created by mona zheng on 5/13/21.
//

import Foundation

struct Storage {
    let storedData = UserDefaults.standard
    
    func checkIsStatePreviouslySaved(key:String)->Bool{
        // check if keys are present
        return storedData.object(forKey: key) != nil
    }
    
    func saveState(key:String, bellValue:Int?, onOffValue2:Bool? ){
        storedData.set(bellValue, forKey: key)
    }
    
    
}

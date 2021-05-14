//
//  Bell.swift
//  ClockTowerBell
//
//  Created by mona zheng on 5/13/21.
//

import UIKit

struct Tower {
    let amOrPm = ["AM", "PM"]
    let hour = [1,2,3,4,5,6,7,8,9,10,11,12]
    
    // default time used is 11am to 11pm
    var firstBellTime = 11
    var firstBellAmOrPmIndexPlusOne = 1
    var lastBellTime = 11
    var lastBellAmOrPmIndexPlusOne = 2
    
    func updateTextField(textField: UITextField, bell:String){
        if bell == "first" {
            textField.text = "\(firstBellTime) \(amOrPm[firstBellAmOrPmIndexPlusOne-1])"
        } else if bell == "last" {
            textField.text = "\(lastBellTime) \(amOrPm[lastBellAmOrPmIndexPlusOne-1])"
        }
        
    }
    
    mutating func checkForRollOverBellTimes()->Bool{
        let tempLastBellTime = getMilitaryTime(bell: "last")
        let tempFirstBellTime = getMilitaryTime(bell: "first")
        if tempFirstBellTime > tempLastBellTime {
            return true
        }
        return false
    }
    
    func getMilitaryTime(bell:String)->Int{
        // differentiate midnight and noon
        let normalTime:Int
        let index: Int
        if bell == "first" {
            normalTime = firstBellTime
            index = firstBellAmOrPmIndexPlusOne
        } else {
            normalTime = lastBellTime
            index = lastBellAmOrPmIndexPlusOne
        }
        
        if normalTime == 12 {
            if index == 1 {
                return 0   // midnight
            }
            
            if index == 2 {
                return 12 // for noon
            }
        }
        return (index == 2) ? normalTime + 12 : normalTime
    }
}

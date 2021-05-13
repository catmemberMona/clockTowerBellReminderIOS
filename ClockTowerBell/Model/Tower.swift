//
//  Bell.swift
//  ClockTowerBell
//
//  Created by mona zheng on 5/13/21.
//

import Foundation

struct Tower {
    let amOrPm = ["AM", "PM"]
    let hour = [1,2,3,4,5,6,7,8,9,10,11,12]
    
    // default time used is 11am to 11pm
    var firstBellTime = 11
    var firstBellAmOrPmIndexPlusOne = 1
    var lastBellTime = 11
    var lastBellAmOrPmIndexPlusOne = 2
    var isRollOverBells = false
    
    
    
}

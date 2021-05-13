//
//  OnOffButtons.swift
//  ClockTowerBell
//
//  Created by mona zheng on 5/13/21.
//
import Foundation
import UIKit

struct OnOffButton {
    let storedData = UserDefaults.standard
    let button : UIButton
    let customYellow : UIColor
    let customBlue: UIColor
    
    init(button:UIButton, customYellow:UIColor, customBlue:UIColor){
        
        self.button = button
        self.customYellow = customYellow
        self.customBlue = customBlue
    }
   
    
    func onOffState()->Bool{
        return storedData.bool(forKey: "buttonState")
    }
    
    func setButtonUIView(){
        if !isKeyPresentInUserDefaults(key: "buttonState") {
            storedData.set(false, forKey: "buttonState")
            button.setTitle("Turn On", for: .normal)
        } else if onOffState() == true {
            showOn()
        } else if onOffState() == false {
            showOff()
        }
    }
    
    func updateButtonUIViewAndState(){
        storedData.bool(forKey: "buttonState")
        
        if onOffState() == false {
            isRollOverBells = checkForRollOverBellTimes()
            determineIfSettingRollOverBells()
            DispatchQueue.main.async {
                self.showOn();
            }
        } else {
            turnOffReminder();
            DispatchQueue.main.async {
                self.showOff();
            }
        }
        storedData.set(!onOffState(), forKey: "buttonState")
    }
    
    // show the UI corresponding to the state of the notifications
    func showOn(){
        button.backgroundColor = customYellow;
        button.setTitleColor(customBlue, for: .normal)
        button.setTitle("Turn Off", for: .normal)
    }
    
    func showOff(){
        button.backgroundColor = customBlue;
        button.setTitleColor(customYellow, for: .normal)
        button.setTitle("Turn On", for: .normal)
    }
    
    
    
    // FUNCTIONS FOR USERDEFAULTS
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return storedData.object(forKey: key) != nil
    }
    
    
    
    
}

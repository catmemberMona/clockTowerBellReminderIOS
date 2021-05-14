//
//  OnOffButtons.swift
//  ClockTowerBell
//
//  Created by mona zheng on 5/13/21.
//
import Foundation
import UIKit

struct OnOffButton {
    let customYellow = UIColor.init(red: 255/255, green: 236/255, blue: 149/255, alpha: 1.0)
    let customBlue = UIColor.init(red: 12/255, green: 18/255, blue: 31/255, alpha: 0.95)
    
    let storedData = UserDefaults.standard
    let button : UIButton
    
    init(button:UIButton){
        self.button = button
        
        // retrieve saved on/off state when app is reopened,
        // or save new state which starts out false if it is the first time app is being used
        setInitialButtonUIView()
        setButtonUIView()
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
    
    // FUNCTION FOR USERDEFAULTS
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return storedData.object(forKey: key) != nil
    }
    
    func setInitialButtonUIView(){
        DispatchQueue.main.async {
            button.layer.cornerRadius = button.frame.size.width / 2
            button.layer.masksToBounds = true
            button.layer.borderWidth = 5
            button.layer.borderColor = customYellow.cgColor
        }
    }
}

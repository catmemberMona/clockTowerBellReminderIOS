//
//  OnOffButtonStyling.swift
//  ClockTowerBell
//
//  Created by mona zheng on 5/13/21.
//

import Foundation
import UIKit

struct OnOffButtonStyling {
    let button : UIButton
    let customYellow : UIColor
    let customBlue: UIColor
    
    init(button:UIButton, customYellow:UIColor, customBlue:UIColor){
        
        self.button = button
        self.customYellow = customYellow
        self.customBlue = customBlue
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

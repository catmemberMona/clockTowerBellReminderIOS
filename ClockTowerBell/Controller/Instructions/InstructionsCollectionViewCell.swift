//
//  InstructionsCollectionViewCell.swift
//  ClockTowerBell
//
//  Created by mona zheng on 5/15/21.
//

import UIKit

class InstructionsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: InstructionsCollectionViewCell.self)
    
    @IBOutlet weak var slideImage: UIImageView!
    
    func setup(instruction: Instruction){
        slideImage.image = UIImage(named: instruction.image)
        
    }
}

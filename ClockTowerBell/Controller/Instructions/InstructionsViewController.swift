//
//  InstructionsViewController.swift
//  ClockTowerBell
//
//  Created by mona zheng on 5/14/21.
//

import UIKit

class InstructionsViewController: UIViewController {
    
   

    @IBOutlet weak var cvInstructions: UICollectionView!
    
    var instructions: [Instruction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cvInstructions.delegate = self
        cvInstructions.dataSource = self
        
        instructions = [Instruction(title: "Step1", image: "dailyBellsInstructions1"), Instruction(title: "Step1.1", image: "dailyBellsInstructions2"), Instruction(title: "Step2", image: "turnOnInstruction")]
        
        
    }
    
    @IBAction func buDone(_ sender: Any) {
        
    }
    
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InstructionsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        instructions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InstructionsCollectionViewCell.identifier, for: indexPath) as! InstructionsCollectionViewCell
        
        cell.setup(instruction: instructions[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
}

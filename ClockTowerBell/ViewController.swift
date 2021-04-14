//
//  ViewController.swift
//  ClockTowerBell
//
//  Created by mona zheng on 4/8/21.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var buONOFFBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        buONOFFBTN.setTitle("Turn On", for: .normal)
        // styling for on/off Button
        buONOFFBTN.layer.cornerRadius = 15
        buONOFFBTN.layer.borderWidth = 1.5
        buONOFFBTN.layer.borderColor = UIColor.clear.cgColor
        
      
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // ACTION FOR WHEN THE BUTTON IS PRESSED
    var buttonStatus = false;
    @IBAction func buOnOffBtn(_ sender: UIButton) {
        let yellowColor = UIColor.init(red: 255/255, green: 236/255, blue: 149/255, alpha: 1.0);
        let blueColor = UIColor.init(red: 40/255, green: 74/255, blue: 119/255, alpha: 1.0);
        // request permission to send notifications and alert
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: {success, error in
            if success {
                // set notifications or remove notifications
                if self.buttonStatus == false {
                    self.turnOnAlarm();
                    DispatchQueue.main.async {
                        sender.backgroundColor = yellowColor;
                        sender.setTitleColor(blueColor, for: .normal)
                        sender.setTitle("Turn Off", for: .normal)
                    }
                } else {
                    self.turnOffReminder();
                    DispatchQueue.main.async {
                        sender.backgroundColor = blueColor;
                        sender.setTitleColor(yellowColor, for: .normal)
                        sender.setTitle("Turn On", for: .normal)
                    }
                }
                self.buttonStatus = !self.buttonStatus;
                print(self.buttonStatus)
                
            } else if error != nil {
                print("there is an error")
            }
        })
    }
    
    func turnOnAlarm(){
        // set reminder for every hour during the day from 11am to 11pm
        for i in 1...59 {
            // set the time
            var date = DateComponents();
            date.minute = i;
//            print("THE DATE Hour: ", date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            
            // set content the notification will display
            let content = UNMutableNotificationContent()
            content.title = "\(i % 12) O'clock"
            // custom sound
            let soundName = UNNotificationSoundName("clock-bell-one.wav");
            content.sound = UNNotificationSound(named: soundName)
            
            // request takes in content to display notification and trigger requirement
            // id needed to turn off alarm?
            let request = UNNotificationRequest(identifier: "id_for_alarm_at_\(i)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error != nil {
                    print("SOMETHING WENT WRONG WITH NOTIFICATION REQUEST")
                } else {
//                    print("THIS WAS SUCCESSFUL, Notified at \(i % 12)")
                }
            })
        }
    }
    
    func turnOffReminder(){
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
}

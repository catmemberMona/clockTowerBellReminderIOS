//
//  ViewController.swift
//  ClockTowerBell
//
//  Created by mona zheng on 4/8/21.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // VARIABLES FOR SET ON/OFF Button
    @IBOutlet weak var buONOFFBTN: UIButton!
    let yellowColor = UIColor.init(red: 255/255, green: 236/255, blue: 149/255, alpha: 1.0);
    let blueColor = UIColor.init(red: 40/255, green: 74/255, blue: 119/255, alpha: 1.0);
    
    // VARIBALES FOR SETTING THE DAILY START AND END TIMES
    var timePicker = UIPickerView()
    @IBOutlet weak var firstBellText: UITextField!
    @IBOutlet weak var lastBellText: UITextField!
    var activeField: UITextField?
    let amOrPm = ["AM", "PM"]
    let hour = [1,2,3,4,5,6,7,8,9,10,11,12]
    // Hour saved
    var hourTime = 11
    var timeOfDay = ""
    // first and last hour saved
    // default time used is 11am to 11pm
    var firstBellMilitaryTime = 11
    var lastBellMilitaryTime = 23
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set up for the daily start and end time picker view
        // set VC as textfield's delegate
        firstBellText.delegate = self
        lastBellText.delegate = self
        // set VC as picker view delegate
        timePicker.delegate = self
        timePicker.dataSource = self
        
        // set default for daily start / end time
        if firstBellText.text == "" {
            firstBellText.text = "11 AM"
        }
        if lastBellText.text == "" {
            lastBellText.text = "11 PM"
        }
        
        
        
        // retrieve on/off state when app is reopened,
        // starts out false if it is the first time app is being used
        let defaults = UserDefaults.standard
        let buttonStatus = defaults.bool(forKey: "buttonState")
        if buttonStatus != false && buttonStatus != true {
            defaults.set(false, forKey: "buttonState")
            buONOFFBTN.setTitle("Turn On", for: .normal)
        } else if buttonStatus == true {
            showOn(btn:buONOFFBTN)
        } else if buttonStatus == false {
            showOff(btn: buONOFFBTN)
        }
        
        // styling for on/off Button
        buONOFFBTN.layer.cornerRadius = 15
        buONOFFBTN.layer.borderWidth = 1.5
        buONOFFBTN.layer.borderColor = UIColor.clear.cgColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // ACTION FOR WHEN THE BUTTON IS PRESSED
    @IBAction func buOnOffBtn(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        let buttonState = defaults.bool(forKey: "buttonState")
        
        // request permission to send notifications and alert
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: {success, error in
            if success {
                // set notifications or remove notifications
                // show corresponding UI
                if buttonState == false {
                    self.turnOnAlarm();
                    DispatchQueue.main.async {
                        self.showOn(btn:sender);
                    }
                } else {
                    self.turnOffReminder();
                    DispatchQueue.main.async {
                        self.showOff(btn:sender);
                    }
                }
                defaults.set(!buttonState, forKey: "buttonState")
                print(defaults.bool(forKey: "buttonState"))
                
            } else if error != nil {
                print("there is an error")
            }
        })
    }
    
    // show the UI corresponding to the state of the notifications
    func showOn(btn:UIButton){
        btn.backgroundColor = self.yellowColor;
        btn.setTitleColor(blueColor, for: .normal)
        btn.setTitle("Turn Off", for: .normal)
    }
    
    func showOff(btn:UIButton){
        btn.backgroundColor = blueColor;
        btn.setTitleColor(yellowColor, for: .normal)
        btn.setTitle("Turn On", for: .normal)
    }
        
    func turnOnAlarm(){
        // set reminder for every hour during the day from 11am to 11pm
        for i in firstBellMilitaryTime...lastBellMilitaryTime {
            // set the time
            var date = DateComponents();
            date.hour = i;
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            
            // set content the notification will display
            let content = UNMutableNotificationContent()
            let time = i % 12 == 0 ? 12 : i % 12
            content.title = "It is \(time) O'clock"
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
                    print("THIS WAS SUCCESSFUL, Notified at \(time)")
                }
            })
        }
    }
    
    func turnOffReminder(){
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    
    // SET DAILY START AND END TIME
    func createTimePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        activeField?.inputAccessoryView = toolbar
        activeField?.inputView = timePicker
        
    }

    @objc func donePressed(){
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12
        } else {
            return 2
        }
    }
    

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(hour[row])
        } else {
            return amOrPm[row]
        }
    }
    
    // show bell times and edit the textfield that was selected
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        createTimePicker()
        return true
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            hourTime = hour[row]
        }
        if component == 1 {
            timeOfDay = amOrPm[row]
        }
        let time = hourTime % 12 == 0 ? 12 : hourTime % 12
        activeField?.text = "\(String(time)) " + timeOfDay
        
        // adjust time to military time
        if timeOfDay == "PM" {
            hourTime = hourTime + 12
        }
        
        // Update start and/or end bell times
        if activeField?.accessibilityIdentifier == "firstBellTextField" {
            firstBellMilitaryTime = hourTime
        } else {
            lastBellMilitaryTime = hourTime
        }
        
    }
}

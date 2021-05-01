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
    @IBOutlet weak var dailyBellMessage: UILabel!
    @IBOutlet weak var firstBellText: UITextField!
    @IBOutlet weak var lastBellText: UITextField!
    var activeField: UITextField?
    let amOrPm = ["AM", "PM"]
    let hour = [1,2,3,4,5,6,7,8,9,10,11,12]

    // first and last hour saved
    // default time used is 11am to 11pm
    var firstBellTime = 11
    var firstBellAmOrPmIndexPlusOne = 1
    var lastBellTime = 11
    var lastBellAmOrPmIndexPlusOne = 2
    
    var isRollOverBells = false
    var removeAllSavedDefaults = !true
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // save data
        let defaults = UserDefaults.standard
        
        // Set up for the daily start and end time picker view
        // set VC as textfield's delegate
        firstBellText.delegate = self
        lastBellText.delegate = self
        // set VC as picker view delegate
        timePicker.delegate = self
        timePicker.dataSource = self
        
        // Reset default keys
        if removeAllSavedDefaults {
           removeAllDefaultKeys()
        }
        
        // retrieve first and last bell times when app is reopened,
        // starts out as 11am and 11pm if it is the first time app is being used
        // check if keys are present
        if isKeyPresentInUserDefaults(key: "firstBellHour") {
            self.firstBellTime = defaults.integer(forKey: "firstBellHour")
        } else {
            defaults.set(firstBellTime, forKey: "firstBellHour")
        }
        
        if isKeyPresentInUserDefaults(key: "firstBellAmOrPm") {
            self.firstBellAmOrPmIndexPlusOne = defaults.integer(forKey: "firstBellAmOrPm")
        } else {
            defaults.set(firstBellAmOrPmIndexPlusOne, forKey: "firstBellAmOrPm")
        }
        
        if isKeyPresentInUserDefaults(key: "lastBellHour") {
            self.lastBellTime = defaults.integer(forKey: "lastBellHour")
        } else {
            defaults.set(lastBellTime, forKey: "lastBellHour")
        }
        
        if isKeyPresentInUserDefaults(key: "lastBellAmOrPm") {
            self.lastBellAmOrPmIndexPlusOne = defaults.integer(forKey: "lastBellAmOrPm")
        } else {
            defaults.set(lastBellAmOrPmIndexPlusOne, forKey: "lastBellAmOrPm")
        }
        
        print("INDEX FOR FIRST:", firstBellAmOrPmIndexPlusOne )
        print("INDEX FOR LAST:", lastBellAmOrPmIndexPlusOne )
        
        
        
        // set default for daily start / end time
        if firstBellText.text == "" {
            firstBellText.text = "\(firstBellTime) \(amOrPm[firstBellAmOrPmIndexPlusOne-1])"
        }
        if lastBellText.text == "" {
            lastBellText.text = "\(lastBellTime) \(amOrPm[lastBellAmOrPmIndexPlusOne-1])"
        }
        
        
        
        // retrieve on/off state when app is reopened,
        // starts out false if it is the first time app is being used
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
    
    // FUNCTIONS FOR USERDEFAULTS
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func removeAllDefaultKeys(){
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
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
                    self.determineIfSettingRollOverBells()
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
//                print(defaults.bool(forKey: "buttonState"))
                
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
        
    func turnOnAlarm(tempFirstBellTime:Int, tempLastBellTime:Int){
        // set reminder for every hour during the day from 11am to 11pm
        for i in tempFirstBellTime...tempLastBellTime { // max range would be 0 - 23
            // set the time
            var date = DateComponents();
            date.hour = i;
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            
            // set content the notification will display
            let content = UNMutableNotificationContent()
            let time = i
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
                    print("THIS WAS SUCCESSFUL, Notified at military hour \(time)")
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
    
    // show bell times
    // edit the textfield that was selected using
    // the picker view
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        activeField = textField
       
        if activeField?.accessibilityIdentifier == "firstBellTextField" {
       
            let timeIndex = firstBellTime-1
            timePicker.selectRow(timeIndex, inComponent: 0, animated: true)
            timePicker.selectRow(firstBellAmOrPmIndexPlusOne-1, inComponent: 1, animated: true)
        } else {
    
            let timeIndex = lastBellTime-1
            timePicker.selectRow(timeIndex, inComponent: 0, animated: true)
            timePicker.selectRow(lastBellAmOrPmIndexPlusOne-1, inComponent: 1, animated: true)
        }
        
        createTimePicker()
        return true
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var time:Int?
        let defaults = UserDefaults.standard
        
        // Update start and/or end bell times and
        // update active text field
        if activeField?.accessibilityIdentifier == "firstBellTextField" {
            if component == 0 {
                firstBellTime = hour[row]
                time = firstBellTime % 12 == 0 ? 12 : firstBellTime % 12
            }
            if component == 1 {
                firstBellAmOrPmIndexPlusOne = row + 1
                time = firstBellTime
            }
            activeField?.text = "\(String(time!)) " + amOrPm[firstBellAmOrPmIndexPlusOne-1]
        } else {
            if component == 0 {
                lastBellTime = hour[row]
                time = lastBellTime % 12 == 0 ? 12 : lastBellTime % 12
            }
            if component == 1 {
                lastBellAmOrPmIndexPlusOne = row + 1
                time = lastBellTime
            }
            activeField?.text = "\(String(time!)) " + amOrPm[lastBellAmOrPmIndexPlusOne-1]
        }
        
        // check if the bell times set is vaild
        isRollOverBells = checkForRollOverBellTimes()
        determineIfSettingRollOverBells()
        
        // update saved time for when user reopens closed app
        if activeField?.accessibilityIdentifier == "firstBellTextField" {
            if component == 0 {
                defaults.set(firstBellTime, forKey: "firstBellHour")
            }
            if component == 1 {
                defaults.set(firstBellAmOrPmIndexPlusOne, forKey: "firstBellAmOrPm")
            }
             
            dailyBellMessage.text = amOrPm[firstBellAmOrPmIndexPlusOne-1]
            
        } else if activeField?.accessibilityIdentifier == "lastBellTextField" {
            component == 0 ?
                defaults.set(lastBellTime, forKey: "lastBellHour") :
                defaults.set(lastBellAmOrPmIndexPlusOne, forKey: "lastBellAmOrPm")
        }
    }
    
    func determineIfSettingRollOverBells(){
        turnOffReminder()
        let tempLastMilitaryTime = getMilitaryTime(normalTime: lastBellTime, index: lastBellAmOrPmIndexPlusOne)
        let tempFirstMilitaryTime = getMilitaryTime(normalTime: firstBellTime, index: firstBellAmOrPmIndexPlusOne)
        if !isRollOverBells {
            turnOnAlarm(tempFirstBellTime: tempFirstMilitaryTime, tempLastBellTime: tempLastMilitaryTime)
        } else {
            turnOnAlarm(tempFirstBellTime: tempFirstMilitaryTime, tempLastBellTime: 23)
            turnOnAlarm(tempFirstBellTime: 0, tempLastBellTime: tempLastMilitaryTime)
        }
        
    }
    
    func checkForRollOverBellTimes()->Bool{
        let tempLastBellTime = getMilitaryTime(normalTime: lastBellTime, index: lastBellAmOrPmIndexPlusOne)
        let tempFirstBellTime = getMilitaryTime(normalTime: firstBellTime, index: firstBellAmOrPmIndexPlusOne)
        if tempFirstBellTime > tempLastBellTime {
            return true
        }
        return false
    }
    
    func getMilitaryTime(normalTime:Int, index:Int)->Int{
        // differentiate midnight and noon
        print("THIS IS THE INDEX IN GET MILITARY TIME:", index)
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

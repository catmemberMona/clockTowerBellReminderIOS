//
//  ViewController.swift
//  ClockTowerBell
//
//  Created by mona zheng on 4/8/21.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // Outlet variables
    @IBOutlet weak var buONOFFBTN: UIButton!
    @IBOutlet weak var dailyBellMessage: UILabel!
    @IBOutlet weak var firstBellText: UITextField!
    @IBOutlet weak var lastBellText: UITextField!
    
    // Input variables
    var timePicker = UIPickerView()
    var activeField: UITextField?
    
    //    var removeAllSavedDefaults = !true
    
    // Defining Struct Objects
    var onOffButton:OnOffButton!
    var storage:Storage!
    var tower = Tower()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // save data
        storage = Storage()
        
        // Set up for the daily start and end time picker view
        // set VC as textfield's delegate
        firstBellText.delegate = self
        lastBellText.delegate = self
        // set VC as picker view delegate
        timePicker.delegate = self
        timePicker.dataSource = self
        
        //Reset default keys
//        if removeAllSavedDefaults {
//           removeAllDefaultKeys()
//        }
        
        // check if keys are present
        // retrieve first and last bell times when app is reopened, or
        // starts first and last bell times as 11am and 11pm if it is the first time app is being used
        if storage.checkIsStatePreviouslySaved(key: "firstBellHour") {
            tower.firstBellTime = storage.storedData.integer(forKey: "firstBellHour")
        } else {
            storage.storedData.set(tower.firstBellTime, forKey: "firstBellHour")
        }
        
        if storage.checkIsStatePreviouslySaved(key: "firstBellAmOrPm") {
            tower.firstBellAmOrPmIndexPlusOne = storage.storedData.integer(forKey: "firstBellAmOrPm")
        } else {
            storage.storedData.set(tower.firstBellAmOrPmIndexPlusOne, forKey: "firstBellAmOrPm")
        }
        
        if storage.checkIsStatePreviouslySaved(key: "lastBellHour") {
            tower.lastBellTime = storage.storedData.integer(forKey: "lastBellHour")
        } else {
            storage.storedData.set(tower.lastBellTime, forKey: "lastBellHour")
        }
        
        if storage.checkIsStatePreviouslySaved(key: "lastBellAmOrPm") {
            tower.lastBellAmOrPmIndexPlusOne = storage.storedData.integer(forKey: "lastBellAmOrPm")
        } else {
            storage.storedData.set(tower.lastBellAmOrPmIndexPlusOne, forKey: "lastBellAmOrPm")
        }
        
        // set default for daily start / end time
        if firstBellText.text == "" {
            tower.updateTextField(textField: firstBellText, bell: "first")
        }
        if lastBellText.text == "" {
            tower.updateTextField(textField: lastBellText, bell: "last")
        }
        
        // retrieve saved on/off state when app is reopened,
        // or save new state which starts out false if it is the first time app is being used
        onOffButton = OnOffButton(button: buONOFFBTN)
        onOffButton.setInitialButtonUIView()
        onOffButton.setButtonUIView()
    
        
    }
    
    // screen
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    //    func removeAllDefaultKeys(){
    //        let domain = Bundle.main.bundleIdentifier!
    //        UserDefaults.standard.removePersistentDomain(forName: domain)
    //        UserDefaults.standard.synchronize()
    //        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
    //    }
    
    
    
    // Action function
    @IBAction func buOnOffBtn(_ sender: UIButton) {
        // request permission to send notifications and alert
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: {success, error in
            if success {
                // set notifications or remove notifications
                // show corresponding UI
                self.updateButtonUIViewAndState()
                
            } else if error != nil {
                print("there is an error")
            }
        })
        
        // SHOW ALERT IF USER DOES NOT ALLOW PERMISSION FOR PUSH NOTIFICATION
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {setting in
            switch setting.authorizationStatus {
            case .authorized:
                print("User gave permisson")
            case .denied:
                print("User denied permissions")
                DispatchQueue.main.async {
                    self.showAlertForNeedingPermission()
                }
            case .notDetermined:
                print("User has not been asked yet for permission")
            case .provisional:
                print("User gave permisson")
            case .ephemeral:
                print("User gave permisson")
            @unknown default:
                print("There is an error with notification permissions")
            }
        })
    }
    
    func showAlertForNeedingPermission(){
        let alert = UIAlertController(title: "Unable to use notifications",
                                      message: "To enable notifications, go to Settings and enable notifications for this app.",
                                      preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            // Take the user to Settings app to possibly change permission.
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // Finished opening URL
                })
            }
        })
        alert.addAction(settingsAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateButtonUIViewAndState(){
        storage.storedData.bool(forKey: "buttonState")
        
        if onOffButton.onOffState() == false {
            determineIfFirstMilitaryTimeIsLargerOrSmaller()
            DispatchQueue.main.async {
                self.onOffButton.showOn();
            }
        } else {
            turnOffReminder();
            DispatchQueue.main.async {
                self.onOffButton.showOff();
            }
        }
        storage.storedData.set(!onOffButton.onOffState(), forKey: "buttonState")
    }
    
    
    
    func turnOnAlarm(tempFirstBellTime:Int, tempLastBellTime:Int){
        // set reminder for every hour during the day from 11am to 11pm
        if tempFirstBellTime <= tempLastBellTime {
                for i in tempFirstBellTime...tempLastBellTime { // max range would be 0 - 23
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
                            print("THIS WAS SUCCESSFUL, Notified at military hour \(time)")
                        }
                    })
                }
       
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
            return String(tower.hour[row])
        } else {
            return tower.amOrPm[row]
        }
    }
    
    // show bell times
    // edit the textfield that was selected using
    // the picker view
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        activeField = textField
        
        if activeField?.accessibilityIdentifier == "firstBellTextField" {
            
            let timeIndex = tower.firstBellTime-1
            timePicker.selectRow(timeIndex, inComponent: 0, animated: true)
            timePicker.selectRow(tower.firstBellAmOrPmIndexPlusOne-1, inComponent: 1, animated: true)
        } else {
            
            let timeIndex = tower.lastBellTime-1
            timePicker.selectRow(timeIndex, inComponent: 0, animated: true)
            timePicker.selectRow(tower.lastBellAmOrPmIndexPlusOne-1, inComponent: 1, animated: true)
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
                tower.firstBellTime = tower.hour[row]
                time = tower.firstBellTime % 12 == 0 ? 12 : tower.firstBellTime % 12
            }
            if component == 1 {
                tower.firstBellAmOrPmIndexPlusOne = row + 1
                time = tower.firstBellTime
            }
            activeField?.text = "\(String(time!)) " + tower.amOrPm[tower.firstBellAmOrPmIndexPlusOne-1]
        } else {
            if component == 0 {
                tower.lastBellTime = tower.hour[row]
                time = tower.lastBellTime % 12 == 0 ? 12 : tower.lastBellTime % 12
            }
            if component == 1 {
                tower.lastBellAmOrPmIndexPlusOne = row + 1
                time = tower.lastBellTime
            }
            activeField?.text = "\(String(time!)) " + tower.amOrPm[tower.lastBellAmOrPmIndexPlusOne-1]
        }
        
   
        // check if user set bell as on or off
        if defaults.bool(forKey: "buttonState") {
            // check conditionals for setting notifications
            determineIfFirstMilitaryTimeIsLargerOrSmaller()
        }
        
        
        // update saved time for when user reopens closed app
        if activeField?.accessibilityIdentifier == "firstBellTextField" {
            if component == 0 {
                storage.storedData.set(tower.firstBellTime, forKey: "firstBellHour")
            }
            if component == 1 {
                storage.storedData.set(tower.firstBellAmOrPmIndexPlusOne, forKey: "firstBellAmOrPm")
            }
            
        } else if activeField?.accessibilityIdentifier == "lastBellTextField" {
            component == 0 ?
                storage.storedData.set(tower.lastBellTime, forKey: "lastBellHour") :
                storage.storedData.set(tower.lastBellAmOrPmIndexPlusOne, forKey: "lastBellAmOrPm")
        }
    }
    
    func determineIfFirstMilitaryTimeIsLargerOrSmaller(){
        turnOffReminder()
        let tempLastMilitaryTime = tower.getMilitaryTime(bell: "last")
        let tempFirstMilitaryTime = tower.getMilitaryTime(bell: "first")
        if !tower.checkForRollOverBellTimes() {
            turnOnAlarm(tempFirstBellTime: tempFirstMilitaryTime, tempLastBellTime: tempLastMilitaryTime)
        } else {
            turnOnAlarm(tempFirstBellTime: tempFirstMilitaryTime, tempLastBellTime: 23)
            turnOnAlarm(tempFirstBellTime: 0, tempLastBellTime: tempLastMilitaryTime)
        }
    }
}

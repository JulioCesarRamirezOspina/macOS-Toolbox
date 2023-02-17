//
//  Notifications Manager.swift
//  BootCamper
//
//  Created by Олег Сазонов on 03.01.2022.
//

import Foundation
import UserNotifications
import Combine

//MARK: - Local Notifications Manager
//MARK: Public
/// Creates instance of Local Notification manager
public class LocalNotificationManager: xCore, ObservableObject {
    //MARK: - Value
    //MARK: Private
    var notifications = [Notification]()
    // MARK: - Initialzier
    /// Gets permission to send local notifications
    public override init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                //                print("Notifications permitted")
            } else {
                NSLog("\(error?.localizedDescription ?? "Notifications not permitted")")
            }
        }
    }
    //MARK: - Function
    //MARK: Public
    /// Sends local notification
    /// - Parameters:
    ///   - title: Title of notification
    ///   - subtitle: Subtitle of notification
    ///   - body: Body of notification
    public func sendNotification(title: String, subtitle: String?, body: String, badge: NSNumber? = nil) async {
        clear()
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString(title, comment: "")
        content.body = NSLocalizedString(body, comment: "")
        content.badge = badge
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "macOS ToolBox", content: content, trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
    
    public func clear()  {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        let content = UNMutableNotificationContent()
        content.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "macOS ToolBox", content: content, trigger: trigger)
        Task{
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch let error {
                NSLog(error.localizedDescription)
            }
        }
    }
}

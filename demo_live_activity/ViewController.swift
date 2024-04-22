//
//  ViewController.swift
//  demo_live_activity
//
//  Created by james ong on 23/08/202 3.
//

import OneSignalFramework
import OneSignalExtension
import UIKit
import SwiftUI
import ActivityKit
import WidgetKit

@available(iOS 16.2, *)
class ViewController: UIViewController {
    let endDate = Date(timeIntervalSince1970: 1693360200);
    var bookingNumber = 100;
    
    @IBAction func startActivities(_ sender: Any) {
        var attributes = SunwayWidgetAttributes(startDate: .now, endDate: endDate, title: "booking\(bookingNumber)");
        let state = SunwayWidgetAttributes.ContentState(title: "See you again for more unforgettable moments", dynamicTitle: "Come back soon to your cherished retreat")
        let activity = try? Activity<SunwayWidgetAttributes>.request(attributes: attributes, content: ActivityContent(state: state, staleDate: endDate), pushType: .token)
        
        Task {
            //Listener to store the activity in one signal
            if let pushTokenUpdates = activity?.pushTokenUpdates {
                for await pushToken in pushTokenUpdates {
                    let myToken = pushToken.map {String(format: "%02x", $0)}.joined()
                    
                    OneSignalLiveActivityController.enter("booking\(bookingNumber)", withToken: myToken)
                    print("Push Token String \(myToken)")
                }
            }
        }
        bookingNumber += 1;
        
//                Task {
//                    if let contentUpdates = activity?.contentUpdates {
//                        for await content in contentUpdates {
//                            print("LA content update: \(content)")
//                            print("LA activity id: \(activity?.id), content update: \(content.state)")
//                        }
//                    }
//
//                }
//
        //Listener to close the live activity
        Task {
            if let activityStateUpdates = activity?.activityStateUpdates {
                for await content in activityStateUpdates {
                    print("LA state update: \(content)")
                    if (content == .stale || content == .ended) {
                        let state = SunwayWidgetAttributes.ContentState(title: "", dynamicTitle: "")
                        await activity?.end(ActivityContent(state:state, staleDate: endDate), dismissalPolicy:.immediate)
                    }
                }
            }
        }
    }
}

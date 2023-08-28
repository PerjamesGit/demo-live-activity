//
//  ViewController.swift
//  demo_live_activity
//
//  Created by james ong on 23/08/2023.
//

import OneSignalFramework
import UIKit
import SwiftUI
import ActivityKit
import WidgetKit

@available(iOS 16.2, *)
class ViewController: UIViewController {
    var activity: Activity<SunwayWidgetAttributes>? = nil
    let attributes = SunwayWidgetAttributes(name: "Testing")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startActivities(_ sender: Any) {
        let endDate = Date().addingTimeInterval(60 * 1);
        let state = SunwayWidgetAttributes.ContentState(title: "See you again for more unforgettable moments", dynamicTitle: "Come back soon to your cherished retreat")
        activity = try? Activity<SunwayWidgetAttributes>.request(attributes: attributes, content: ActivityContent(state: state, staleDate: nil), pushType: .token)
        
        Task {
            if let pushTokenUpdates = activity?.pushTokenUpdates {
                for await pushToken in pushTokenUpdates {
                    let pushTokenString = pushToken.reduce("") {
                     $0 + String(format: "%02x", $1)
                    }
                    
                    OneSignalLiveActivityController.enter("booking98", withToken: pushTokenString)
                    print("Push Token String \(pushTokenString)")
                }
            }
        }
        
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
//            print(self.time)
//            if (self.time >= 30) {
//                let state = SunwayWidgetAttributes.ContentValue(time: self.time)
//                Task {
//                    await self.activity?.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .immediate)
//                    self.time = 0
//                    timer.invalidate();
//                }
//            } else {
//                self.time += 1;
//                let state = SunwayWidgetAttributes.ContentValue(time: self.time)
//                Task {
//                    await self.activity?.update((ActivityContent(state: state, staleDate: nil)))
//                }
//            }
//        });
    }
    
    @IBAction func updateActivity(_ sender: Any) {
        print("end")
        let state = SunwayWidgetAttributes.ContentState(title: "", dynamicTitle: "")

        Task {
            await activity?.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .immediate)
        }
    }
    
    
    @IBAction func endActivity(_ sender: Any) {
        print("end")
        let state = SunwayWidgetAttributes.ContentState(title: "", dynamicTitle: "")

        Task {
            await activity?.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .immediate)
        }
    }
    
    
}

//
//  live_activity_widgetLiveActivity.swift
//  live_activity_widget
//
//  Created by james ong on 23/08/2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.2, *)
public struct SunwayWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
//        var time: Date
        var title: String
        var dynamicTitle: String
    }
    
    // Fixed non-changing properties about your activity go here!
    var name: String
}

@available(iOS 16.2, *)
struct live_activity_widgetLiveActivity: Widget {
    let gold = Color(red: 204/255, green: 170/255, blue: 101/255)
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SunwayWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            //            Gold 204, 170, 101, 1.0
            VStack(alignment: .leading, content: {
                Image("icon").resizable().scaledToFit().frame(height: 40)
                HStack(content: {
                    Text("Check Out at").bold().foregroundColor(.black)
//                    Text(context.state.time, style: .time).bold().font(.system(size: 24)).foregroundColor(gold)
                })
                Text(context.state.title).bold().foregroundColor(.black)
//                ProgressView(timerInterval: Date()...context.state.time)
//                    .progressViewStyle(LinearProgressViewStyle(tint: gold))
//                    .foregroundColor(.white)
            })
            .activityBackgroundTint(.white)
            .activitySystemActionForegroundColor(Color.black)
            .padding(Edge.Set.all, 16)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Image("icon").resizable().scaledToFit().frame(height: 40)
                    //                    Circle().foregroundColor(gold).frame(width: 20, height: 20).padding(Edge.Set.leading, 8)
                }
                DynamicIslandExpandedRegion(.center) {
//                    Text(context.state.title).foregroundColor(.white)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    //                    Text("TRAILING")
                    Image("luggage").resizable().scaledToFit().frame(height: 40)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(content: {
                        Text("Check Out at").bold().foregroundColor(.white)
//                        Text(context.state.time, style: .time).bold().font(.system(size: 24)).foregroundColor(gold)
                    })
                    Text(context.state.dynamicTitle).bold().font(.system(size: 14)).foregroundColor(.white)
//                    ProgressView(timerInterval:
//                                    Date()...context.state.time).progressViewStyle(LinearProgressViewStyle(tint: gold))
//                        .padding(Edge.Set.horizontal, 8)
//                        .foregroundColor(.black)
                    //                    Text(context.state.time, style: .timer).foregroundColor(.white).bold()
                    // more content
                }
            } compactLeading: {
                //                HStack(content: {
                //                    Circle().foregroundColor(gold).frame(width: 20, height: 20)
                //                    Text("Sunway")
                //                })
                Image("icon").resizable().scaledToFit().frame(height: 25)
            } compactTrailing: {
                Image("luggage").resizable().scaledToFit().frame(height: 25)
                //                ProgressView(timerInterval: Date()...context.state.time).progressViewStyle(LinearProgressViewStyle(tint: gold))
                //                Text(context.state.time, style: .timer).foregroundColor(.white).bold()
            } minimal: {
                Image("luggage").resizable().scaledToFit().frame(width: 25, height: 25)
            }
            .keylineTint(.green)
        }
    }
}

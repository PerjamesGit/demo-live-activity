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
        var title: String
        var dynamicTitle: String
    }
    
    //Fixed attribute: wont get update if new update coming in
    var startDate:Date = .now
    var endDate:Date;
    var title: String;
}

@available(iOS 16.2, *)
struct live_activity_widgetLiveActivity: Widget {
    let gold = Color(red: 204/255, green: 170/255, blue: 101/255)
    @State private var speed = 50.0

    init() {
        let thumbImage = UIImage(systemName: "luggage")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SunwayWidgetAttributes.self) { context in
            VStack(alignment:.leading, content: {
                HStack(content: {
                    Image("icon").resizable().scaledToFit().frame(height: 40)
                    Spacer()
                    Text(context.attributes.title).bold()
                })
                HStack(content: {
                    if context.attributes.startDate <= context.attributes.endDate {
                        Text("Check Out at").bold().foregroundColor(.black).font(.system(size: 14))
                        Text(context.attributes.endDate, style: .date).bold().font(.system(size: 16)).foregroundColor(gold)
                        Text(context.attributes.endDate, style: .time).bold().font(.system(size: 16)).foregroundColor(gold)
                    } else {
                        // handle when time really run out on open live activity
                        Text("Thank you").bold().foregroundColor(gold)
                    }
                })
                if context.attributes.startDate <= context.attributes.endDate {
                    Text(context.state.title).bold().foregroundColor(.black).font(.system(size: 14))
                    ProgressView(timerInterval: context.attributes.startDate...context.attributes.endDate)
                        .progressViewStyle(LinearProgressViewStyle(tint: gold))
                        .foregroundColor(.white)
                } else {
                    // handle when time really run out on open live activity
                    Text("See you again for more excited event").bold().foregroundColor(.black).font(.system(size: 14))
                }
            })
            .activityBackgroundTint(.white)
            .activitySystemActionForegroundColor(Color.black)
            .padding(.all, 16)
            .padding(.top, context.attributes.startDate <= context.attributes.endDate ? 24 : 0)
            .frame(maxWidth: .infinity, alignment: .leading)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image("icon").resizable().scaledToFit().frame(height: 40)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image("luggage").resizable().scaledToFit().frame(height: 40)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(content: {
                        Text("Check Out at").bold().foregroundColor(.white)
                    })
                    Text(context.state.dynamicTitle).bold().font(.system(size: 14)).foregroundColor(.white)
                    if context.attributes.startDate <= context.attributes.endDate {
                        ProgressView(timerInterval:
                                        context.attributes.startDate...context.attributes.endDate).progressViewStyle(LinearProgressViewStyle(tint: gold))
                            .padding(Edge.Set.horizontal, 8)
                            .foregroundColor(.black)
                    }
                }
            } compactLeading: {
                Image("icon").resizable().scaledToFit().frame(height: 25)
            } compactTrailing: {
                Image("luggage").resizable().scaledToFit().frame(height: 25)
            } minimal: {
                // use for when there is multiple live activity going on dynamic island
                Image("luggage").resizable().scaledToFit().frame(width: 25, height: 25)
            }
            .keylineTint(.green)
        }
    }
}

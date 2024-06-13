
# OneSignal Live Activity

## Content
 - [Intro](#intro)
 - [Frontend IOS](#frontend-ios) 
   - [Requirement](#requirement)
   - [Setup Live Activity](#setup-live-activity)
   - [Create Activity Attributes](#create-activity-attributes)
   - [Create Live Activity Widget](#create-live-activity-widget)
   - [Show Live Activtiy Widget](#show-live-activity-widget)
   - [End Live Activity Widget](#show-live-activity-widget)

 - [Backend](#backend)
    - [Requirement](#requirement-backend)
    - [API Reference](#api-reference)



## Intro
[Live Activity](#https://developer.apple.com/design/human-interface-guidelines/live-activities) is a widget that show a temporary event in phone's notification screen and Dynamic Island.
[Live Activity](#https://developer.apple.com/design/human-interface-guidelines/live-activities) widget allow up to 5 event in notification screen.
[Live Activity](#https://developer.apple.com/design/human-interface-guidelines/live-activities) able to dismiss by either user remove or event end. It will automatically dismiss the event by default 4 hours.

In this tutorial, we will talk about how to setup and use [Live Activity](#https://developer.apple.com/design/human-interface-guidelines/live-activities) using [OneSignal](https://documentation.onesignal.com/docs) on [Frontend IOS](#Frontend IOS) and Backend

# Frontend IOS
## Requirement
1. Live Activity available on iOS 16.2 and above.
2. Dynamic Island available for iphone 14 pro max and iOS 16.2 and above.
3. [Xcode](https://developer.apple.com/xcode/)
4. [OneSignal](https://documentation.onesignal.com/docs) (v3.12.3+ above)

## Setup Live Activity
Note: Assume you already setup for OneSignal IOS, if not please refer this [link](https://documentation.onesignal.com/docs/ios-sdk-setup)
1. Add [NSSupportsLiveActivities](https://developer.apple.com/documentation/bundleresources/information_property_list/nssupportsliveactivities) on Info.list, to support live activity.
2. To allow frequently update Live Activity, add [NSSupportsLiveActivitiesFrequentUpdates](https://developer.apple.com/documentation/bundleresources/information_property_list/nssupportsliveactivities) on Info.list, to support live activity.
3. Go to `File` > `New` > `Target`
-  Select ` widget extension`, add widget extension with `Include live activity` been select. 
- `Note: Don't activate the live activty scheme`.

4. Add `Capability's Push Notification` for `own target`. [OneSignal Requirement](https://documentation.onesignal.com/docs/ios-sdk-setup#2-add-capabilities)
5. Add `Capability's Background Modes` for `own target`, and select `remote notifications`. [OneSignal Requirement](https://documentation.onesignal.com/docs/ios-sdk-setup#2-add-capabilities)
6. Add `Capability's App Group` for `own target` and `widget extension target.`, 
- Select same app groups on `own target` and `widget extension target`. 
- `Note: Not added will cause the live activity can't dismiss.`

## Create Activity Attributes
Activity Attributes use to update Live Activity content from time to time.\
Activtiy Attributes will create by default in your project WidgetExtension Folder's `ExampleWidgetLiveActivity` together with struct `ExampleWidgetLiveActivity`

**Example of ActivityAttributes**
```
//Support on iOS 16.2 and above
@available(iOS 16.2, *)
public struct ExampleWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var title: String
    }
    
    //Fixed attribute: wont get update if new update coming in
    var attributeTitle: String;
}
```

## Create Live Activity Widget
Live Activity Widget will be use to display on the notifcation and also dynamic island\
Live Activity Widget will create by default in your project WidgetExtension Folder's `ExampleWidgetLiveActivity` together with struct `ActivityAttributes`\
To learn how to create live activity design, please refer this [link](https://developer.apple.com/design/human-interface-guidelines/live-activities)

**Example of ExampleWidgetLiveActivity**
```
//Support on iOS 16.2 and above
@available(iOS 16.2, *)
struct ExampleWidgetLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ExampleWidgetAttributes.self) { context in
            Text("It is working")
            Text(context.attributes.attributeTitle)
            Text(context.state.title)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    
                }
                DynamicIslandExpandedRegion(.trailing) {
                    
                }
                DynamicIslandExpandedRegion(.bottom) {
                }
            } compactLeading: {
                
            } compactTrailing: {
                
            } minimal: {
                
            }
        }
    }
}

```

## Show Live Activity Widget
Using OneSignal to show the Live Activity Widget.

1. Create a ActivityAttributes instance
```
var attributes = ExampleWidgetAttributes(attributeTitle: "My Title");
```

2. Create a state variable from your ActivityAttributes
```
let state = ExampleWidgetAttributes.ContentState(title: "My State")
```

3. Start Live Activity
To make your live activity inactive just give it a staleDate.\
To allow the phone to receive [ActivityKit Push Notification](https://developer.apple.com/documentation/activitykit/updating-live-activities-with-activitykit-push-notifications), set `.token` to `pushType`
```
let activity = try? Activity<ExampleWidgetAttributes>.request(attributes: attributes, content: ActivityContent(state: state, staleDate: Date()), pushType: .token)
```

4. To allow Backend able to send OneSignal Push Notifcation to the respective phone,
   - Get the token after start live activity using `pushTokenUpdates` from activity.
   - Send token and activityId to OneSignal once receive the pushTokemUpdates, `OneSignalLiveActivityController.enter("ACTIVITY_ID", withToken: yourToken)`
```
Task {
   if let pushTokenUpdates = activity?.pushTokenUpdates {
      for await pushToken in pushTokenUpdates {
         let myToken = pushToken.map {String(format: "%02x", $0)}.joined()
         
         OneSignalLiveActivityController.enter("ACTIVITY_ID", withToken: myToken)
      }
   }
}
```

5. To listen to the update Live Activity Content Update.
```
Task {
   if let contentUpdates = activity?.contentUpdates {
      for await content in contentUpdates {
         print("LA content update: \(content)")
         print("LA activity id: \(activity?.id), content update: \(content.state)")
      }
   }
}
```

6. To listen to the update Live Activity State Update.
```
Task {
   if let activityStateUpdates = activity?.activityStateUpdates {
      for await content in activityStateUpdates {
         print("LA state update: \(content)") Example: ended, stale, dismiss, active
      }
   }
}
```


**Full Example**
```
var attributes = ExampleWidgetAttributes(attributeTitle: "My Title");

let state = ExampleWidgetAttributes.ContentState(title: "My State")

let activity = try? Activity<ExampleWidgetAttributes>.request(attributes: attributes, content: ActivityContent(state: state, staleDate: Date()), pushType: .token)

<!-- To allow Backend able to send OneSignal Push Notifcation to the respective phone -->
Task {
   if let pushTokenUpdates = activity?.pushTokenUpdates {
      for await pushToken in pushTokenUpdates {
         let myToken = pushToken.map {String(format: "%02x", $0)}.joined()
         
         OneSignalLiveActivityController.enter("booking\(bookingNumber)", withToken: myToken)
      }
   }
}

<!-- To listen to the update Live Activity Content Update. -->
Task {
   if let contentUpdates = activity?.contentUpdates {
      for await content in contentUpdates {
         print("LA content update: \(content)")
         print("LA activity id: \(activity?.id), content update: \(content.state)")
      }
   }
}

<!-- To listen to the update Live Activity State Update. -->
Task {
   if let activityStateUpdates = activity?.activityStateUpdates {
      for await content in activityStateUpdates {
         <!-- Example: ended, stale, dismiss, active -->
         print("LA state update: \(content)") 
      }
   }
}
```

## End Live Activity Widget
To end live activity, you can let user clear the activity, [Received activityStateUpdates from backend](#received-activitystateupdates-from-backend), or [Event end the activity]().

### Received activityStateUpdates from backend
By using the activityStateUpdate above, if is content is ended, end the activity using `activity.end` with dismissalPolicy `.immediate`
```
Task {
   if let activityStateUpdates = activity?.activityStateUpdates {
      for await content in activityStateUpdates {
          if (content == .ended) {
               let state = ExampleWidgetAttributes.ContentState(title: "")
               await activity?.end(ActivityContent(state:state, staleDate: endDate), dismissalPolicy:.immediate)
            }
      }
   }
}
```

### Event end the activity
First set the `staleDate` to desire time during [startActivity](#show-live-activity-widget) (Step 3).

By using the activityStateUpdate above, if is content is stale, end the activity using `activity.end` with dismissalPolicy `.immediate`
```
Task {
   if let activityStateUpdates = activity?.activityStateUpdates {
      for await content in activityStateUpdates {
          if (content == .stale) {
               let state = ExampleWidgetAttributes.ContentState(title: "")
               await activity?.end(ActivityContent(state:state, staleDate: endDate), dismissalPolicy:.immediate)
            }
      }
   }
}
```


# Backend
## Requirement Backend
1. Any IDE to call [OneSignal REST Api](https://documentation.onesignal.com/reference/live-activities-api)
2. Any Programming language


## API Reference

### Update or End Live Activity Event

```
  https://onesignal.com/api/v1/apps/APP_ID/live_activities/ACTIVITY_ID/notifications
```

**Path Parameter**
| Path | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `APP_ID` | `string` | **Required**.  From Onesignal **App Id** (Keys & IDs section)|
| `ACTIVITY_ID` | `string` | **Required**.  Generate a string (slash / is not allow) for OneSignal to push Activity to that user. Eg. booking20|

**Header Parameter**
| Header | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `Authorization` | `string` | **Required**.  **Basic Authentication** From OneSignal **ApiKey** (Keys & IDs section)|
| `Content-Type` | `string` | **Required**.  application/json|
| `accept` | `string` | **Required**.  application/json|


**Body Parameter**
| Parameter | Type     | Description                |
| :-------- | :------- | :------------------------- |
| `event` | `string` | **Required**.  value: `end` or `update` |
| `event_update` | `json` | **Required**.  value: follow stateful variable define in Frontend IOS (Case Sensitive)|
| `name` | `string` | **Required**.  value: Any Name for differentiate |
| `contents` | `json` | **Required**.  value: use to display on **Apple Watch** ```{"en": "English Message"}```|
| `headings` | `json` | **Required**.  value: use to display on **Apple Watch** ```{"en": "English Message"}``` |
| `priority` | `string` | **Optional**.  value: 0 (low) - 10 (high) priority to update the Live Activity |

**Example Update Event using Curl**
```
curl --request POST \
     --url https://onesignal.com/api/v1/apps/APPID/live_activities/ACTIVITY_ID/notifications \
     --header 'Authorization: Basic YmEzYjZlNGMtMmUxNC00NDIxLWI2ZDEtNmViMTg4NDZiZTYw' \
     --header 'Content-Type: application/json' \
     --header 'accept: application/json' \
     --data '
{
  "event": "update",
  "event_updates": {
    "title": "Harlo",
  },
  "name": "Title",
  "contents": {
    "en": "English Message"
  },
  "headings": {
    "en": "English Message"
  },
  "priority": 10
}
'
```

**Example End Event using Curl**
```
curl --request POST \
     --url https://onesignal.com/api/v1/apps/APPID/live_activities/ACTIVITY_ID/notifications \
     --header 'Authorization: Basic YmEzYjZlNGMtMmUxNC00NDIxLWI2ZDEtNmViMTg4NDZiZTYw' \
     --header 'Content-Type: application/json' \
     --header 'accept: application/json' \
     --data '
{
  "event": "end",
  "event_updates": {
    "title": "Thank you",
  },
  "name": "Title",
  "contents": {
    "en": "English Message"
  },
  "headings": {
    "en": "English Message"
  },
  "priority": 10
}
'
```

## Frontend References
- [Design Dynamic Island and Live Activity Widget](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [Quick Start OneSignal Live Activity](https://documentation.onesignal.com/docs/live-activities-quickstart)
- [Create and Update OneSignal Live Activity](https://documentation.onesignal.com/docs/how-to-create-and-update-a-live-activity)



## Backend References
- [OneSignal Live Activity Api](https://documentation.onesignal.com/reference/live-activities-api)

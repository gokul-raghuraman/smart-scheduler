//
//  AppDelegate.swift
//  Zazu Screens
//
//  Created by Gokul Raghuraman on 3/26/15.
//  Copyright (c) 2015 Zazu Labs. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import EventKit
import SwiftHTTP

var events = Array<Event>()
var user = User()
var request = HTTPTask()
var eventStore = EKEventStore()
var apiURL = "http://szheng60.pythonanywhere.com/api"
//var apiURL = "http://192.168.136.1:8000/api"
//var apiURL = "http://143.215.59.236:8000/api"
//var userEmail = "xinyuchen919@gmail.com"
//var userName = "song"
var calendarTitle = String()
var calendarEventTimeSlot = Array<calendarEvent>()
var timeDifference = 4 //adjustment for time
var timeSlotInterval = 30 //minutes for each time slot
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        initCalendarAccess()
        //readEvents()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func initCalendarAccess()
    {
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .Authorized:
            extractEventEntityCalendarsOutOfStore(eventStore)
        case .Denied:
            displayAccessDenied()
        case .NotDetermined:
            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
                {[weak self] (granted: Bool, error: NSError!) -> Void in
                    if granted{
                        self!.extractEventEntityCalendarsOutOfStore(eventStore)
                    } else {
                        self!.displayAccessDenied()
                    }
            })
        case .Restricted:
            displayAccessRestricted()
        }
    }
    func displayAccessDenied()
    {
        println("Access to the event store is denied")
    }
    func displayAccessRestricted()
    {
        println("Access to the event store is restricted")
    }
    func extractEventEntityCalendarsOutOfStore(eventStore: EKEventStore){
        let calendarTypes = [
            "Local",
            "CalDAV",
            "Exchange",
            "Subscription",
            "Birthday",
        ]
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent)
            as [EKCalendar]
        for calendar in calendars{
            println("Calendar title = \(calendar.title)")
            println("Calendar type = \(calendarTypes[Int(calendar.type.value)])")
            let color = UIColor(CGColor: calendar.CGColor)
            println("Calendar color = \(color)")
            if calendar.allowsContentModifications{
                calendarTitle = calendar.title
                println("This calendar allows modifications")
            } else {
                println("This calendar does not allow modifications")
            }
            println("--------------------------")
        }
    }
    func sourceInEventStore(eventStore: EKEventStore, type: EKSourceType, title: String) ->EKSource? {
        for source in eventStore.sources() as [EKSource] {
            if source.sourceType.value == type.value && source.title.caseInsensitiveCompare(title) == NSComparisonResult.OrderedSame {
                return source
            }
        }
        return nil
    }
    func calendarWithTitle(title: String, type: EKCalendarType, source: EKSource, eventType: EKEntityType) ->EKCalendar? {
        for calendar in source.calendarsForEntityType(eventType).allObjects as [EKCalendar] {
            if calendar.title.caseInsensitiveCompare(title) == NSComparisonResult.OrderedSame && calendar.type.value == type.value {
                return calendar
            }
        }
        return nil
    }
    func createEventWithTitle (title: String, startDate: NSDate, endDate: NSDate, inCalendar: EKCalendar, inEventStore: EKEventStore, notes: String) -> Bool {
        /*if a calendar does not alow modification of its contents, then we cannot insert an event into it*/
        if inCalendar.allowsContentModifications == false {
            println("The selected calendar does not allow moidifications")
            return false
        }
        /*create an event*/
        var event = EKEvent(eventStore: inEventStore)
        event.calendar = inCalendar
        /*populate detail to the event*/
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        
        /*save the event into the calendar*/
        var error:NSError?
        let result = inEventStore.saveEvent(event, span: EKSpanThisEvent, error: &error)
        if result == false {
            if let theError = error {
                println("An error occured \(theError)")
            }
        }
        return result
    }
    func insertEventIntoStore(store: EKEventStore) {
        let source = sourceInEventStore(store, type: EKSourceTypeLocal, title: "Calendar")
        if source == nil {
            println("you have not configured the calendar for your device")
            return
        }
        let calendar = calendarWithTitle("Calendar", type: EKCalendarTypeLocal, source: source!, eventType: EKEntityTypeEvent)
        if calendar == nil {
            println("could not find the calendar we were looking for")
            return
        }
        /*The event starts from today, now*/
        let startDate = NSDate()
        /*The event ends this time, tomorrow*/
        let endDate = startDate.dateByAddingTimeInterval(24*60*60)
        if createEventWithTitle("testing", startDate: startDate, endDate: endDate, inCalendar: calendar!, inEventStore: store, notes: "insert testing") {
            println("Successfully created the event")
        } else {
            println("Fail to create the event")
        }
    }
    func readEvents(startTime:String, endTime:String)
    {
        println("to read events")
        let eventStore = EKEventStore()
        let source = sourceInEventStore(eventStore, type: EKSourceTypeLocal, title: "\(calendarTitle)")
        
        if source == nil {
            println("you have not configured the calendar for your device")
            return
        }
        let calendar = calendarWithTitle("\(calendarTitle)", type: EKCalendarTypeLocal, source: source!, eventType: EKEntityTypeEvent)
        if calendar == nil {
            println("could not find the calendar we were looking for ")
            return
        }
        let startDate = NSDate(fromString: startTime, format: .ISO8601)
        let endDate = NSDate(fromString: endTime, format: .ISO8601)
        
        println(startDate)
        println(endDate)
        /*create fetch*/
        let searchPredicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: [calendar!])
        println("create fetch")
        /*fetch events b/t starting and ending dates*/
        let e = eventStore.eventsMatchingPredicate(searchPredicate) as? [EKEvent]
        println("fetch events")
        
        if e == nil {
            println("No events could be found")
        } else {
            println("parse event")
            for event in e! {
                let ce = calendarEvent(title: event.title, start_date: event.startDate.dateBySubtractingHours(timeDifference), end_date: event.endDate.dateBySubtractingHours(timeDifference))
                calendarEventTimeSlot.append(ce)
            }
            println("got events")
        }
    }

}


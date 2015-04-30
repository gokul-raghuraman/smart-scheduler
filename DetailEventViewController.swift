//
//  DetailEventViewController.swift
//  Zazu Screens
//
//  Created by Gokul Raghuraman on 3/26/15.
//  Copyright (c) 2015 Zazu Labs. All rights reserved.
//

import UIKit
import EventKit
import SwiftHTTP
import JSONJoy

class DetailEventViewController: UIViewController
{
    var event: Event!
    
    var appDelegate: AppDelegate?
    //var incrementTime = 30 //minutes
    //var du = DateUtils()
    var startOnDateTime:NSDate!
    var endOnDateTime:NSDate!
    var timeSlotHelper = TimeSlotHelper()

    @IBOutlet weak var meetingNameTextField: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var creatorEmailLabel: UILabel!
    @IBOutlet weak var creatorImageView: UIImageView!

    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var decideByIndicatorLabel: UILabel!
    @IBOutlet weak var decideByDateLabel: UILabel!
    @IBOutlet weak var participantsTextView: UITextView!
    @IBOutlet weak var meetingDescriptionTextView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var viewTimeSlotsButton: UIButton!
    @IBOutlet weak var declinedLabel: UILabel!
    
    @IBOutlet weak var scheduleButton: UIButton!
    
    @IBOutlet weak var scheduledLabel: UILabel!
    
    override func viewDidLoad()
    {
        
        println(event.timeSlots)
        println("\n")
        println("\n")
        
        if event.status == "new" && event.creator_email != user.currentUser?.email
        {
            viewTimeSlotsButton.hidden = true
        }
        
        
        if event.status != "new" || event.creator_email == user.currentUser?.email
        {
            acceptButton.hidden = true
            declineButton.hidden = true
        }
        
        if (event.status == "declined")
        {
            acceptButton.hidden = true
            declineButton.hidden = true
            viewTimeSlotsButton.hidden = true
            declinedLabel.hidden = false
        }
        
        if (event.status == "scheduled")
        {
            scheduledLabel.hidden = false
            scheduleButton.hidden = true
            viewTimeSlotsButton.hidden = true
            toDate.hidden = true
            decideByIndicatorLabel.hidden = true
            decideByDateLabel.hidden = true
            
            //Format and display only the fixed date
            
            let meetingDate = event.timeSlots![0]
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            let formattedDate = formatter.dateFromString(meetingDate)
            
            //println("FORMATTED DATE :")
            //println(formattedDate)
            
            let formatter2 = NSDateFormatter()
            formatter2.dateStyle = NSDateFormatterStyle.FullStyle
            formatter2.timeStyle = .MediumStyle
            let dateString = formatter2.stringFromDate(formattedDate!)

            fromDate.text = dateString
            
            //fromDate.text = NSDate(fromString: event.timeSlots![0], format: .ISO8601).toString(format: .Custom("dd MMM yyyy HH:mm"))
            
        }
        
        if (event.status != "scheduled" && event.status != "declined")
        {
            if (event.creator_email == user.currentUser?.email)
            {
                scheduleButton.hidden = false
            }
        }
        
        if event.eventID == 0 {
            acceptButton.enabled = false
        }
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        meetingNameTextField.text = event.name
        meetingDescriptionTextView.text = event.description
        creatorLabel.text = "Created by " + event.creator_name!
        creatorEmailLabel.text = "(" + event.creator_email! + ")"
        //creatorImageView.image = UIImage(named: event.image!)
        fromDate.text = "From\t" + NSDate(fromString: event.start_date!, format: .ISO8601).toString(format: .Custom("dd MMM yyyy HH:mm"))
        
        if (event.status == "scheduled")
        {
            fromDate.text = NSDate(fromString: event.start_date!, format: .ISO8601).toString(format: .Custom("dd MMM yyyy HH:mm"))

        }
        toDate.text = "To\t\t" + NSDate(fromString: event.end_date!, format: .ISO8601).toString(format: .Custom("dd MMM yyyy HH:mm"))
        decideByDateLabel.text = NSDate(fromString: event.decide_by_date!, format: .ISO8601).toString(format: .Custom("dd MMM yyyy HH:mm"))
        var attendee = ",".join(event.attendees!)
        participantsTextView.text = attendee
        
        
        print(event.timeSlots)
        
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func acceptButton(sender: AnyObject) {
        if event.eventID != 0
        {
            event.status = "accepted"
            var eventDuration = event.duration!.toInt()
            var timeSlots = Array<NSDate>()
        
            startOnDateTime = NSDate(fromString: event.start_date!, format: .ISO8601)
            endOnDateTime = NSDate(fromString: event.end_date!, format: .ISO8601)
        
            startOnDateTime = startOnDateTime.dateBySubtractingSeconds(startOnDateTime.seconds())
            endOnDateTime = endOnDateTime.dateBySubtractingSeconds(endOnDateTime.seconds())
        
            appDelegate!.readEvents(startOnDateTime.toString(format: .ISO8601), endTime: endOnDateTime.toString(format: .ISO8601))
        
            startOnDateTime = startOnDateTime.dateBySubtractingHours(timeDifference)
            endOnDateTime = endOnDateTime.dateBySubtractingHours(timeDifference)
        
            var adjustedCalendarEvents = timeSlotHelper.adjustment()//adjustment()

            while startOnDateTime.compare(endOnDateTime) == NSComparisonResult.OrderedAscending {
                timeSlots.append(startOnDateTime)
                let temp = startOnDateTime.dateByAddingMinutes(timeSlotInterval)
                startOnDateTime = temp
            }
            let availableTimeSlots = timeSlotHelper.generateAvalableTimeSlots(timeSlots, events: adjustedCalendarEvents, eventDuration: eventDuration!)
            //println(availableTimeSlots)
            var temp = Array<String>()
            var time_slots = String()
            for slot in availableTimeSlots {
                temp.append(slot.dateByAddingHours(timeDifference).toString(format: .ISO8601))
            }
            
            time_slots = ",".join(temp)
            let params:Dictionary<String, AnyObject> = [
                "id": "\(event.eventID!)",
                "timeSlots": "\(time_slots)",
            ]
            println(params)
            request.requestSerializer = HTTPRequestSerializer()
            request.PUT("\(apiURL)/events", parameters: params, success: {(response: HTTPResponse) in
                self.dismissViewControllerAnimated(true, completion: nil)
                }, failure: {(error: NSError, response: HTTPResponse? ) in
                    println("error: \(error)")
            })
            for var i = 0; i < events.count; i++ {
                if events[i].eventID == event.eventID {
                    events[i] = event
                }
            }
        }
        
    }
    
    
    @IBAction func scheduleButtonAction(sender: AnyObject)
    {
        event.status = "scheduled"
        
        var timeSlotsArray = [event.timeSlots![0]]
        
        var time_slots = String()
        time_slots = ",".join(timeSlotsArray)
       
        var status = "scheduled"
       
        let params:Dictionary<String, AnyObject> = [
            "id": "\(event.eventID!)",
            "status": "\(status)",
            "timeSlots": "\(time_slots)",
        ]
        println(params)
        request.requestSerializer = HTTPRequestSerializer()
        request.PUT("\(apiURL)/events", parameters: params, success: {(response: HTTPResponse) in
            self.dismissViewControllerAnimated(true, completion: nil)
            }, failure: {(error: NSError, response: HTTPResponse? ) in
                println("error: \(error)")
        })
        
        for var i = 0; i < events.count; i++
        {
            if events[i].eventID == event.eventID
            {
                events[i] = event
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        var updatedTimeSlots = Array<String>()
        
        request.GET("\(apiURL)/events?id=\(event.eventID!)", parameters: nil, success: {(response: HTTPResponse) in
            if response.responseObject != nil {
                let decoder = JSONDecoder(response.responseObject!)
                if let decoders = decoder.array {
                    let subDecoder = decoders[0]
                    let temp = Event(subDecoder)
                    println("TEMP SLOTS : ")
                    println(temp.timeSlots)
                    for timeSlot in temp.timeSlots!
                    {
                        println("TIME SLOT : ")
                        println(timeSlot)
                        updatedTimeSlots.append(timeSlot)
                        println("UPDATED SLOTS IN LOOP: ")
                        println(updatedTimeSlots)
                        
                    }
                    
                }

            }
            
            }, failure: {(error: NSError, response: HTTPResponse? ) in
                println("error: \(error)")
        })
        sleep(1)
        
        
        // Pass the selected object to the new view controller.
        if segue.identifier == "ViewSlots"
        {
            var timeSlotsViewController = segue.destinationViewController as TimeSlotsViewController
            
            timeSlotsViewController.timeSlots = updatedTimeSlots
            timeSlotsViewController.eventID = event.eventID!

        }

    }
}


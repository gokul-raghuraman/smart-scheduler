//
//  CreateMeetingViewController.swift
//  Zazu Screens
//
//  Created by Gokul Raghuraman on 3/26/15.
//  Copyright (c) 2015 Zazu Labs. All rights reserved.
//
import Foundation
import UIKit
import AddressBookUI
import SwiftHTTP
import JSONJoy

class CreateMeetingViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ABPeoplePickerNavigationControllerDelegate
{
    var appDelegate: AppDelegate?
    //Invitee data passed from contacts screen
    var dataPassed: Array<String>!
    var timeSlotHelper = TimeSlotHelper()
    //Meeting data passed to contacts screen
    var meetingName: String?
    var meetingDescription: String?
    var fromDate: String?
    var toDate: String?
    var decideByDate: String?
    var duration: String?
    var startOnDateTime:NSDate!
    var endOnDateTime:NSDate!
    var decideByDateTime:NSDate!
    var DESC_CONSTRAINT_ORIG: CGFloat!
    
    @IBOutlet weak var meetingNameTextField: UITextField!
    @IBOutlet weak var meetingDescriptionTextView: UITextView!
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var decideByDateTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var inviteesTableView: UITableView!
    
    @IBOutlet weak var descriptionConstraint: NSLayoutConstraint!
    
    
    var fromDatePopDatePicker: PopDatePicker?
    var toDatePopDatePicker: PopDatePicker?
    var decideByDatePopDatePicker: PopDatePicker?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        fromDatePopDatePicker = PopDatePicker(forTextField: fromDateTextField)
        toDatePopDatePicker = PopDatePicker(forTextField: toDateTextField)
        decideByDatePopDatePicker = PopDatePicker(forTextField: decideByDateTextField)
        
        //Assign delegates and dataSource
        fromDateTextField.delegate = self
        toDateTextField.delegate = self
        decideByDateTextField.delegate = self
        inviteesTableView.delegate = self
        inviteesTableView.dataSource = self
        meetingDescriptionTextView.delegate = self
        
        //Important: if no data passed, set to empty list.
        if dataPassed == nil
        {
            dataPassed = []
        }
        
        //Re-populate text fields with data saved from last segue to contacts screen
        refillTextFields()
        
        DESC_CONSTRAINT_ORIG = descriptionConstraint.constant
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func createMeetingAction(sender: AnyObject)
    {

        meetingName = meetingNameTextField.text
        meetingDescription = meetingDescriptionTextView.text
        fromDate = fromDateTextField.text
        toDate = toDateTextField.text
        decideByDate = decideByDateTextField.text
        duration = durationTextField.text
        
        
        //Go through the participants array and convert to string
        let now  = NSDate()
        if startOnDateTime.compare(now) == NSComparisonResult.OrderedAscending {
            let alertController = UIAlertController(title: "Smart Scheduler", message:
                "Invalid start time", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: false, completion: nil)
            return
        }
        
        var participants:String = ",".join(dataPassed)
        
        var navigationController = self.navigationController! as UINavigationController
        var eventsViewController = navigationController.presentingViewController as ViewController
        
        var status = "new"
        var time_slots = String()
        var temp = Array<String>()
        
        let fd = NSDate(fromString: "\(startOnDateTime.toString(format: .ISO8601))", format: .ISO8601)
        let ed = NSDate(fromString: "\(endOnDateTime.toString(format: .ISO8601))", format: .ISO8601)
        let dd = NSDate(fromString: "\(decideByDateTime.toString(format: .ISO8601))", format: .ISO8601)

        var timeSlots = Array<NSDate>()
        var eventDuration = duration?.toInt()
        
        var start = NSDate(fromString: fd.toString(format: .ISO8601), format: .ISO8601)
        var end = NSDate(fromString: ed.toString(format: .ISO8601), format: .ISO8601)
        
        start = startOnDateTime.dateBySubtractingSeconds(startOnDateTime.seconds())
        end = endOnDateTime.dateBySubtractingSeconds(endOnDateTime.seconds())
        
        println("start: \(start)")
        println("end: \(end)")
        if appDelegate == nil {
            println("nil")
        }
        appDelegate!.readEvents(start.toString(format: .ISO8601), endTime: end.toString(format: .ISO8601))
        
        println("can I pass here")
        start = start.dateBySubtractingHours(timeDifference)
        end = end.dateBySubtractingHours(timeDifference)

        var adjustedCalendarEvents = timeSlotHelper.adjustment()
        
        while start.compare(end) == NSComparisonResult.OrderedAscending {
            timeSlots.append(start)
            let temp = start.dateByAddingMinutes(timeSlotInterval)
            start = temp
        }
        let availableTimeSlots = timeSlotHelper.generateAvalableTimeSlots(timeSlots, events: adjustedCalendarEvents, eventDuration: eventDuration!)//generateAvalableTimeSlots(timeSlots, events: adjustedCalendarEvents, eventDuration: eventDuration!)
        println(availableTimeSlots)
        
        for slot in availableTimeSlots {
            temp.append(slot.dateByAddingHours(timeDifference).toString(format: .ISO8601))
        }

        time_slots = ",".join(temp)
        let params:Dictionary<String, AnyObject> = [
            "name": "\(meetingName!)",
            "description": "\(meetingDescription!)",
            "duration": "\(duration!)",
            "creator_email": "\(user.currentUser!.email!)",
            "creator_name": "\(user.currentUser!.firstName!) \(user.currentUser!.lastName!)",
            "decide_by_date": "\(dd.toString(format: .ISO8601))",
            "start_date": "\(fd.toString(format: .ISO8601))",
            "end_date": "\(ed.toString(format: .ISO8601))",
            "status": "\(status)",
            "timeSlots": "\(time_slots)",
            "invitee": "\(participants)"
        ]
        //println(params)

        request.POST("\(apiURL)/events/", parameters: params, success: {(response: HTTPResponse) in
            eventsViewController.newEvent = Event(
                eID: 0,
                name: self.meetingName!,
                description: self.meetingDescription!,
                duration: self.duration!,
                email: "\(user.currentUser!.email!)",
                creator_name: "\(user.currentUser!.firstName!) \(user.currentUser!.lastName!)",
                attendees: self.dataPassed,
                sd: fd.toString(format: .ISO8601),//.fromDate!,
                ed: ed.toString(format: .ISO8601),//self.toDate!,
                dd: dd.toString(format: .ISO8601),//self.decideByDate!,
                status: "\(status)",
                timeSlots: [time_slots]
            )

            if response.responseObject != nil {
                let temp = Event(JSONDecoder(response.responseObject!))
                eventsViewController.newEvent!.eventID = temp.eventID!
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            }, failure: {(error: NSError, response: HTTPResponse? ) in
                let alertController = UIAlertController(title: "Smart Scheduler", message:
                    "No time slot available for this event", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: false, completion: nil)
        })

    }
    private func checkTextField(s: String) ->NSString {
        let text = s
        if countElements(text) == 0 {
            return "null"
        }
        else
        {
            return text
        }
    }
    // For resigning text fields as first responders
    func resignTextFields()
    {
        fromDateTextField.resignFirstResponder()
        toDateTextField.resignFirstResponder()
        decideByDateTextField.resignFirstResponder()
    }
    
    //Dismiss keyboard if screen tapped
    func dismissKeyboard()
    {
        view.endEditing(true)
        self.descriptionConstraint?.constant = DESC_CONSTRAINT_ORIG
        UIView.animateWithDuration(0.1, animations: { () in
            self.view.layoutIfNeeded()})
    }
    
    func refillTextFields()
    {
        if meetingName != nil
        {
            meetingNameTextField.text = meetingName
        }
        if meetingDescription != nil
        {
            meetingDescriptionTextView.text = meetingDescription
        }
        if fromDate != nil
        {
            fromDateTextField.text = fromDate
        }
        if toDate != nil
        {
            toDateTextField.text = toDate
        }
        if decideByDate != nil
        {
            decideByDateTextField.text = decideByDate
        }
        if duration != nil
        {
            durationTextField.text = duration
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        
        //Resign date text fields as first responders
        resignTextFields()
        
        //Pop-up the date picker for each text field
        if textField == fromDateTextField
        {
            //let initDate = dateUtil.getDateFromString(fromDateTextField.text)
            let initDate = NSDate(fromString: fromDateTextField.text, format: .ISO8601)
            fromDatePopDatePicker!.pick(self, initDate:initDate, dataChanged: { (newDate : NSDate, forTextField : UITextField) -> () in
                forTextField.text = newDate.toString(format: .Custom("dd MMM yyyy HH:mm"))
                self.startOnDateTime = newDate
            })
            return false
        }
            
        else if textField == toDateTextField
        {
            //let initDate = dateUtil.getDateFromString(fromDateTextField.text)
            let initDate = NSDate(fromString: fromDateTextField.text, format: .ISO8601)
            toDatePopDatePicker!.pick(self, initDate:initDate, dataChanged: { (newDate : NSDate, forTextField : UITextField) -> () in
                forTextField.text = newDate.toString(format: .Custom("dd MMM yyyy HH:mm"))
                self.endOnDateTime = newDate
            })
            return false
        }
            
        else if textField == decideByDateTextField
        {
            //let initDate = dateUtil.getDateFromString(fromDateTextField.text)
            let initDate = NSDate(fromString: fromDateTextField.text, format: .ISO8601)
            decideByDatePopDatePicker!.pick(self, initDate:initDate, dataChanged: { (newDate : NSDate, forTextField : UITextField) -> () in
                forTextField.text = newDate.toString(format: .Custom("dd MMM yyyy HH:mm"))
                self.decideByDateTime = newDate
            })
            return false
        }
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        if textView == meetingDescriptionTextView
        {
            println(self.descriptionConstraint?.constant)
            self.descriptionConstraint?.constant = 260
            UIView.animateWithDuration(0.1, animations: { () in
                self.view.layoutIfNeeded()})

        }
        return true
    }
    
    @IBAction func performPickPerson(sender : AnyObject) {
        let picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        picker.displayedProperties = [NSNumber(int: kABPersonEmailProperty)]
        
        if picker.respondsToSelector(Selector("predicateForEnablingPerson")) {
            picker.predicateForEnablingPerson = NSPredicate(format: "emailAddresses.@count > 0")
        }
        
        presentViewController(picker, animated: true, completion: nil)
    }

    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!, property: ABPropertyID, identifier: ABMultiValueIdentifier){
        let multiValue: ABMultiValueRef = ABRecordCopyValue(person, property).takeRetainedValue()
        let index = ABMultiValueGetIndexForIdentifier(multiValue, identifier)
        let email = ABMultiValueCopyValueAtIndex(multiValue, index).takeRetainedValue() as String
        dataPassed.append(email)
        println("email = \(email)")
    }
    
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataPassed.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = inviteesTableView.dequeueReusableCellWithIdentifier("InviteeCell") as UITableViewCell
        cell.textLabel?.text = dataPassed[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "AddInvitees"
        {
            var addInviteesViewController = segue.destinationViewController as AddInviteesViewController
            addInviteesViewController.meetingName = meetingName
            addInviteesViewController.meetingDescription = meetingDescription
            addInviteesViewController.fromDate = fromDate
            addInviteesViewController.toDate = toDate
            addInviteesViewController.decideByDate = decideByDate
            addInviteesViewController.duration = duration
        }
    }
}

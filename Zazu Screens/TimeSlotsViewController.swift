//
//  TimeSlotsViewController.swift
//  Zazu Screens
//
//  Created by Gokul Raghuraman on 4/21/15.
//  Copyright (c) 2015 Zazu Labs. All rights reserved.
//

import UIKit
import SwiftHTTP
import JSONJoy

class TimeSlotsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var timeSlots = Array<String>()
    
    var timeSlotsFormatted = Array<String>()
    
    var eventID = Int()
    
    var selectedTimeSlots = Array<String>()
    
    var timeSlotSelections = Array<Bool>()
    
    @IBOutlet weak var timeSlotsTableView: UITableView!
    
    override func viewDidLoad()
    {
        //println("NOW")
        
        
        
        self.timeSlotsTableView.delegate = self
        self.timeSlotsTableView.dataSource = self
        
        for var i = 0; i < timeSlots.count; i++
        {
            timeSlotSelections.append(true)
        }
        
        
        let formatter = NSDateFormatter()
        //formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        //formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        
        var dates = Array<NSDate>()
        
        for var i = 0; i < timeSlots.count; i++
        {
            
            let formattedDate = formatter.dateFromString(timeSlots[i])
            
            //println("FORMATTED DATE now:")
            println(formattedDate)

            if formattedDate == nil
            {
                dates.append(NSDate())
            }
            else
            {
                dates.append(formattedDate!)
            }
            

        }
        
        
        let formatter2 = NSDateFormatter()
        formatter2.dateStyle = NSDateFormatterStyle.FullStyle
        formatter2.timeStyle = .MediumStyle
        
        for var i = 0; i < dates.count; i++
        {
            let date = dates[i]
            
            let dateString = formatter2.stringFromDate(date)
            timeSlotsFormatted.append(dateString)
        }
        
        println(timeSlotsFormatted)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.timeSlots.count
        //return 3
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark
        {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            timeSlotSelections[indexPath.row] = false
            
        }
        else
        {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            timeSlotSelections[indexPath.row] = true
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeSlotCell") as UITableViewCell
        
        if timeSlotSelections[indexPath.row] == true
        {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        cell.textLabel?.text = timeSlotsFormatted[indexPath.row]
        cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
        return cell

    }
    
    
    
    @IBAction func updateButtonAction(sender: AnyObject)
    {
        for var i = 0; i < timeSlots.count; i++
        {
            if timeSlotSelections[i] == true
            {
                selectedTimeSlots.append(timeSlots[i])
            }
        }
        
        print(selectedTimeSlots)
        
        
        var time_slots = ",".join(selectedTimeSlots)
        let params:Dictionary<String, AnyObject> = [
            "id": "\(eventID)",
            "timeSlots": "\(time_slots)",
        ]
        println(" ")
        println(" ")
        println(" ")
        println(time_slots)
        
        request.requestSerializer = HTTPRequestSerializer()
        request.PUT("\(apiURL)/events", parameters: params, success: {(response: HTTPResponse) in
            self.dismissViewControllerAnimated(true, completion: nil)
            }, failure: {(error: NSError, response: HTTPResponse? ) in
                println("error: \(error)")
        })

        
    }
    

}

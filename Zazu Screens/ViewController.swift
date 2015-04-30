//
//  ViewController.swift
//  Zazu Screens
//
//  Created by Gokul Raghuraman on 3/26/15.
//  Copyright (c) 2015 Zazu Labs. All rights reserved.
//

import UIKit
import SwiftHTTP
import JSONJoy
import AddressBookUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    var newEvent: Event?
    var refreshControl = UIRefreshControl()
    var tableViewController = UITableViewController(style: .Plain)

    @IBOutlet weak var eventsTableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        if newEvent != nil {
            events.append(newEvent!)
            newEvent = nil
        }
        self.eventsTableView.reloadData()
        //self.refreshControl = rc
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var tableView = tableViewController.tableView
        tableView.dataSource = self
        request.requestSerializer = HTTPRequestSerializer()
        request.requestSerializer.headers["JWT"] = "\(user.token!)"
        getAPIEvents()
        //self.refreshControl = UIRefreshControl()

        tableViewController.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: Selector("updateSlotView"), forControlEvents: UIControlEvents.ValueChanged)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getAPIEvents()
    {
        request.GET("\(apiURL)/events/", parameters: nil, success: {(response: HTTPResponse) in
            if response.responseObject != nil {
                let decoder = JSONDecoder(response.responseObject!)
                if let decoders = decoder.array {
                    for subDecoder in decoders {
                        let temp = Event(subDecoder)
                        if user.currentUser!.email! == temp.creator_email! {
                            events.append(temp)
                        } else if let invitees = temp.attendees {
                            for invitee in invitees {
                                if user.currentUser!.email! == invitee {
                                    events.append(temp)
                                }
                            }
                        }
                    }
                }
                self.eventsTableView.reloadData()
            }
            }, failure: {(error: NSError, response: HTTPResponse?) in
                println("got an error: \(error)")
        })

    }
    
    func updateSlotView() {
        var tempEvents = Array<Event>()
        request.GET("\(apiURL)/events/", parameters: nil, success: {(response: HTTPResponse) in
            if response.responseObject != nil {
                let decoder = JSONDecoder(response.responseObject!)
                if let decoders = decoder.array {
                    for subDecoder in decoders {
                        let temp = Event(subDecoder)
                        if user.currentUser!.email! == temp.creator_email! {
                            tempEvents.append(temp)
                        } else if let invitees = temp.attendees {
                            for invitee in invitees {
                                if user.currentUser!.email! == invitee {
                                    tempEvents.append(temp)
                                }
                            }
                        }
                    }
                }
                for e in tempEvents {
                    for ee in events {
                        if e.eventID != ee.eventID {
                            events.append(e)
                        }
                    }
                }
                self.eventsTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            }, failure: {(error: NSError, response: HTTPResponse?) in
                println("got an error: \(error)")
        })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: EventTableViewCell = eventsTableView.dequeueReusableCellWithIdentifier("EventCell") as EventTableViewCell
        let event = events[indexPath.row]
        var attendee = ",".join(event.attendees!)
        
        let name = event.creator_name!.componentsSeparatedByString(" ")
        let pic = name[0].lowercaseString

        cell.setCell(event.name!, status: event.status!, eventTimeText: event.start_date!, eventAttendeesText: attendee, eventCreatorName: event.creator_name!, eventCreatorImage: "\(pic)")

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "EventDetail"
        {
            let index:NSIndexPath = self.eventsTableView.indexPathForSelectedRow()!
            var navigationController = segue.destinationViewController as UINavigationController
            var detailEventViewController = navigationController.viewControllers[0] as DetailEventViewController
            var event:Event = events[index.row]
            detailEventViewController.event = Event(
                eID: event.eventID!,
                name: event.name!,
                description: event.description!,
                duration: event.duration!,
                email: event.creator_email!,
                creator_name: event.creator_name!,
                attendees: event.attendees!,
                sd: event.start_date!,
                ed: event.end_date!,
                dd: event.decide_by_date!,
                status: event.status!,
                timeSlots: event.timeSlots!//, image: event.image!)
            )
        }
    }

    
    

}


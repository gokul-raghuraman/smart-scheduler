//
//  Event.swift
//  Smart Scheduler
//
//  Created by song on 3/5/15.
//  Copyright (c) 2015 ___Zazu Labs___. All rights reserved.
//

import Foundation
import JSONJoy


struct CurrentUser: JSONJoy {
    var firstName: String?
    var lastName: String?
    var email: String?
    init() {
        
    }
    init(_ decoder: JSONDecoder) {
        firstName = decoder["first_name"].string
        lastName = decoder["last_name"].string
        email = decoder["email"].string
    }

}

struct User: JSONJoy {
    var token : String?
    var currentUser: CurrentUser?
    init() {
        
    }
    init(_ decoder: JSONDecoder) {
        token = decoder["token"].string
        currentUser = CurrentUser(decoder["user"])
    }
}


struct Event: JSONJoy {
    var eventID: Int?
    var name: String?
    var description: String?
    var duration: String?
    var creator_email: String?
    var creator_name: String?
    var attendees: Array<String>?
    var start_date: String?
    var end_date: String?
    var decide_by_date: String?
    var status: String?
    var timeSlots: Array<String>?
    //var image: String?
    
    init(eID: Int, name: String, description: String, duration: String, email: String, creator_name: String, attendees: Array<String>, sd: String, ed: String, dd: String, status: String, timeSlots: Array<String>)//, image: String)
    {
        self.eventID = eID
        self.name = name
        self.description = description
        self.duration = duration
        self.creator_email = email
        self.creator_name = creator_name
        self.attendees = attendees
        self.start_date = sd
        self.end_date = ed
        self.decide_by_date = dd
        self.status = status
        self.timeSlots = timeSlots
        //self.image = image
    }
        init(_ decoder: JSONDecoder) {
            eventID = decoder["id"].integer
            name = decoder["name"].string
            description = decoder["description"].string
            duration = decoder["duration"].string
            creator_name = decoder["creator_name"].string
            creator_email = decoder["creator_email"].string
            start_date = decoder["start_date"].string
            end_date = decoder["end_date"].string
            decide_by_date = decoder["decide_by_date"].string
            status = decoder["status"].string
            let s = decoder["timeSlots"].string
            let ss = s?.componentsSeparatedByString(",")
            timeSlots = ss
            let a = decoder["invitee"].string
            let aa = a?.componentsSeparatedByString(",")
            attendees = aa
        }

}
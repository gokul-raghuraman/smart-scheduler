//
//  TimeSlotHelper.swift
//  Zazu Screens
//
//  Created by song on 4/4/15.
//  Copyright (c) 2015 Zazu Labs. All rights reserved.
//

import Foundation

class TimeSlotHelper {

func generateAvalableTimeSlots(timeSlots: Array<NSDate>, events: Array<calendarEvent>, eventDuration: Int) ->Array<NSDate>
{
    
    var result = Array<NSDate>()
    var adjustedCalendarEvents = events
    var i = 0
    if !adjustedCalendarEvents.isEmpty {
        if timeSlots[i].compare(adjustedCalendarEvents[0].event_start_date!) == NSComparisonResult.OrderedDescending {
            while i < timeSlots.count && timeSlots[i].compare(adjustedCalendarEvents[0].event_end_date!) == NSComparisonResult.OrderedAscending {
                i++
            }
            adjustedCalendarEvents.removeAtIndex(0)
        }
    }
    for (i; i < timeSlots.count; i++) {
        if !adjustedCalendarEvents.isEmpty {
            if timeSlots[i].isEqualToDate(adjustedCalendarEvents[0].event_start_date!) {
                while i < timeSlots.count && timeSlots[i].compare(adjustedCalendarEvents[0].event_end_date!) == NSComparisonResult.OrderedAscending {
                    i++
                }
                adjustedCalendarEvents.removeAtIndex(0)
                //adjustedCalendarEvents.removeAtIndex(0)
                if i == timeSlots.count {
                    break
                } else {
                    i--
                }
            }
            
        }
        result.append(timeSlots[i])
    }
    //println(result)
    var finalTimeSlots = Array<NSDate>()
    for(i = 0; i < result.count; i++)
    {
        let record = i
        var sum = 0
        while i < result.count {
            if eventDuration == timeSlotInterval {
                //println(", result \(result[record])")
                finalTimeSlots.append(result[record])
                break
            } else {
                if i == result.count-1 {
                    break
                }
                let diff = result[i].minutesBeforeDate(result[i+1])
                sum += diff
                if diff == timeSlotInterval {
                    if sum+timeSlotInterval >= eventDuration {
                        //println(", result \(result[record])")
                        finalTimeSlots.append(result[record])
                        break
                    } else {
                        i++
                    }
                } else {
                    //println("not consecutive time slot")
                    break
                }
            }
        }
        i = record
        
    }
    return finalTimeSlots
}
func adjustment() ->Array<calendarEvent>{
    var events = Array<calendarEvent>()
    for eachEvent in calendarEventTimeSlot {
        let title = eachEvent.event_title
        let startDate = adjustEventStartOnDateTime(eachEvent.event_start_date)
        let endDate = adjustEventEndOnDateTime(eachEvent.event_end_date)
        let newEventDate = calendarEvent(title: title!, start_date: startDate!, end_date: endDate!)
        events.append(newEventDate)
    }
    return events
}
func adjustEventStartOnDateTime(startTime: NSDate?) ->NSDate? {
    var result:NSDate?
    if let s = startTime?.seconds() {
        result = startTime?.dateBySubtractingSeconds(s)
    }
    if let m = result?.minute() {
        var adjust = Int()
        if m < 30 {
            result = result?.dateBySubtractingMinutes(m)
        } else if m > 30 && m < 60 {
            let temp = 60 - m
            result = result?.dateBySubtractingMinutes(temp)
        }
    }
    return result
}
func adjustEventEndOnDateTime(endTime: NSDate?) ->NSDate? {
    var result:NSDate?
    if let s = endTime?.seconds() {
        result = endTime?.dateBySubtractingSeconds(s)
    }
    if let m = result?.minute() {
        var adjust = Int()
        if m < 30 {
            adjust = 30 - m
            result = result?.dateByAddingMinutes(adjust)
        } else if m > 30 && m < 60 {
            let temp = result?.dateBySubtractingMinutes(m)
            result = temp?.dateByAddingHours(1)
        }
    }
    return result
}
}
//
//  DateFormatting.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension Date {
    static func convertToDate(isoDateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if isoDateString.matches("[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{6}Z") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        } else if isoDateString.matches("[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        }
        return dateFormatter.date(from: isoDateString)!
    }
    
    static func h(isoDateString: String) -> String{
        let formatter = DateFormatter()
        let date = convertToDate(isoDateString: isoDateString)
        formatter.dateFormat = "HH:mm aa"
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        return formatter.string(from: date)
    }
    
    static func startOfToday() -> Date{
        let formatter = DateFormatter()
        let date = Date()
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString: String = formatter.string(from: date)
        let dateToday: Date = formatter.date(from: todayString)!
        
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let todayStringUTC = formatter.string(from: dateToday)
        let dateTodayInUTC = formatter.date(from: todayStringUTC)!
        return dateTodayInUTC
    }
    
    static func todayYesterdayWeekDay(isoDateString: String) -> String{
        let date = convertToDate(isoDateString: isoDateString)
        let startOfDay = startOfToday()
        
        if date > startOfDay{
            return "TODAY"
        } else if date > Calendar.current.date(byAdding: .day, value: -1, to: startOfDay)!{
            return "YESTERDAY"
        } else if date > Calendar.current.date(byAdding: .day, value: -7, to: startOfDay)!{
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date).uppercased()
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
            return formatter.string(from: date)
        }
    }
    
    static func hhmmHappenedNowTodayYesterdayWeekDay(start: String, end: String) -> String{
        let startDate = convertToDate(isoDateString: start)
        let endDate = convertToDate(isoDateString: end)
        let now = Date()
        let startOfDay = startOfToday()
        
        if now < Calendar.current.date(byAdding: .day, value: -2, to: startDate)!{
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
            return formatter.string(from: startDate)
        } else if now < Calendar.current.date(byAdding: .day, value: -1, to: startDate)!{
            return "TOMORROW"
        } else if now < startDate{
            return "TODAY"
        } else if startDate <= now && now <= endDate{
            return "HAPPENING NOW"
        } else if startDate > startOfDay{
            return "HAPPENED TODAY"
        } else if startDate > Calendar.current.date(byAdding: .day, value: -1, to: startOfDay)!{
            return "YESTERDAY"
        } else if startDate > Calendar.current.date(byAdding: .day, value: -7, to: startOfDay)!{
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return "Last " + formatter.string(from: startDate).uppercased()
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
            return formatter.string(from: startDate)
        }
    }
    
    static func timeRange(start: String, end: String) -> String{
        let startDate = convertToDate(isoDateString: start)
        let endDate = convertToDate(isoDateString: end)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm aa"
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        return formatter.string(from: startDate) + "-" + formatter.string(from: endDate)
    }
    
    static func hYesterdayWeekDay(isoDateString: String) -> String{
        let date = convertToDate(isoDateString: isoDateString)
        let startOfDay = startOfToday()
        
        if date > startOfDay{
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm aa"
            formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
            return formatter.string(from: date)
        } else if date > Calendar.current.date(byAdding: .day, value: -1, to: startOfDay)!{
            return "YESTERDAY"
        } else if date > Calendar.current.date(byAdding: .day, value: -7, to: startOfDay)!{
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date).uppercased()
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
            return formatter.string(from: date)
        }
    }
}

//
//  Date+Extension.swift
//  TwitterLite
//
//  Created by Nana on 4/16/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import Foundation

extension Date {

    var readableValue: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: self)
    }

    var relativeValue: String {

        let timeInterval = Int(abs(self.timeIntervalSinceNow))

        if timeInterval < 60 {
            return "\(timeInterval)s"
        } else if timeInterval < 3600 {
            return "\(timeInterval/60)m"
        } else if timeInterval < 86400 {
            return "\(Int(timeInterval/1440))h"
        } else {

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: self)
        }
    }
}

//
//  DateExtension.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 15.02.21.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

//
//  Date.swift
//  ImageFeed
//
//  Created by Алия Давлетова on 25.06.2023.
//

import Foundation

private let dateTimeDefaultFormatter = ISO8601DateFormatter()

extension Date {
    var dateTimeString: String { dateTimeDefaultFormatter.string(from: self) }
}

extension String {
    var stringDateTime: Date? {
        dateTimeDefaultFormatter.date(from: self)
    }
}

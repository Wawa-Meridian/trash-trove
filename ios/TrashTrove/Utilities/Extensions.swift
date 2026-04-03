import SwiftUI

// MARK: - Color Hex Initializer

extension Color {
    /// Initialize a Color from a hex integer value (e.g., 0xFDF8F0)
    init(hex: UInt32, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    /// Initialize a Color from a hex string (e.g., "#FDF8F0" or "FDF8F0")
    init(hexString: String, opacity: Double = 1.0) {
        let sanitized = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var hexValue: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&hexValue)

        self.init(hex: UInt32(hexValue), opacity: opacity)
    }
}

// MARK: - Date Formatting

extension Date {
    /// Format as ISO 8601 date string (yyyy-MM-dd)
    var isoDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }

    /// Format as a human-readable date (e.g., "Saturday, March 15, 2026")
    var longDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Format as a short date (e.g., "Mar 15, 2026")
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Format as a relative date (e.g., "Today", "Tomorrow", "In 3 days")
    var relativeDateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Whether the date is today or in the future
    var isUpcoming: Bool {
        Calendar.current.isDateInToday(self) || self > Date()
    }
}

// MARK: - String Extensions

extension String {
    /// Trim whitespace and newlines
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Check if the string is a valid email address
    var isValidEmail: Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    /// Check if the string is a valid US zip code (5 digits or 5+4 format)
    var isValidZipCode: Bool {
        let pattern = #"^\d{5}(-\d{4})?$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    /// Convert an ISO date string to a Date
    var isoDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: self)
    }

    /// Convert a time string (HH:mm) to a display format (h:mm a)
    var formattedTime: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        guard let date = inputFormatter.date(from: self) else { return self }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        return outputFormatter.string(from: date)
    }

    /// Get the full state name from a 2-letter state code
    var stateName: String? {
        US_STATES[self.uppercased()]
    }
}

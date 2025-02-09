//
//  DateFormats.swift
//  Epoch2Date
//
//  Created by Sai Yalamarty on 1/25/25.
//

import Foundation
import SwiftDate

struct DateFormats {
    static let dateFormats: [String] = SwiftDate.autoFormats + [
        // ISO8601 and Precise Formats
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ", // ISO8601 with milliseconds and timezone
        "yyyy-MM-dd'T'HH:mm:ss.SSS",  // ISO8601 with milliseconds
        "yyyy-MM-dd'T'HH:mm:ssZ",     // ISO8601 with seconds and timezone
        "yyyy-MM-dd'T'HH:mm:ss",      // ISO8601 basic
        "yyyy-MM-dd'T'HH:mm",         // ISO8601 without seconds
        "yyyy-MM-dd HH:mm:ss.SSS",    // ISO8601 with millisecond precision
        "yyyy-MM-dd HH:mm:ss Z",      // ISO8601 with time zone
        "yyyy-MM-dd HH:mm:ss",        // Standard ISO8601 date with time
        "yyyy-MM-dd HH:mm",        // Standard ISO8601 date with time
        
        // Date with Time Formats (AM/PM first, then 24-hour)
        "yyyy/MM/dd hh:mm:ss a",   // Slash-separated with time (12-hour AM/PM)
        "yyyy/MM/dd HH:mm:ss",     // Slash-separated with time (24-hour)
        "yyyy/MM/dd hh:mm a",   // Slash-separated with time (12-hour AM/PM)
        "yyyy/MM/dd HH:mm",     // Slash-separated with time (24-hour)
        "MM/dd/yyyy hh:mm:ss a",   // Month-first with time (12-hour AM/PM)
        "MM/dd/yyyy HH:mm:ss",     // Month-first with time (24-hour)
        "MM/dd/yyyy hh:mm a",   // Month-first with time (12-hour AM/PM)
        "MM/dd/yyyy HH:mm",     // Month-first with time (24-hour)
        "dd/MM/yyyy hh:mm:ss a",   // Day-first with time (12-hour AM/PM)
        "dd/MM/yyyy HH:mm:ss",     // Day-first with time (24-hour)
        "dd/MM/yyyy hh:mm a",   // Day-first with time (12-hour AM/PM)
        "dd/MM/yyyy HH:mm",     // Day-first with time (24-hour)
        "MM.dd.yyyy hh:mm:ss a",   // Dot-separated with time (12-hour AM/PM)
        "MM.dd.yyyy HH:mm:ss",     // Dot-separated with time (24-hour)
        "MM.dd.yyyy hh:mm a",   // Dot-separated with time (12-hour AM/PM)
        "MM.dd.yyyy HH:mm",     // Dot-separated with time (24-hour)
        "dd.MM.yyyy hh:mm:ss a",   // Dot-separated with time (12-hour AM/PM)
        "dd.MM.yyyy HH:mm:ss",     // Dot-separated with time (24-hour)
        "dd.MM.yyyy hh:mm a",   // Dot-separated with time (12-hour AM/PM)
        "dd.MM.yyyy HH:mm",     // Dot-separated with time (24-hour)
        
        // Time-Only Formats (AM/PM first, then 24-hour)
        "hh:mm:ss a Z",            // 12-hour time with AM/PM and time zone
        "hh:mm:ss a",              // 12-hour time with seconds and AM/PM
        "hh:mm a Z",               // 12-hour time with AM/PM and time zone
        "hh:mm a",                 // 12-hour time without seconds
        "HH:mm:ss Z",              // 24-hour time with seconds and time zone
        "HH:mm:ss",                // 24-hour time with seconds
        "HH:mm Z",                 // 24-hour time with time zone
        "HH:mm",                   // 24-hour time without seconds
        "HHmm",                    // Compact time (e.g., 1530)
        
        // US and European Date Formats (Month-first, then Day-first)
        "MM/dd/yyyy",              // US-style date
        "dd/MM/yyyy",              // European-style date
        "MM.dd.yyyy",              // Dot-separated date (US format)
        "dd.MM.yyyy",              // Dot-separated date (European format)
        "yyyy/MM/dd",              // Slash-separated date
        "yyyyMMdd",                // Compact date (no separators)
        
        // US Formats with Full and Abbreviated Month Names
        "MMMM d, yyyy",            // Full month name, day, year (e.g., January 22, 2025)
        "MMM d, yyyy",             // Abbreviated month name, day, year (e.g., Jan 22, 2025)
        
        // Week-Based Formats
        "yyyy-'W'ww",              // Week-based date (e.g., 2025-W03)
        "yyyy-'W'ww-E",            // Week-based with day (e.g., 2025-W03-2)
        
        // Full and Abbreviated Day Name Formats
        "EEE, MMM d, yyyy",        // Abbreviated day, abbreviated month, day, year
        "EEEE, MMMM d, yyyy",      // Full day, full month, day, year
        
        // Month and Year Formats
        "MMMM yyyy",               // Full month and year (e.g., January 2025)
        "MMM yyyy",                // Abbreviated month and year (e.g., Jan 2025)
        
        // Miscellaneous Formats
        "d MMM yyyy",              // Day, abbreviated month, year
        "MMddyyyy"                 // Compact month, day, year (e.g., 01222025)
    ]
}

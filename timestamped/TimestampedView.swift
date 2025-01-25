//
//  Timestamped.swift
//  timestamped
//
//  Created by Sai Yalamarty on 1/22/25.
//

import SwiftUI
import SwiftDate

struct TimestampedView: View {
    @EnvironmentObject var preferences: Preferences
    @State private var preferencesWindow: NSWindow?
    @State private var rawInputText: String = "now"
    @State private var inputText: String = ""
    @State private var result: String = ""
    @State private var showCopiedFeedback: Bool = false
    @State private var showingDatePicker: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Input Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Enter Timestamp")
                        .font(.headline)
                        .padding(.leading, 2)
                    
                    Spacer()
                    
                    // Settings Gear Icon
                    Button(action: openPreferencesWindow) {
                        Image(systemName: "gearshape.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Open Preferences")
                    
                    // Quit Button
                    Button(action: { NSApplication.shared.terminate(nil) }) {
                        Text("Quit")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                    }
                    .buttonStyle(.plain)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
                    .help("Quit App")
                }
                
                HStack {
                    TextField("Enter timestamp or date...", text: $rawInputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                        .onChange(of: rawInputText) { _, _ in
                            identifyAndConvert()
                        }
                    
                    if !rawInputText.isEmpty {
                        Button(action: {
                            rawInputText = ""
                            identifyAndConvert()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .help("Enter 'now', Unix timestamp, or date (yyyy-MM-dd HH:mm:ss)")
                
                // Quick preset buttons
                HStack(spacing: 12) {
                    ForEach(["now", "tomorrow", "yesterday"], id: \.self) { preset in
                        Button(preset.capitalized) {
                            rawInputText = preset
                            identifyAndConvert()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    // Add clipboard preset button
                    if let clipboardString = NSPasteboard.general.string(forType: .string) {
                        Button("Paste from clipboard") {
                            rawInputText = clipboardString
                            identifyAndConvert()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .font(.body)
            }

            Divider()

            // Result Section
            if !result.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Result")
                        .font(.headline)
                        .padding(.leading, 2)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(result)
                                .font(.system(.title3, design: .monospaced))
                                .textSelection(.enabled)
                            
                            Divider()
                                .opacity(0.5)
                            
                            Text(inputText)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(result, forType: .string)
                            withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                                showCopiedFeedback = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showCopiedFeedback = false
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: showCopiedFeedback ? "checkmark" : "doc.on.doc")
                                    .frame(width: 8, alignment: .center)
                                
                                Text(showCopiedFeedback ? "Copied!" : "Copy")
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .frame(width: 64, height: 32)
                            .padding(.horizontal, 10)
                            .background(showCopiedFeedback ? Color.green.opacity(0.1) : Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                        .help("Copy to clipboard")
                    }
                    .padding(12)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .frame(width: 450)
        .onAppear {
            identifyAndConvert()
        }
        .onChange(of: preferences.timestampUnit) { _, _ in
            identifyAndConvert()
        }
        .onChange(of: preferences.timeZone) { _, _ in
            identifyAndConvert()
        }
        .onChange(of: preferences.dateInputOrder) { _, _ in
            identifyAndConvert()
        }
        .onChange(of: preferences.dateOutputFormat) { _, _ in
            identifyAndConvert()
        }
        .onChange(of: preferences.timeOutputFormat) { _, _ in
            identifyAndConvert()
        }
        .focusable(false)
    }
    
    func openPreferencesWindow() {
        if preferencesWindow == nil {
            // Get the main screen dimensions
            let screenFrame = NSScreen.main?.frame ?? NSRect.zero
            let windowWidth: CGFloat = 460
            let windowHeight: CGFloat = 200

            // Calculate the center position
            let centerX = screenFrame.midX - (windowWidth / 2)
            let centerY = screenFrame.midY - (windowHeight / 2)

            // Create the preferences window
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: centerX, y: centerY, width: windowWidth, height: windowHeight),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            preferencesWindow?.title = "timestamped App Preferences"
            preferencesWindow?.isReleasedWhenClosed = false
            preferencesWindow?.contentView = NSHostingView(rootView: PreferencesView().environmentObject(preferences))
        }

        // Activate the app and bring the window to the front
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindow?.makeKeyAndOrderFront(nil)
    }
    
    let moreFormats: [String] = SwiftDate.autoFormats + [
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
    
    func identifyAndConvert() {
        inferRawInput()

        if inputText.isEmpty {
            result = "No input"
            inputText = "..."
            return
        }

        if let unixTimestamp = Double(inputText) {
            // Input is a Unix timestamp
            let date: Date
            if preferences.timestampUnit == "Milliseconds" {
                date = Date(timeIntervalSince1970: unixTimestamp / 1000) // Convert milliseconds to seconds
            } else {
                date = Date(timeIntervalSince1970: unixTimestamp)
            }
            
            let formatter = DateFormatter()
            
            // Check if the user wants to display time
            if preferences.timeOutputFormat == "Don't display time" {
                formatter.dateFormat = preferences.dateOutputFormat
            } else {
                formatter.dateFormat = "\(preferences.dateOutputFormat) \(preferences.timeOutputFormat)"
            }
            
            formatter.timeZone = TimeZone(identifier: preferences.timeZone) ?? .current
            result = formatter.string(from: date) // Convert Unix to formatted date and time
        } else {
            // Input is a date-time string
            if let timeZone = TimeZone(identifier: preferences.timeZone) {
                let region = Region(calendar: Calendar.current, zone: timeZone, locale: Locale.current)
                if let parsedDate = inputText.toDate(moreFormats, region: region) {
                    // Automatically parse input with SwiftDate
                    let unixTimestamp: Double
                    if preferences.timestampUnit == "Milliseconds" {
                        unixTimestamp = parsedDate.date.timeIntervalSince1970 * 1000 // Convert seconds to milliseconds
                    } else {
                        unixTimestamp = parsedDate.date.timeIntervalSince1970
                    }
                    result = String(Int(unixTimestamp)) // Output Unix timestamp
                } else {
                    result = "Invalid date/time format"
                }
            } else {
                result = "Invalid time zone in preferences"
            }
        }
    }

    func inferRawInput() {
        inputText = rawInputText.trimmingCharacters(in: .whitespaces).lowercased()

        // Create a date formatter using user preferences
        let formatter = DateFormatter()
        formatter.dateFormat = preferences.dateOutputFormat
        formatter.timeZone = TimeZone(identifier: preferences.timeZone) ?? .current

        let currentDate: Date
        if ["now", "current", "today"].contains(inputText) {
            currentDate = Date()
        } else if inputText == "tomorrow" {
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        } else if inputText == "yesterday" {
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        } else {
            return
        }

        // Convert the date to a Unix timestamp based on the user's preference
        let unixTimestamp: Double
        if preferences.timestampUnit == "Milliseconds" {
            unixTimestamp = currentDate.timeIntervalSince1970 * 1000 // Convert seconds to milliseconds
        } else {
            unixTimestamp = currentDate.timeIntervalSince1970
        }
        inputText = String(Int(unixTimestamp))
    }
}

#Preview {
    TimestampedView()
        .environmentObject(Preferences())
}

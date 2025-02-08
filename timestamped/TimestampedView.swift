//
//  Timestamped.swift
//  timestamped
//
//  Created by Sai Yalamarty on 1/22/25.
//

import SwiftUI
import SwiftDate
import LaunchAtLogin

struct TimestampedView: View {
    @EnvironmentObject var preferences: Preferences
    @State private var rawInputText: String = ""
    @State private var inputText: String = ""
    @State private var result: String = ""
    @State private var showCopiedFeedback: Bool = false
    @State private var showingDatePicker: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            inputSection
            Divider()
            if !result.isEmpty {
                resultSection
            }
        }
        .padding()
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
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            inputField
            presetButtons
        }
    }
    
    private var headerRow: some View {
        HStack {
            Text("Enter Timestamp")
                .font(.headline)
                .padding(.leading, 2)
            
            Spacer()
            
            settingsButton
        }
    }
    
    private var settingsButton: some View {
        Menu {
            Group {
                timestampUnitPicker
                timeZonePicker
                dateInputOrderPicker
                dateOutputFormatPicker
                timeOutputFormatPicker
                
                Divider()
                
                launchAtLogin
                
                Divider()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .help("Preferences")
    }
    
    private var timestampUnitPicker: some View {
        Picker("Timestamp Unit", selection: $preferences.timestampUnit) {
            ForEach(["Seconds", "Milliseconds"], id: \.self) { unit in
                Text(unit).tag(unit)
            }
        }
    }
    
    private var timeZonePicker: some View {
        Picker("Time Zone", selection: $preferences.timeZone) {
            Text(preferences.timeZone)
                .tag(preferences.timeZone)
            
            Divider()
            
            ForEach(TimeZone.knownTimeZoneIdentifiers.sorted().filter { $0 != preferences.timeZone }, id: \.self) { timeZone in
                Text(timeZone).tag(timeZone)
            }
        }
    }
    
    private var dateInputOrderPicker: some View {
        Picker("Date Input Order", selection: $preferences.dateInputOrder) {
            ForEach(["Month/Day/Year", "Day/Month/Year"], id: \.self) { order in
                Text(order).tag(order)
            }
        }
    }
    
    private var dateOutputFormatPicker: some View {
        Picker("Date Output Format", selection: $preferences.dateOutputFormat) {
            ForEach([
                "MMMM d, yyyy",
                "MMM d, yyyy", 
                "MM/dd/yyyy",
                "dd/MM/yyyy",
                "yyyy-MM-dd"
            ], id: \.self) { format in
                Text(format).tag(format)
            }
        }
    }
    
    private var timeOutputFormatPicker: some View {
        Picker("Time Output Format", selection: $preferences.timeOutputFormat) {
            ForEach([
                "Don't display time",
                "h:mm:ss a",
                "h:mm a",
                "H:mm:ss",
                "H:mm"
            ], id: \.self) { format in
                Text(format).tag(format)
            }
        }
    }
    
    private var launchAtLogin: some View {
        LaunchAtLogin.Toggle()
    }
    
    private var inputField: some View {
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
    }
    
    private func convertPresetToDate(for preset: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm:ss a"
        formatter.timeZone = TimeZone(identifier: preferences.timeZone) ?? .current
        
        let date: Date
        switch preset.lowercased() {
        case "now", "current", "today":
            date = Date()
        case "tomorrow":
            date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        case "yesterday":
            date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        default:
            date = Date()
        }
        
        return formatter.string(from: date)
    }
    
    private var presetButtons: some View {
        HStack(spacing: 12) {
            ForEach(["now", "tomorrow", "yesterday"], id: \.self) { preset in
                Button(action: {
                    rawInputText = convertPresetToDate(for: preset)
                    identifyAndConvert()
                }) {
                    Text(preset.capitalized)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .contentShape(RoundedRectangle(cornerRadius: 4))
                        .fixedSize(horizontal: true, vertical: false)
                        .lineLimit(1)
                }
                .buttonStyle(.borderless)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Add clipboard preset button
            if let clipboardString = NSPasteboard.general.string(forType: .string) {
                Button(action: {
                    rawInputText = clipboardString
                    identifyAndConvert()
                }) {
                    Text("Paste from clipboard")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .contentShape(RoundedRectangle(cornerRadius: 4))
                        .fixedSize(horizontal: true, vertical: false)
                        .lineLimit(1)
                }
                .buttonStyle(.borderless)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .font(.body)
    }
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Result")
                .font(.headline)
                .padding(.leading, 2)
            
            HStack(spacing: 12) {
                Text(result)
                    .font(.system(.title3, design: .monospaced))
                    .textSelection(.enabled)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                
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
                    ZStack {
                        Image(systemName: "square.on.square")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .opacity(showCopiedFeedback ? 0 : 1)
                            .scaleEffect(showCopiedFeedback ? 0.8 : 1)
                        
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .opacity(showCopiedFeedback ? 1 : 0)
                            .scaleEffect(showCopiedFeedback ? 1 : 0.8)
                    }
                    .padding(8)
                    .background(showCopiedFeedback ? Color.green.opacity(0.1) : Color.secondary.opacity(0.1))
                    .clipShape(Circle())
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
                date = Date(timeIntervalSince1970: unixTimestamp / 1000)
            } else {
                date = Date(timeIntervalSince1970: unixTimestamp)
            }
            
            let formatter = DateFormatter()
            
            if preferences.timeOutputFormat == "Don't display time" {
                formatter.dateFormat = preferences.dateOutputFormat
            } else {
                formatter.dateFormat = "\(preferences.dateOutputFormat) \(preferences.timeOutputFormat)"
            }
            
            formatter.timeZone = TimeZone(identifier: preferences.timeZone) ?? .current
            result = formatter.string(from: date)
        } else {
            // Input is a date-time string
            if let timeZone = TimeZone(identifier: preferences.timeZone) {
                let region = Region(calendar: Calendar.current, zone: timeZone, locale: Locale.current)
                
                // Filter formats based on dateInputOrder preference
                let filteredFormats = DateFormats.dateFormats.filter { format in
                    switch preferences.dateInputOrder {
                    case "Month/Day/Year":
                        // Include formats that start with month or don't have explicit date order
                        return !format.contains("dd/MM") && !format.contains("dd.MM")
                    case "Day/Month/Year":
                        // Include formats that start with day or don't have explicit date order
                        return !format.contains("MM/dd") && !format.contains("MM.dd")
                    default:
                        return true
                    }
                }
                
                if let parsedDate = inputText.toDate(filteredFormats, region: region) {
                    let unixTimestamp: Double
                    if preferences.timestampUnit == "Milliseconds" {
                        unixTimestamp = parsedDate.date.timeIntervalSince1970 * 1000
                    } else {
                        unixTimestamp = parsedDate.date.timeIntervalSince1970
                    }
                    result = String(Int(unixTimestamp))
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
        
        if ["now", "current", "today", "tomorrow", "yesterday"].contains(inputText) {
            inputText = convertPresetToDate(for: inputText)
            if let date = inputText.toDate() {
                let unixTimestamp: Double
                if preferences.timestampUnit == "Milliseconds" {
                    unixTimestamp = date.date.timeIntervalSince1970 * 1000
                } else {
                    unixTimestamp = date.date.timeIntervalSince1970
                }
                inputText = String(Int(unixTimestamp))
            }
        }
    }
}

#Preview {
    TimestampedView()
        .environmentObject(Preferences())
}

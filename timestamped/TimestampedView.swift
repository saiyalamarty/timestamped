//
//  Timestamped.swift
//  timestamped
//
//  Created by Sai Yalamarty on 1/22/25.
//

import SwiftUI

struct TimestampedView: View {
    @State private var rawInputText: String = "now"
    @State private var inputText: String = ""
    @State private var result: String = ""
    @State private var showCopiedFeedback: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter Timestamp")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("Enter timestamp or date...", text: $rawInputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(.body))
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
                HStack(spacing: 8) {
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
                .font(.caption)
            }

            Divider()

            // Result Section
            if !result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Result")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(result)
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                            
                            Divider()
                                .opacity(0.5)
                            
                            Text(inputText)
                                .font(.system(.callout))
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
                                    .frame(width: 16, alignment: .center)
                                
                                Text(showCopiedFeedback ? "Copied!" : "Copy")
                                    .font(.caption)
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
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
        .padding(8)
        .frame(width: 360, height: 220)
        .onAppear {
            identifyAndConvert()
        }
        .focusable(false)
    }
    
    func identifyAndConvert() {
        inferRawInput()
        
        if inputText.isEmpty {
            result = "No input"
            inputText = "..."
            return
        }
        
        if inputText.allSatisfy({ $0.isNumber }) {
            // Input is a Unix timestamp
            if let timestamp = Double(inputText) {
                let date = Date(timeIntervalSince1970: timestamp)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // Removed timezone
                formatter.timeZone = .current  // Use local timezone
                result = formatter.string(from: date)
            } else {
                result = "Invalid Unix timestamp"
            }
        } else {
            // Input is a datetime string
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = .current
            if let date = formatter.date(from: inputText) {
                let timestamp = date.timeIntervalSince1970
                result = String(Int(timestamp))
            } else {
                result = "Invalid date format"
            }
        }
    }

    func inferRawInput() {
        inputText = rawInputText.trimmingCharacters(in: .whitespaces).lowercased()

        if ["now", "current", "today"].contains(inputText) {
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = .current
            inputText = formatter.string(from: currentDate)
            return
        }
        
        if inputText == "tomorrow" {
            let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = .current
            inputText = formatter.string(from: tomorrowDate)
            return
        }
        
        if inputText == "yesterday" {
            let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = .current
            inputText = formatter.string(from: yesterdayDate)
            return
        }
    }
}

#Preview {
    TimestampedView()
}

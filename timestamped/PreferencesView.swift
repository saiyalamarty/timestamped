//
//  PreferencesView.swift
//  timestamped
//
//  Created by Sai Yalamarty on 1/24/25.
//

import Foundation
import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var preferences: Preferences

    let timestampUnits = ["Seconds", "Milliseconds"]
    let timeZones = TimeZone.knownTimeZoneIdentifiers.sorted()
    let dateInputOrders = ["Month/Day/Year", "Day/Month/Year"]
    let dateOutputFormats = [
        "MMMM d, yyyy",
        "ddd, MMMM d, yyyy",
        "MMM d, yyyy",
        "M/d/yyyy",
        "M/d/yy",
        "d/M/yyyy",
        "d/M/yy",
        "M-d-yyyy",
        "d-M-yyyy",
        "d-M-yy",
        "YYYY-MM-DDThh:mm:ss"
    ]
    let timeOutputFormats = [
        "Don't display time",
        "h:mm:ss a",
        "h:mm a",
        "H:mm:ss",
        "H:mm"
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Form {
                        Section {
                            HStack {
                                Spacer()
                                Text("Timestamp Unit:")
                                Picker("", selection: $preferences.timestampUnit) {
                                    ForEach(timestampUnits, id: \.self) { unit in
                                        Text(unit).tag(unit)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                Spacer()
                            }

                            HStack {
                                Spacer()
                                Text("Time Zone:")
                                Picker("", selection: $preferences.timeZone) {
                                    ForEach(timeZones, id: \.self) { timeZone in
                                        Text(timeZone).tag(timeZone)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                Spacer()
                            }

                            HStack {
                                Spacer()
                                Text("Date Input Order:")
                                Picker("", selection: $preferences.dateInputOrder) {
                                    ForEach(dateInputOrders, id: \.self) { order in
                                        Text(order).tag(order)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                Spacer()
                            }

                            HStack {
                                Spacer()
                                Text("Date Output Format:")
                                Picker("", selection: $preferences.dateOutputFormat) {
                                    ForEach(dateOutputFormats, id: \.self) { format in
                                        Text(format).tag(format)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                Spacer()
                            }

                            HStack {
                                Spacer()
                                Text("Time Output Format:")
                                Picker("", selection: $preferences.timeOutputFormat) {
                                    ForEach(timeOutputFormats, id: \.self) { format in
                                        Text(format).tag(format)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: geometry.size.width * 0.9)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(24)
            }
        }
    }
}

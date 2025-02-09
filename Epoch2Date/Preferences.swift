//
//  Preferences.swift
//  timestamped
//
//  Created by Sai Yalamarty on 1/24/25.
//

import Foundation

class Preferences: ObservableObject {
    @Published var timestampUnit: String {
        didSet {
            UserDefaults.standard.set(timestampUnit, forKey: "timestampUnit")
        }
    }
    @Published var timeZone: String {
        didSet {
            UserDefaults.standard.set(timeZone, forKey: "timeZone")
        }
    }
    @Published var dateInputOrder: String {
        didSet {
            UserDefaults.standard.set(dateInputOrder, forKey: "dateInputOrder")
        }
    }
    @Published var dateOutputFormat: String {
        didSet {
            UserDefaults.standard.set(dateOutputFormat, forKey: "dateOutputFormat")
        }
    }
    @Published var timeOutputFormat: String {
        didSet {
            UserDefaults.standard.set(timeOutputFormat, forKey: "timeOutputFormat")
        }
    }
    
    init() {
        self.timestampUnit = UserDefaults.standard.string(forKey: "timestampUnit") ?? "Seconds"
        self.timeZone = UserDefaults.standard.string(forKey: "timeZone") ?? TimeZone.current.identifier
        self.dateInputOrder = UserDefaults.standard.string(forKey: "dateInputOrder") ?? "Month/Day/Year"
        self.dateOutputFormat = UserDefaults.standard.string(forKey: "dateOutputFormat") ?? "MMMM d, yyyy"
        self.timeOutputFormat = UserDefaults.standard.string(forKey: "timeOutputFormat") ?? "h:mm a"
    }
}

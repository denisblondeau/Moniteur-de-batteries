//
//  LocalNotifications.swift
//  Moniteur de batteries
//
//  Created by Denis Blondeau on 2022-10-28.
//

import UserNotifications

@MainActor
final class LocalNotifications: NSObject, ObservableObject {
    
    @Published var authorized = false
    
    private let center = UNUserNotificationCenter.current()
    
    func requestAuthorization() async throws {
        authorized = try await center.requestAuthorization(options: [.alert])
    }
    
    func sendNotification(model: CommonFieldsModel) async throws {
        
        let title = model.title.trim()
        let subtitle = model.subtitle.trim()
        let body = model.body.trim()
        
        let content = UNMutableNotificationContent()
        content.title = title.isEmpty ? "Pas de titre fourni" : title
        if !subtitle.isEmpty {
            content.subtitle = subtitle
        }
        if !body.isEmpty {
            content.body = body
        }
        
        if model.hasSound {
            content.sound = UNNotificationSound.default
        }
        
        if let number = Int(model.badge) {
            content.badge = NSNumber(value: number)
        }
        
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        try await center.add(request)
        
    }
}


extension String {
    
    /// Returns a new string made by removing from both ends of the String characters contained in a given character set.
    /// - Returns: Trimmed string.
    func trim() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

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
        authorized = try await center.requestAuthorization(options: [.badge, .sound, .alert])
    }
    
    func sendNotification(model: CommonFieldsModel) async throws {
        
        let title = model.title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let content = UNMutableNotificationContent()
        content.title = title.isEmpty ? "No Title Provided" : title
        
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

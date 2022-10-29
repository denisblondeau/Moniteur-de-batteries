import SwiftUI

class CommonFieldsModel: ObservableObject {
    @Published var title = ""
    @Published var subtitle = ""
    @Published var body = ""
    @Published var badge = ""
    @Published var isRepeating = false
    @Published var hasSound = false
    
    func reset() {
        title = ""
        subtitle = ""
        body = ""
        badge = ""
        isRepeating = false
        hasSound = false
    }
}

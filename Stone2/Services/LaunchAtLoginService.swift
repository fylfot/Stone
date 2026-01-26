import Foundation
import ServiceManagement

@Observable
final class LaunchAtLoginService {
    private(set) var isEnabled: Bool = false
    private(set) var status: SMAppService.Status = .notRegistered

    init() {
        updateStatus()
    }

    func updateStatus() {
        status = SMAppService.mainApp.status
        isEnabled = status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            updateStatus()
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
        }
    }

    var statusDescription: String {
        switch status {
        case .notRegistered:
            return "Not registered"
        case .enabled:
            return "Enabled"
        case .requiresApproval:
            return "Requires approval in System Settings"
        case .notFound:
            return "Helper not found"
        @unknown default:
            return "Unknown"
        }
    }
}

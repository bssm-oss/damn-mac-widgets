import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginService {
    private var service: SMAppService { .mainApp }

    var statusDescription: String {
        switch service.status {
        case .enabled:
            return "Enabled"
        case .requiresApproval:
            return "Enabled, awaiting approval"
        case .notRegistered:
            return "Disabled"
        case .notFound:
            return "Unavailable"
        @unknown default:
            return "Unknown"
        }
    }

    func enable() throws {
        try service.register()
    }

    func disable() throws {
        try service.unregister()
    }
}

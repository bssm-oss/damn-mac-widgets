import EventKit
import Foundation

struct CalendarEventSummary: Identifiable, Equatable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let calendarTitle: String
    let location: String?
    let isAllDay: Bool

    var timeRangeText: String {
        let formatter = Self.timeFormatter

        if isAllDay {
            return "All day"
        }

        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

enum CalendarServiceError: LocalizedError {
    case denied
    case unavailable

    var errorDescription: String? {
        switch self {
        case .denied:
            return "Calendar access is not available."
        case .unavailable:
            return "No calendar data was returned."
        }
    }
}

@MainActor
final class CalendarService {
    private let store = EKEventStore()

    var authorizationSummary: String {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            return "Calendar access not requested"
        case .restricted:
            return "Calendar access restricted"
        case .denied:
            return "Calendar access denied"
        case .fullAccess:
            return "Calendar access granted"
        case .writeOnly:
            return "Calendar access is write-only"
        @unknown default:
            return "Calendar access granted"
        }
    }

    func fetchUpcomingEvents(limit: Int = 5, daysAhead: Int = 7) async throws -> [CalendarEventSummary] {
        let status = EKEventStore.authorizationStatus(for: .event)

        if status == .notDetermined {
            do {
                let granted = try await store.requestFullAccessToEvents()
                guard granted else {
                    throw CalendarServiceError.denied
                }
            } catch {
                throw CalendarServiceError.denied
            }
        } else {
            switch status {
            case .restricted, .denied:
                throw CalendarServiceError.denied
            default:
                break
            }
        }

        guard let endDate = Calendar.current.date(byAdding: .day, value: daysAhead, to: .now) else {
            throw CalendarServiceError.unavailable
        }

        let calendars = store.calendars(for: .event)
        let predicate = store.predicateForEvents(withStart: .now, end: endDate, calendars: calendars)

        let events = store.events(matching: predicate)
            .filter { !$0.isDetached }
            .sorted { $0.startDate < $1.startDate }

        guard !events.isEmpty else {
            return []
        }

        return events.prefix(limit).map { event in
            CalendarEventSummary(
                id: event.eventIdentifier ?? UUID().uuidString,
                title: event.title ?? "Untitled event",
                startDate: event.startDate,
                endDate: event.endDate,
                calendarTitle: event.calendar.title,
                location: event.location,
                isAllDay: event.isAllDay
            )
        }
    }
}

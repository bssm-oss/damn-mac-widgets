import SwiftUI

struct CalendarWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager

    var body: some View {
        WidgetChrome(kind: .calendar) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(widgetManager.calendarStatusText)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.62))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Button("Refresh") {
                        widgetManager.refreshCalendar()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                }

                if widgetManager.calendarEvents.isEmpty {
                    Text("No upcoming events are loaded yet.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.42))
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(widgetManager.calendarEvents) { event in
                                CalendarEventRow(event: event)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
    }
}

private struct CalendarEventRow: View {
    let event: CalendarEventSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(event.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

                Spacer(minLength: 8)

                Text(event.timeRangeText)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.68))
            }

            HStack(spacing: 6) {
                Text(event.calendarTitle)
                if let location = event.location, !location.isEmpty {
                    Text("•")
                    Text(location)
                }
            }
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.45))
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

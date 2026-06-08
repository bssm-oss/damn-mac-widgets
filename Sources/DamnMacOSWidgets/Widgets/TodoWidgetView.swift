import SwiftUI

struct TodoWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @State private var draft = ""
    @FocusState private var isDraftFocused: Bool

    private var todos: [TodoItem] {
        widgetManager.appState.todos
    }

    var body: some View {
        WidgetChrome(kind: .todo) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(todos.count) items")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(todos.filter(\.isDone).count) done")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                if todos.isEmpty {
                    Text("Nothing here yet.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                } else {
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(todos) { item in
                                TodoRow(item: item) {
                                    widgetManager.toggleTodo(item.id)
                                } onDelete: {
                                    widgetManager.removeTodo(item.id)
                                }
                            }
                        }
                    }
                }

                HStack(spacing: 8) {
                    TextField("Add a task…", text: $draft)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .focused($isDraftFocused)
                        .onSubmit(addDraft)
                        .background(Color.clear)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .liquidGlassBackground(cornerRadius: 12)

                    Button(action: addDraft) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(GlassActionButtonStyle(cornerRadius: 999, horizontalPadding: 0, verticalPadding: 0))
                    .foregroundStyle(.primary)
                    .background(.clear, in: Circle())
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func addDraft() {
        widgetManager.addTodo(draft)
        draft = ""
        isDraftFocused = true
    }
}

private struct TodoRow: View {
    let item: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isDone ? .primary : .secondary)
            }
            .buttonStyle(GlassActionButtonStyle(cornerRadius: 999, horizontalPadding: 4, verticalPadding: 4))

            Text(item.title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .buttonStyle(GlassActionButtonStyle(cornerRadius: 999, horizontalPadding: 4, verticalPadding: 4))
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .liquidGlassBackground(cornerRadius: 12)
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(isHovering ? 0.04 : 0))
        }
        .scaleEffect(isHovering ? 1.01 : 1.0)
        .onHover { isHovering = $0 }
        .animation(.snappy(duration: 0.18), value: isHovering)
    }
}

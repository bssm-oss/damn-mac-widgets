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
                        .liquidGlassBackground(cornerRadius: 12, tintOpacity: 0.02, strokeOpacity: 0.06)

                    Button(action: addDraft) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
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

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isDone ? .primary : .secondary)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .liquidGlassBackground(cornerRadius: 12, tintOpacity: 0.02, strokeOpacity: 0.06)
    }
}

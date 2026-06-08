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
                if todos.isEmpty {
                    Text("Nothing here yet.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
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
                        .font(.subheadline)
                        .focused($isDraftFocused)
                        .onSubmit(addDraft)

                    Button(action: addDraft) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
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
                    .foregroundStyle(item.isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.subheadline)
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tertiary)
        }
    }
}

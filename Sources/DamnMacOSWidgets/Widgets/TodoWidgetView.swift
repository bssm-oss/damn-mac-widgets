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
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Text("\(todos.filter(\.isDone).count) done")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(widgetManager.appState.todos.isEmpty ? .white.opacity(0.35) : .white.opacity(0.7))
                }

                if todos.isEmpty {
                    Text("Nothing here yet.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.45))
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
                        .foregroundStyle(.white)
                        .focused($isDraftFocused)
                        .onSubmit(addDraft)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Button(action: addDraft) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(widgetManager.appState.widgets[WidgetKind.todo.rawValue]?.isVisible == true ? WidgetKind.todo.accentColor : .white.opacity(0.7))
                    .background(WidgetKind.todo.accentColor.opacity(0.14), in: Circle())
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
                    .foregroundStyle(item.isDone ? WidgetKind.todo.accentColor : .white.opacity(0.35))
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .white.opacity(0.38) : .white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.35))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

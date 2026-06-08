import Foundation

struct LocalStore {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = appSupport.appendingPathComponent("damn-macos-widgets", isDirectory: true)
        self.init(
            fileURL: directory.appendingPathComponent("state.json"),
            fileManager: fileManager
        )
    }

    init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL

        let directory = fileURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    func load() -> AppState {
        guard let data = try? Data(contentsOf: fileURL),
              let state = try? JSONDecoder().decode(AppState.self, from: data)
        else {
            return .empty
        }
        return state
    }

    func save(_ state: AppState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

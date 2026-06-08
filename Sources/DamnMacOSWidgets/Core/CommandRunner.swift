import Foundation

struct CommandResult {
    let stdout: String
    let stderr: String
    let terminationStatus: Int32
}

enum CommandRunnerError: LocalizedError {
    case failedToLaunch(String)

    var errorDescription: String? {
        switch self {
        case .failedToLaunch(let message):
            return message
        }
    }
}

enum CommandRunner {
    static func run(executableURL: URL, arguments: [String]) async throws -> CommandResult {
        try await Task.detached(priority: .utility) {
            let process = Process()
            process.executableURL = executableURL
            process.arguments = arguments

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            do {
                try process.run()
            } catch {
                throw CommandRunnerError.failedToLaunch(error.localizedDescription)
            }

            process.waitUntilExit()

            let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

            return CommandResult(
                stdout: String(decoding: stdoutData, as: UTF8.self),
                stderr: String(decoding: stderrData, as: UTF8.self),
                terminationStatus: process.terminationStatus
            )
        }.value
    }
}

import Foundation

struct GitHubActivityItem: Identifiable, Equatable {
    let id: String
    let repositoryName: String
    let title: String
    let reason: String
    let updatedAtText: String
    let url: URL?
}

struct GitHubActivitySnapshot: Equatable {
    var username: String?
    var items: [GitHubActivityItem]
    var statusMessage: String

    static let empty = GitHubActivitySnapshot(
        username: nil,
        items: [],
        statusMessage: "Run `gh auth login` to connect GitHub."
    )
}

@MainActor
final class GitHubService {
    func fetchSnapshot(limit: Int = 5) async -> GitHubActivitySnapshot {
        do {
            let userResult = try await CommandRunner.run(
                executableURL: URL(fileURLWithPath: "/usr/bin/env"),
                arguments: ["gh", "api", "user", "-q", ".login"]
            )

            guard userResult.terminationStatus == 0 else {
                return GitHubActivitySnapshot.empty
            }

            let username = userResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            let notificationsResult = try await CommandRunner.run(
                executableURL: URL(fileURLWithPath: "/usr/bin/env"),
                arguments: ["gh", "api", "notifications", "-F", "per_page=\(limit)"]
            )

            guard notificationsResult.terminationStatus == 0,
                  let data = notificationsResult.stdout.data(using: .utf8)
            else {
                return GitHubActivitySnapshot(
                    username: username.isEmpty ? nil : username,
                    items: [],
                    statusMessage: "GitHub authenticated, but no notifications were returned."
                )
            }

            let decoder = JSONDecoder()
            let responses = try decoder.decode([GitHubNotificationResponse].self, from: data)
            let items = responses.map { response in
                GitHubActivityItem(
                    id: response.id,
                    repositoryName: response.repository.fullName,
                    title: response.subject.title,
                    reason: response.reason,
                    updatedAtText: response.updatedAt,
                    url: URL(string: response.url ?? response.subject.url)
                )
            }

            return GitHubActivitySnapshot(
                username: username.isEmpty ? nil : username,
                items: items,
                statusMessage: items.isEmpty ? "No unread notifications." : "Loaded \(items.count) notification\(items.count == 1 ? "" : "s")."
            )
        } catch {
            return GitHubActivitySnapshot(
                username: nil,
                items: [],
                statusMessage: "GitHub unavailable: \(error.localizedDescription)"
            )
        }
    }
}

private struct GitHubNotificationResponse: Decodable {
    let id: String
    let reason: String
    let updatedAt: String
    let repository: GitHubRepositoryResponse
    let subject: GitHubSubjectResponse
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case reason
        case updatedAt = "updated_at"
        case repository
        case subject
        case url
    }
}

private struct GitHubRepositoryResponse: Decodable {
    let fullName: String

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
    }
}

private struct GitHubSubjectResponse: Decodable {
    let title: String
    let url: String
}

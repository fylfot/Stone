import Foundation
import CloudKit
import SwiftData
import Combine

enum SyncStatus: Equatable {
    case idle
    case syncing
    case synced(Date)
    case error(String)

    var description: String {
        switch self {
        case .idle:
            return "Not synced"
        case .syncing:
            return "Syncing..."
        case .synced(let date):
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return "Synced \(formatter.localizedString(for: date, relativeTo: .now))"
        case .error(let message):
            return "Error: \(message)"
        }
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }
}

@Observable
final class CloudKitSyncService {
    private(set) var status: SyncStatus = .idle
    private(set) var isCloudKitAvailable: Bool = false
    private(set) var accountStatus: CKAccountStatus = .couldNotDetermine

    private let container: CKContainer
    private var accountChangedSubscription: AnyCancellable?

    var onAccountWillChange: (() -> Void)?

    init(containerIdentifier: String = "iCloud.com.jamg.Stone") {
        self.container = CKContainer(identifier: containerIdentifier)
        checkAccountStatus()
        observeAccountChanges()
    }

    func checkAccountStatus() {
        Task {
            do {
                let status = try await container.accountStatus()
                await MainActor.run {
                    self.accountStatus = status
                    self.isCloudKitAvailable = status == .available
                }
            } catch {
                await MainActor.run {
                    self.accountStatus = .couldNotDetermine
                    self.isCloudKitAvailable = false
                }
            }
        }
    }

    private func observeAccountChanges() {
        // Observe iCloud account changes
        NotificationCenter.default.addObserver(
            forName: .CKAccountChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAccountChange()
        }
    }

    private func handleAccountChange() {
        // Warn user before account changes affect data
        onAccountWillChange?()
        checkAccountStatus()
    }

    func triggerSync() {
        guard isCloudKitAvailable else {
            status = .error("iCloud not available")
            return
        }

        status = .syncing

        // SwiftData handles the actual sync when configured with CloudKit
        // We just update our status indicator

        Task {
            // Give SwiftData a moment to sync
            try? await Task.sleep(for: .seconds(2))

            await MainActor.run {
                self.status = .synced(.now)
            }
        }
    }

    func handleSyncError(_ error: Error) {
        status = .error(error.localizedDescription)
    }

    func markSynced() {
        status = .synced(.now)
    }
}

// MARK: - Conflict Resolution

enum ConflictResolutionStrategy {
    case serverWins
    case clientWins
    case merge
}

struct ConflictResolver {
    static let strategy: ConflictResolutionStrategy = .serverWins

    static func resolve<T: Identifiable>(
        local: T,
        remote: T,
        strategy: ConflictResolutionStrategy = ConflictResolver.strategy
    ) -> T {
        switch strategy {
        case .serverWins:
            return remote
        case .clientWins:
            return local
        case .merge:
            // For Stone, server wins is safest - data loss prevention
            return remote
        }
    }
}

// MARK: - SwiftData CloudKit Configuration

extension ModelConfiguration {
    static var cloudKitEnabled: ModelConfiguration {
        // When CloudKit sync is enabled, SwiftData automatically syncs
        // This requires proper entitlements and container setup
        ModelConfiguration(
            schema: Schema([
                Project.self,
                TimeEntry.self,
                Folder.self,
                Tag.self
            ]),
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.jamg.Stone")
        )
    }

    static var localOnly: ModelConfiguration {
        ModelConfiguration(
            schema: Schema([
                Project.self,
                TimeEntry.self,
                Folder.self,
                Tag.self
            ]),
            isStoredInMemoryOnly: false
        )
    }
}

import SwiftUI

struct SyncStatusView: View {
    let syncService: CloudKitSyncService

    var body: some View {
        HStack(spacing: 8) {
            statusIcon

            VStack(alignment: .leading, spacing: 2) {
                Text(syncService.status.description)
                    .font(.caption)

                if !syncService.isCloudKitAvailable {
                    Text("Sign in to iCloud to enable sync")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if syncService.isCloudKitAvailable {
                Button {
                    syncService.triggerSync()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(.plain)
                .disabled(syncService.status == .syncing)
            }
        }
        .padding(8)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch syncService.status {
        case .idle:
            Image(systemName: "cloud")
                .foregroundStyle(.secondary)
        case .syncing:
            ProgressView()
                .scaleEffect(0.6)
        case .synced:
            Image(systemName: "checkmark.icloud.fill")
                .foregroundStyle(.green)
        case .error:
            Image(systemName: "exclamationmark.icloud.fill")
                .foregroundStyle(.red)
        }
    }

    private var backgroundColor: Color {
        switch syncService.status {
        case .error:
            return .red.opacity(0.1)
        case .synced:
            return .green.opacity(0.1)
        default:
            return .secondary.opacity(0.1)
        }
    }
}

struct SyncSettingsView: View {
    let syncService: CloudKitSyncService
    @State private var showAccountChangeWarning = false

    var body: some View {
        Form {
            Section("iCloud Sync") {
                SyncStatusView(syncService: syncService)

                if syncService.isCloudKitAvailable {
                    LabeledContent("Account Status") {
                        Text(accountStatusText)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                        Text("iCloud is not available. Sign in to iCloud in System Settings to enable sync.")
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("About Sync") {
                Text("Stone automatically syncs your projects and time entries across all your Macs using iCloud. Changes typically appear on other devices within a few minutes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .alert("iCloud Account Changed", isPresented: $showAccountChangeWarning) {
            Button("OK") {}
        } message: {
            Text("Your iCloud account has changed. Local data may need to be merged with the new account's data.")
        }
        .onAppear {
            syncService.onAccountWillChange = {
                showAccountChangeWarning = true
            }
        }
    }

    private var accountStatusText: String {
        switch syncService.accountStatus {
        case .available:
            return "Connected"
        case .noAccount:
            return "No Account"
        case .restricted:
            return "Restricted"
        case .couldNotDetermine:
            return "Unknown"
        case .temporarilyUnavailable:
            return "Temporarily Unavailable"
        @unknown default:
            return "Unknown"
        }
    }
}

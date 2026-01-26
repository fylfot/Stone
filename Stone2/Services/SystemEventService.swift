import Foundation
import AppKit
import Combine

@Observable
final class SystemEventService {
    private let workspace = NSWorkspace.shared
    private var sleepObserver: NSObjectProtocol?
    private var wakeObserver: NSObjectProtocol?
    private var idleTimer: Timer?
    private var lastActivityTime: Date = .now

    var onSystemWillSleep: (() -> Void)?
    var onSystemDidWake: ((_ idleSeconds: TimeInterval) -> Void)?
    var onIdleDetected: ((_ idleSeconds: TimeInterval) -> Void)?

    private let idleThreshold: TimeInterval = 300 // 5 minutes

    func startObserving() {
        sleepObserver = workspace.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleWillSleep()
        }

        wakeObserver = workspace.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleDidWake()
        }

        startIdleMonitoring()
    }

    func stopObserving() {
        if let sleepObserver {
            workspace.notificationCenter.removeObserver(sleepObserver)
        }
        if let wakeObserver {
            workspace.notificationCenter.removeObserver(wakeObserver)
        }
        idleTimer?.invalidate()
        idleTimer = nil
    }

    private func handleWillSleep() {
        lastActivityTime = .now
        onSystemWillSleep?()
    }

    private func handleDidWake() {
        let idleSeconds = Date.now.timeIntervalSince(lastActivityTime)
        onSystemDidWake?(idleSeconds)
    }

    private func startIdleMonitoring() {
        idleTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.checkIdleTime()
        }
    }

    private func checkIdleTime() {
        let idleTime = systemIdleTime()

        if idleTime >= idleThreshold {
            onIdleDetected?(idleTime)
        }
    }

    private func systemIdleTime() -> TimeInterval {
        var iterator: io_iterator_t = 0
        defer { IOObjectRelease(iterator) }

        guard IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IOHIDSystem"),
            &iterator
        ) == KERN_SUCCESS else {
            return 0
        }

        let entry = IOIteratorNext(iterator)
        defer { IOObjectRelease(entry) }

        guard entry != 0 else { return 0 }

        var unmanagedProperties: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(
            entry,
            &unmanagedProperties,
            kCFAllocatorDefault,
            0
        ) == KERN_SUCCESS else {
            return 0
        }

        guard let properties = unmanagedProperties?.takeRetainedValue() as? [String: Any],
              let idleTime = properties["HIDIdleTime"] as? Int64 else {
            return 0
        }

        // HIDIdleTime is in nanoseconds
        return TimeInterval(idleTime) / 1_000_000_000
    }

    func recordActivity() {
        lastActivityTime = .now
    }
}

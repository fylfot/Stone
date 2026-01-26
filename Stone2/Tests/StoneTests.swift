import XCTest
import SwiftUI
@testable import Stone

final class StoneTests: XCTestCase {
    func testTimeIntervalFormatting() {
        // Test full duration format (HH:MM:SS)
        XCTAssertEqual(TimeInterval(0).formattedDuration, "00:00:00")
        XCTAssertEqual(TimeInterval(61).formattedDuration, "00:01:01")
        XCTAssertEqual(TimeInterval(3661).formattedDuration, "01:01:01")
        XCTAssertEqual(TimeInterval(7200).formattedDuration, "02:00:00")

        // Test short duration format (HH:MM)
        XCTAssertEqual(TimeInterval(0).formattedShortDuration, "00:00")
        XCTAssertEqual(TimeInterval(3600).formattedShortDuration, "01:00")
        XCTAssertEqual(TimeInterval(5400).formattedShortDuration, "01:30")

        // Test compact duration format
        XCTAssertEqual(TimeInterval(0).formattedCompactDuration, "0m")
        XCTAssertEqual(TimeInterval(3600).formattedCompactDuration, "1h 0m")
        XCTAssertEqual(TimeInterval(5400).formattedCompactDuration, "1h 30m")
        XCTAssertEqual(TimeInterval(1800).formattedCompactDuration, "30m")
    }

    func testDateExtensions() {
        let now = Date.now
        XCTAssertTrue(now.isToday)

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        XCTAssertTrue(yesterday.isYesterday)
        XCTAssertFalse(yesterday.isToday)
    }

    func testColorHexParsing() {
        // Test 6-digit hex
        let blue = Color(hex: "#007AFF")
        XCTAssertNotNil(blue)

        // Test hex without #
        let red = Color(hex: "FF0000")
        XCTAssertNotNil(red)
    }
}

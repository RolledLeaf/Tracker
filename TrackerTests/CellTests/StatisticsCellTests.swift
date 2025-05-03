import XCTest
@testable import Tracker

final class StatisticsCellTests: XCTestCase {
    
    func testStatisticLables() {
        let cell = StatisticsCell()
        let expectedTitle = 1
        let expectedSubtitle = "Track your progress"
        
        cell.configure(with: (title: expectedTitle, subtitle: expectedSubtitle))
        
        XCTAssertEqual(cell.titleLabel.text, "\(expectedTitle)")
        XCTAssertEqual(cell.detailedTextLabel.text, expectedSubtitle)
    }
}

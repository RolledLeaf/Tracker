import XCTest
@testable import Tracker

final class ScheduleTableCellTests:XCTestCase {
    func testConfigureScheduleCell() {
        
        let cell = ScheduleTableCell()
        let expectedDayOfWeek = "Monday"
        let expectedIsOn = true
        
        cell.configure(with: expectedDayOfWeek, isOn: expectedIsOn)
        
        XCTAssertEqual(cell.titleLabel.text, expectedDayOfWeek)
        XCTAssertTrue(cell.toggleSwitch.isOn)
      
    }
}

import XCTest
@testable import Tracker

final class CategoryAndScheduleCellTests: XCTestCase {
    
    func testCellTitles() {
        let cell = CategoryAndScheduleTableViewCell()
        
        let exampleTiltle = "Example Title"
        let exampleSubtitle = "Example Subtitle"
        
        cell.configure(with: (title: exampleTiltle, subtitle: exampleSubtitle))
        
        XCTAssertEqual(cell.titleLabel.text, exampleTiltle)
        XCTAssertEqual(cell.detailedTextLabel.text, exampleSubtitle)
    }
    
    func testWetherHasSubtitle() {
        
        let cell = CategoryAndScheduleTableViewCell()
        
        let exampleTiltle = "Example Title"
        let exampleSubtitle = "Example Subtitle"
        
        //When
        cell.configure(with: (title: exampleTiltle, subtitle: exampleSubtitle))
        
        XCTAssertTrue(cell.hasSubtitle)
    }
    
    func testWetherHasТщSubtitle() {
        
        let cell = CategoryAndScheduleTableViewCell()
        
        let exampleTiltle = "Example Title"
        
        //When
        cell.configure(with: (title: exampleTiltle, subtitle: nil))
        
        XCTAssertFalse(cell.hasSubtitle)
    }
}

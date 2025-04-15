import XCTest
@testable import Tracker

final class FiltersTableCellTests: XCTestCase {
    
    func testCategoryNameLabel() {
        let cell = FiltersTableCell()
        let expectedText = "Category Name"
        
        cell.configure(with: expectedText)
        
        XCTAssertEqual(cell.categoryNameLabel.text, expectedText)
    }
}

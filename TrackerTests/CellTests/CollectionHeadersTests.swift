import XCTest
@testable import Tracker

final class HeadersTests: XCTestCase {
    
    func testCollectionHeadersConfigure() {
        
        let cell = CategoriesCollectionHeaderView()
        let expectedTitle = "Categories"
        
        cell.configure(with: expectedTitle)
        
        XCTAssertEqual(cell.titleLabel.text, expectedTitle)
    }
}

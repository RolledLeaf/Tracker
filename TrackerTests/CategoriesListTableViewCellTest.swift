import XCTest

@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testCategoriesListTableTitle() {
        
        //Arrange
        let cell = CategoriesListTableCell()
        
        let exampleText = "Hello, World!"
        
        //Act
        cell.configure(with: exampleText)
        
        //Assert
        XCTAssertEqual(cell.categoryNameLabel.text, exampleText)
    }
    
    func testSetHiddenHidesCellCorrectly() {
        
        //Given
        let cell = CategoriesListTableCell()
        
        //When
        cell.setHidden(true)
        
        //Then
        XCTAssertTrue(cell.isHidden)
        XCTAssertFalse(cell.isUserInteractionEnabled)
        XCTAssertTrue(cell.contentView.isHidden)
        
    }
    
    func testSetHiddenShowsCellCorrectly() {
        
        //Given
        let cell = CategoriesListTableCell()
        
        //When
        cell.isHidden = false
        
        //Then
        XCTAssertFalse(cell.isHidden)
        XCTAssertTrue(cell.isUserInteractionEnabled)
        XCTAssertFalse(cell.contentView.isHidden)
    }
    
}

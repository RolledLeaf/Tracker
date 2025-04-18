import XCTest
@testable import Tracker

final class ColorCollectionCellTest: XCTestCase {
    func testConfigureImageViewWithColor() {
        
        //Given
        let cell = ColorsCollectionViewCell()
        let sampleColor = CollectionColors.collectionBeige7
        let expectedColor = sampleColor.uiColor
        
        //When
        cell.configure(with: sampleColor)
        
        //Then
        XCTAssertEqual(cell.colorBlockImage.backgroundColor, expectedColor)
    }
}

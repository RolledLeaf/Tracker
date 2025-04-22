import XCTest
@testable import Tracker

final class EmojiAndColorHeadersTestCase: XCTestCase {
    
    func testHeaders() {
        let header = EmojiAndColorCollectionHeaderView()
        let expectedHeader = "Header"
        
        header.configure(with: expectedHeader)
        
        XCTAssertEqual(header.titleLabel.text, expectedHeader)
    }
}

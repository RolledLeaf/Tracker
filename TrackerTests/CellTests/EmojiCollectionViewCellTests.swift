import XCTest
@testable import Tracker

final class EmojiCollectionViewCellTests: XCTestCase {
    
    func testEmojiConfigure() {
        let cell = EmojiCollectionViewCell()
        
        let emojiSample = "😄"
        
        cell.configure(with: emojiSample)
        
        XCTAssertEqual(cell.emojiLabel.text, emojiSample)
    }
}

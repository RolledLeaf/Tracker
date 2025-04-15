import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {

    func testTrackersVC() {
        let vc = TrackersViewController()
        vc.view.frame = CGRect(x: 0, y: 0, width: 430, height: 932)
        _ = vc.view
        assertSnapshot(of: vc, as: .image, named: "TrackersViewController")

        let vc2 = StatisticsViewController()
        vc2.view.frame = CGRect(x: 0, y: 0, width: 430, height: 932)
        _ = vc2.view
        assertSnapshot(of: vc2, as: .image, named: "StatisticsViewController")
    }
    
    

}

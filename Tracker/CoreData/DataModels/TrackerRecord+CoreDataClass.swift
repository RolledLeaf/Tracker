//
//  TrackerRecord+CoreDataClass.swift
//  Tracker
//
//  Created by Vitaly Wexler on 24.02.2025.
//
//

import Foundation
import CoreData

@objc(TrackerRecord)
public class TrackerRecord: NSManagedObject {


        @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecord> {
            return NSFetchRequest<TrackerRecord>(entityName: "TrackerRecord")
        }

        @NSManaged public var date: Date
        @NSManaged public var trackerID: Int



    
}

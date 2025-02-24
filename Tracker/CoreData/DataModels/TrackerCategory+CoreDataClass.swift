//
//  TrackerCategory+CoreDataClass.swift
//  Tracker
//
//  Created by Vitaly Wexler on 24.02.2025.
//
//

import Foundation
import CoreData

@objc(TrackerCategory)
public class TrackerCategory: NSManagedObject {

    


        @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategory> {
            return NSFetchRequest<TrackerCategory>(entityName: "TrackerCategory")
        }

        @NSManaged public var title: String
        @NSManaged public var tracker: Set<Tracker>

    

    // MARK: Generated accessors for tracker


        @objc(addTrackerObject:)
        @NSManaged public func addToTracker(_ value: Tracker)

        @objc(removeTrackerObject:)
        @NSManaged public func removeFromTracker(_ value: Tracker)

        @objc(addTracker:)
        @NSManaged public func addToTracker(_ values: NSSet)

        @objc(removeTracker:)
        @NSManaged public func removeFromTracker(_ values: NSSet)

    }
    


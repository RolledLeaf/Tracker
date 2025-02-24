//
//  Tracker+CoreDataClass.swift
//  Tracker
//
//  Created by Vitaly Wexler on 24.02.2025.
//
//

import Foundation
import CoreData

@objc(Tracker)
public class Tracker: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tracker> {
        return NSFetchRequest<Tracker>(entityName: "Tracker")
    }

    @NSManaged var color: String
    @NSManaged public var daysCount: Int
    @NSManaged public var emoji: String
    @NSManaged public var id: Int
    @NSManaged public var name: String
    @NSManaged var weekDays: [String]
    
}

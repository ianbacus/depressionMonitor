//
//  SensorData+CoreDataProperties.swift
//  
//
//  Created by Ian Bacus on 2/22/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension SensorData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorData> {
        return NSFetchRequest<SensorData>(entityName: "SensorDataEntity");
    }

    @NSManaged public var name: String?
    @NSManaged public var stateVal: String?
    @NSManaged public var time: NSDate?

}

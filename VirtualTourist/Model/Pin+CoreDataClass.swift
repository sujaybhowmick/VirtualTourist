//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Sujay Bhowmick on 5/26/18.
//  Copyright © 2018 Sujay Bhowmick. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    static let name = "Pin"
    
    convenience init(latitude: String, longitude: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Pin.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

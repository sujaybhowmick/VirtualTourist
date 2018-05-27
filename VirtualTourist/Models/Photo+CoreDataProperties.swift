//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Sujay Bhowmick on 5/26/18.
//  Copyright © 2018 Sujay Bhowmick. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?

}

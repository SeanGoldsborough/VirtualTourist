//
//  Photo+CoreDataProperties.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 4/2/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var photoData: NSData?
    @NSManaged public var photoURL: String?
    @NSManaged public var pin: Pin?

}

//
//  Pin+CoreDataClass.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 4/2/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//
//

import Foundation
import CoreData

//@objc(Pin)
public class Pin: NSManagedObject {
    
    convenience init(latitude : Double , longitude : Double , context : NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context){
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.creationDate = Date()
            
        }else{
            fatalError("Unable To Find Entity name 'PIN'")
        }
    }
    
    var dateFormatter : String{
        get{
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .short
            formatter.doesRelativeDateFormatting = true
            formatter.locale = Locale.current
            return formatter.string(from: creationDate!)
        }
    }

}

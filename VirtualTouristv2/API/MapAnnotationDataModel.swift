//
//  MapAnnotationDataModel.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 4/2/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        
        super.init()
    }
}

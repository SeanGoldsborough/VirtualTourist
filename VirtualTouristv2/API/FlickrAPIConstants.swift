//
//  FlickrAPIConstants.swift
//  VirtualTouristV1
//
//  Created by Sean Goldsborough on 11/26/17.
//  Copyright © 2017 Sean Goldsborough. All rights reserved.
//

import Foundation
import UIKit

extension FlickrAPIClient {
    
    //// MARK: - Constants
    //
    struct Constants {
        
        // MARK: Flickr
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
            
            static let SearchBBoxHalfWidth = 1.0
            static let SearchBBoxHalfHeight = 1.0
            static let SearchLatRange = (-90.0, 90.0)
            static let SearchLonRange = (-180.0, 180.0)
        }
        
        // MARK: Flickr Parameter Keys  // Query Keys
        struct FlickrParameterKeys {
            
            static let Method = "method"
            static let APIKey = "api_key"
            static let Latitude = "lat"
            static let Longitude = "long"
            static let Extras = "extras"
            static let PerPage = "per_page"
            static let Page = "page"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            
            static let GalleryID = "gallery_id"
            static let SafeSearch = "safe_search"
            static let Text = "text"
            static let BoundingBox = "bbox"
            
        }
        
        // MARK: Flickr Parameter Values //Query Values
        struct FlickrParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let UseSafeSearch = "1"
            static let APIKey = "4b6ebaa596519d19ebc493eb2a72147f"
            static let Latitude = "40.730610"
            static let Longitude = "-73.935242"
            static let MediumURL = "url_m"
            static let Page = "1"
            static let PerPage = "21"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" /* 1 means "yes" */
        }
        
        // MARK: Flickr Response Keys
        struct FlickrResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        // MARK: Flickr Response Values
        struct FlickrResponseValues {
            static let OKStatus = "ok"
        }
    }
    
}




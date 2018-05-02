//
//  FlickrAPIClient.swift
//  VirtualTouristV1
//
//  Created by Sean Goldsborough on 11/26/17.
//  Copyright © 2017 Sean Goldsborough. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FlickrAPIClient : NSObject {
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrAPIClient {
        struct Singleton {
            static var sharedInstance = FlickrAPIClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: Properties
    
    var session = URLSession.shared
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //var dataController:DataController!
    
//    var sharedContext: NSManagedObjectContext {
//        //return dataController.persistentContainer.viewContext
//        return dataController.viewContext
//    }
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: Helpers
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? AnyObject
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        //print("JSON Serialization result is: \(parsedResult)")
        completionHandlerForConvertData(parsedResult, nil)
        
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        print(components.url!)
        return components.url!
    }
    
    // MARK: GET Methods - Flickr
    func taskForGETMethodFlickr(variant: String, parameters: [String:AnyObject], completionHandlerForFlickrGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: flickrURLFromParameters(parameters  as [String:AnyObject]))
        //print("The Flickr GET URL Request is: \(request)")
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForFlickrGET(nil, NSError(domain: "taskForGETMethodFlickr", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("Flickr GET: There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Flickr GET: Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("Flickr GET: No data was returned by the request!")
                return
            }
            
            //print("Flickr GET: The URL Data Task Response is: \(response)")
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForFlickrGET)
            print("data from Flickr get data task is: \(data)")
            // self.appDelegate.saveContext()
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: GET Convenience Methods - Flickr
    
    func getFlickrPhotos(lat: String, long: String, pageNum: Int, chosenPin: Pin, _ completionHandlerForFlickrGetPhotos: @escaping (_ result: [String]?, _ error: NSError?) -> Void) {
        
        func bboxString() -> String {
            print("bbox func was called!")
            // ensure bbox is bounded by minimum and maximums
            if let latitude = Double(lat), let longitude = Double(long) {
                let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
                let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
                let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
                let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
                return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
            } else {
                return "0,0,0,0"
            }
        }
        
        let methodParameters = [
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage,
            Constants.FlickrParameterKeys.Page: pageNum,
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod as AnyObject,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey as AnyObject,
            Constants.FlickrParameterKeys.BoundingBox: bboxString() as AnyObject,
            Constants.FlickrParameterKeys.SafeSearch: "1", //Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            
            ] as [String : AnyObject]
        
        let variant = ""
        /* 2. Make the request */
        
        let _ = taskForGETMethodFlickr(variant: variant, parameters: methodParameters) { (results, error) in
            //print("The getFlickrPhotos JSON Data is: \(results!)")
            if results == nil {
                //AlertView.alertPopUp(view: self, alertMessage: "Unable to connect to network.")
            }
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForFlickrGetPhotos(nil, NSError(domain: "taskForGETMethodFlickr", code: 1, userInfo: userInfo))
            }
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForFlickrGetPhotos(nil, error)
            } else {
                guard let photosResults = results?[FlickrAPIClient.Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {print("Error on photoResults from results");return}
                
                //print("the flickr GET Request photoResults are: \(photosResults)")
                
                guard let photosArray = photosResults[FlickrAPIClient.Constants.FlickrResponseKeys.Photo] as? [[String: Any]] else {print("Error on photoURL from photosResults");return}
                
                print("the getParseRequest photo are: \(photosArray)")
                
                
                var photoURLS = [String]()
                for pictureURL in photosArray{
                    photoURLS.append(pictureURL[FlickrAPIClient.Constants.FlickrParameterValues.MediumURL] as! String)
                    print("photosArray.count0 = \(photosArray.count)")
                    print("photoURLS.count is = \(photoURLS.count)")
                }
                if photoURLS.count >= 0 {
                    // Return array of photo URLs and page count
                    print("photosArray.count1 = \(photosArray.count)")
                    print("photoURLS are = \(photoURLS)")
                    completionHandlerForFlickrGetPhotos(photoURLS,nil)
                }
                else {
                    print("photosArray.count2 = \(photosArray.count)")
                    completionHandlerForFlickrGetPhotos(nil,error)
                }
                print("photosArray.count3 = \(photosArray.count)")
//                performUpdatesOnMain {
//                    self.appDelegate.saveContext()
//                }
                return
            }
        }
    }
    
    func getImage(urlString: String, completionHandler: @escaping (_ results: NSData?,_ error:NSError?) -> ()){
        do{
            let url = URL(string: urlString)
            let imageData = try NSData(contentsOf: url!)
            completionHandler(imageData,nil)
        }
        catch let error as NSError {
            completionHandler(nil,error)
        }
    }
    
    /// Adds a new photo to the end of the `photoalbum` array
    func addPhotos(creationDate: Date, photoURL: String, photoData: NSData?, mapPin: Pin, view: UIViewController) {
        let photo = Photo(context: self.context)
        print("addPhotosCV was called - photo is in context?")
        var date = Date()
        photo.creationDate = date
        print("addPhotosCV creationDate is: \(photo.creationDate)")
        photo.photoURL = photoURL
        photo.pin = mapPin
        print("addPhotosCV was called")
        
        do{
            let url = URL(string: photoURL)
            var imageData = try NSData(contentsOf: url!)
            photo.photoData = imageData
            if photo.photoData != nil {
                print("photo.photoDataCV has data!")
            }
        }
        catch let error as NSError {
            AlertView.alertPopUp(view: view, alertMessage: "Unable to download images. Please try again.")
        }
    }
    
    
    func getDataForPhoto(_ currentCellPhoto: Photo, _ ImageURLString: String, completionHandlerForGetImageData: @escaping (_ imageData: NSData?, _ error: NSError?) -> Void) -> URLSessionTask { // return nothing, as we just gonna update the coreData directly
        
        // convert String to url
        let imageURL = URL(string: ImageURLString)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: imageURL!) { (data, response, error) in
            
            // download has finished
            
            // handle error
            guard (error == nil) else {
                // has error:
                if let error = error {
                    print("Error downloading photo: \(error)")
                    completionHandlerForGetImageData(nil, error as NSError?)
                }
                return
            } // END of guard (error == nil) else {
            
            // check for response code
            if let res = response as? HTTPURLResponse {
                print("Downloaded photo with response code \(res.statusCode)")
            }
            
            // deal with returned data!
            if let returnedImageData = data {
                // add to photo's property
                DispatchQueue.main.async {
                    currentCellPhoto.photoData = returnedImageData as NSData? // Photo's @NSManaged public var imageData: NSData?
                }
                
                // should I update view here??? not really... - because you will block the UI as there are lots of photos! - do it at PhotoAlbumViewController...
                completionHandlerForGetImageData(returnedImageData as NSData, nil)
            }
        } // END of let task =
        task.resume()
        return task
    } // END of getImageData()
    
    // MARK: ADD INFO TO COREDATA METHODS
//    func addNewPhotos(_ pin: Pin, handler: @escaping (_ error: String?) -> Void) {
//
//        getFlickrPhotos(lat: "\(pin.latitude)", long: "\(pin.longitude)", pageNum: 5, chosenPin: pin) { (photos, error) -> Void in
//            DispatchQueue.main.async(execute: {
//
//                var photoTemp: Photo?
//
//                print("Getting new photos for dropped pin...")
//
//                // Add web URLs and Pin(s) only at this point...
//                var photoURLS = [String]()
//                if let entity = NSEntityDescription.entity(forEntityName: "Photos", in: self.context) {
//                    for pictureURL in photos!{
//                        photoTemp?.photoURL = pictureURL
//                        //photoURLS.append(pictureURL[FlickrAPIClient.Constants.FlickrParameterValues.MediumURL] as! String)
//                        print("photosArray.count0 = \(photos?.count)")
//                    }
//                }
//                if photoTemp == nil {
//                    for photo in photos! {
//                        if let entity = NSEntityDescription.entity(forEntityName: "Photos", in: self.context) {
//                            photoTemp = Photo(entity: entity, insertInto: self.context)
//                            //photoTemp?.photoURL = photo["url_m"] //as? String
//                            photoTemp?.pin = pin
//                        }
//                    }
//                }
//                return handler(nil)
//            })
//        }
//    }
    
    // MARK: LOAD PHOTOS THAT ARE NOT SAVED IN COREDATA
    
    // Load photos from URLs
//    func loadNewPhoto(_ indexPath: IndexPath, photosArray: [Photo], handler: @escaping (_ image: UIImage?, _ data: Data?, _ error: String) -> Void) {
//
//        if photosArray.count > 0 {
//            if photosArray[indexPath.item].photoURL != nil {
//                let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: photosArray[indexPath.item].photoURL!)!), completionHandler: { data, response, downloadError in
//                    DispatchQueue.main.async(execute: {
//
//                        guard let data = data, let image = UIImage(data: data) else {
//                            print("Photo not loaded")
//                            return handler(nil, nil, "Photo not loaded")
//                        }
//
//                        return handler(image, data, "")
//                    })
//                })
//                task.resume()
//            }
//        }
//    }
    
}







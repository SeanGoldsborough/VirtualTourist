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
    
    private var tasks: [String: URLSessionDataTask] = [:]
    
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
     
        let request = NSMutableURLRequest(url: flickrURLFromParameters(parameters  as [String:AnyObject]))
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForFlickrGET(nil, NSError(domain: "taskForGETMethodFlickr", code: 1, userInfo: userInfo))
            }

            guard (error == nil) else {
                sendError("Flickr GET: There was an error with your request: \(error!)")
                return
            }
   
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Flickr GET: Your request returned a status code other than 2xx!")
                return
            }

            guard let data = data else {
                sendError("Flickr GET: No data was returned by the request!")
                return
            }

            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForFlickrGET)
            print("data from Flickr get data task is: \(data)")
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: GET Convenience Methods - Flickr
    // Makes HTTP request based on parameters.
    //Gets the JSON data and parses for the urls for the photos
    //and saves them as an array of strings
    
    func getFlickrPhotos(lat: String, long: String, pageNum: Int, chosenPin: Pin, _ completionHandlerForFlickrGetPhotos: @escaping (_ result: [String]?, _ error: NSError?) -> Void) {
        
        func bboxString() -> String {
            print("bbox func was called!")
        
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
            Constants.FlickrParameterKeys.SafeSearch: "1",
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            
            ] as [String : AnyObject]
        
        let variant = ""
        
        let _ = taskForGETMethodFlickr(variant: variant, parameters: methodParameters) { (results, error) in
            
            if results == nil {
            }
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForFlickrGetPhotos(nil, NSError(domain: "taskForGETMethodFlickr", code: 1, userInfo: userInfo))
            }
            
            if let error = error {
                completionHandlerForFlickrGetPhotos(nil, error)
            } else {
                guard let photosResults = results?[FlickrAPIClient.Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {print("Error on photoResults from results");return}

                guard let photosArray = photosResults[FlickrAPIClient.Constants.FlickrResponseKeys.Photo] as? [[String: Any]] else {print("Error on photoURL from photosResults");return}
                
                print("the getParseRequest photo are: \(photosArray)")
                
                
                var photoURLS = [String]()
                for pictureURL in photosArray{
                    photoURLS.append(pictureURL[FlickrAPIClient.Constants.FlickrParameterValues.MediumURL] as! String)
                    print("photosArray.count0 = \(photosArray.count)")
                    print("photoURLS.count is = \(photoURLS.count)")
                }
                if photoURLS.count >= 0 {

                    print("photosArray.count1 = \(photosArray.count)")
                    print("photoURLS are = \(photoURLS)")
                    completionHandlerForFlickrGetPhotos(photoURLS,nil)
                }
                else {
                    print("photosArray.count2 = \(photosArray.count)")
                    completionHandlerForFlickrGetPhotos(nil,error)
                }
                print("photosArray.count3 = \(photosArray.count)")

                return
            }
        }
    }
    
    func getImage(urlString: String, completionHandler: @escaping (_ results: Data?,_ error:NSError?) -> ()){
        do{
            let url = URL(string: urlString)
            let imageData = try Data(contentsOf: url!)
            completionHandler(imageData,nil)
        }
        catch let error as NSError {
            completionHandler(nil,error)
        }
    }
    
//      TODO: delete this func because its not being used anywhere
    
//    func addPhotos(creationDate: Date, photoURL: String, photoData: NSData?, mapPin: Pin, view: UIViewController) {
//        let photo = Photo(context: self.context)
//        print("addPhotosCV was called - photo is in context?")
//        var date = Date()
//        photo.creationDate = date
//        print("addPhotosCV creationDate is: \(photo.creationDate)")
//        photo.photoURL = photoURL
//        photo.pin = mapPin
//        print("addPhotosCV was called")
//
//        do{
//            let url = URL(string: photoURL)
//            var imageData = try NSData(contentsOf: url!)
//            photo.photoData = imageData
//            if photo.photoData != nil {
//                print("photo.photoDataCV has data!")
//            }
//        }
//        catch let error as NSError {
//            AlertView.alertPopUp(view: view, alertMessage: "Unable to download images. Please try again.")
//        }
//    }
    
//  TODO: delete this func because its not being used anywhere
    
//    func getDataForPhoto(_ currentCellPhoto: Photo, _ ImageURLString: String, completionHandlerForGetImageData: @escaping (_ imageData: NSData?, _ error: NSError?) -> Void) -> URLSessionTask {
//
//        let imageURL = URL(string: ImageURLString)
//        let session = URLSession.shared
//        let task = session.dataTask(with: imageURL!) { (data, response, error) in
//
//            guard (error == nil) else {
//                if let error = error {
//                    print("Error downloading photo: \(error)")
//                    completionHandlerForGetImageData(nil, error as NSError?)
//                }
//                return
//            }
//            if let res = response as? HTTPURLResponse {
//                print("Downloaded photo with response code \(res.statusCode)")
//            }
//            if let returnedImageData = data {
//
//                DispatchQueue.main.async {
//                    currentCellPhoto.photoData = returnedImageData as NSData?
//                }
//                completionHandlerForGetImageData(returnedImageData as NSData, nil)
//            }
//        }
//        task.resume()
//        return task
//    }
    
//        func downloadImage(imageUrl: String, result: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
//            guard let url = URL(string: imageUrl) else {
//                return
//            }
////            let task = taskForGETMethodFlickr(nil, url, parameters: [:]) { (data, error) in
//            let task = taskForGETMethodFlickr(variant: <#T##String#>, parameters: [:], completionHandlerForFlickrGET: data)
//                result(data, error)
//                self.tasks.removeValue(forKey: imageUrl)
//            }
//
//            if tasks[imageUrl] == nil {
//                tasks[imageUrl] = task
//            }
//        }
}

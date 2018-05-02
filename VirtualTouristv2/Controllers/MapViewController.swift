//
//  AppDelegate.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 4/2/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var arrayOfPins = [Pin]()
    var mapPin: Pin?
    var onePhoto: Photo?
    var arrayOfPhotos = [Photo]()
    var selectedIndexPaths: [NSIndexPath]?
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var fetchedResultsControllerPhotos:NSFetchedResultsController<Photo>!
    var labelOnScreen = false
    var randomNumberResults = 0
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var deleteLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tapPinsToDeleteLabel2: UIButton!
    
    @IBOutlet weak var tapPinsToDeleteLabel: UILabel!
    
    //LONG PRESS ON SCREEN TO ADD A NEW MAP PIN/ANNOTATION
    @IBAction func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        print("A Map Pin has been dropped!")
        if sender.state == .ended {
            
            let location = sender.location(in: self.mapView)
            let locCoord = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = locCoord
            annotation.title = ""
            annotation.subtitle = ""
            
            let mapPin = Pin(context: self.context)
            mapPin.latitude = locCoord.latitude
            mapPin.longitude = locCoord.longitude
            mapPin.creationDate = Date()
       
            performUpdatesOnMain {
                self.mapView.addAnnotation(annotation)
                self.arrayOfPins.append(mapPin)
                self.appDelegate.saveContext()
            }
            
            print("arrayOfPins count is: \(arrayOfPins.count)")
            
            FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(mapPin.latitude)", long: "\(mapPin.longitude)", pageNum: randomNumberResults, chosenPin: mapPin) { (photosURLs, error) in

                print("returnedPhotoURLs from FlickrGetPhotosCall On long press geusture is\(photosURLs)")

                guard let photosURLs = photosURLs else {
                    AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos")
                    return
                }

                for returnedURLs in photosURLs {
                    let photo = Photo(context: self.context)
                    print("for returnedURLs in photosURLs is called - \(mapPin.photos)")
                    let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.context)
                    let photoModel = Photo(entity: Photo.entity(), insertInto: self.context)
                   
                    //let photoModel = Photo()
                    
                    var date = Date()
                    photoModel.creationDate = date
                    photoModel.photoURL = returnedURLs as! String
                    photoModel.pin = mapPin

                    do{
                        let url = URL(string: photoModel.photoURL!)
                        var imageData = try NSData(contentsOf: url!)
                        photoModel.photoData = imageData
                        if photo.photoData != nil {
                            print("2photo.photoData has data!")
                        } else {

                        }
                    }
                    catch let error as NSError {
                        AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again.")
                    }
                    
                    //self.addPhotos(creationDate: photoModel.creationDate!, photoURL: photoModel.photoURL!, photoData: photoModel.photoData, mapPin: photoModel.pin!)
//                    print("returnedPhotoURLs in photo model are\(photoModel.photoURL)")
//                    print("returnedPhotoData in photo model are\(photoModel.photoData)")
//                    print("returnedPhotoCreationDate in photo model are\(photoModel.creationDate)")
  
                    //self.arrayOfPhotos.append(photoModel)
//                    print("arrayOfPhotos/photo model are\(self.arrayOfPhotos)")
//                    print("arrayOfPhotos count is \(self.arrayOfPhotos.count)")
                    
                    //mapPin.photos = NSSet(object: photoModel)
                    //mapPin.photos?.addingObjects(from: self.arrayOfPhotos)
                    //print("map pin photos: \(mapPin.photos)")
                    print("map pin photos count: \(mapPin.photos?.count)")
                    //print("map pin debug: \(mapPin.debugDescription)")
                    print("self.context is changed?: \(self.context.hasChanges)")
                }
//                performUpdatesOnMain {
//                    self.mapView.addAnnotation(annotation)
//                    print("mapView.annotations.count is: \(self.mapView.annotations.count)")
//                    print("mapPin is: \(mapPin)")
//                    print(" arrayOfPins.count is: \(self.arrayOfPins.count)")
//                    self.arrayOfPins.append(mapPin)
//                    self.appDelegate.saveContext()
//                    print("mapPin photos are : \(mapPin.photos?.count)")
//
//                }
                self.appDelegate.saveContext()
            }
            
            performUpdatesOnMain {
                self.mapView.addAnnotation(annotation)
                print("mapView.annotations.count is: \(self.mapView.annotations.count)")
                print("mapPin is: \(mapPin)")
                print(" arrayOfPins.count is: \(self.arrayOfPins.count)")
                self.arrayOfPins.append(mapPin)
                
                print("mapPin photos are : \(mapPin.photos?.count)")
                print("self.context is changed?:1 \(self.context.hasChanges)")
            }
        }
    }
    
    func getImage(urlString: String, completionHandler: @escaping (_ results:NSData?,_ error:NSError?) -> ()){
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
//    func addPhotos(creationDate: Date, photoURL: String, photoData: NSData?, mapPin: Pin) {
//        let photo = Photo(context: self.context)
//        print("addPhotos was called - photo is in context?")
//        var date = Date()
//        photo.creationDate = date
//        print("addPhotos creationDate is: \(photo.creationDate)")
//        photo.photoURL = photoURL
//        photo.pin = mapPin
//        print("addPhotos was called")
//
//        do{
//            let url = URL(string: photoURL)
//            var imageData = try NSData(contentsOf: url!)
//            photo.photoData = imageData
//            if photo.photoData != nil {
//                print("photo.photoData has data!")
//            }
//            //print("photoData is: \(photo.photoData)")
//        }
//        catch let error as NSError {
//            AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again.")
//        }
//
////        getImage(urlString: photoURL) { (photoData, error) in
////            //print("photo data in add photos is\(photoData)")
////            print("getImage was called")
////        }
//
//        performUpdatesOnMain {
//            self.arrayOfPhotos.append(photo)
//            print("arrayOfPhotos in add photos is\(self.arrayOfPhotos.count)")
////            self.appDelegate.saveContext()
////            print("save context in addPhotos was called")
//        }
//    }
 
    /// TODO - Deletes the photo at the specified index path - ADD TO COLLECTION VIEW!!!
//    func deletePhotos(at indexPath: IndexPath) {
//        let photoToDelete = fetchedResultsController.object(at: indexPath)
//        context.delete(photoToDelete)
//        self.appDelegate.saveContext()
//    }
    
    @objc func tapToDeletePin() {
        let annotation = MKPointAnnotation()
        
        for pinToDelete in arrayOfPins {
            if pinToDelete.latitude == annotation.coordinate.latitude && pinToDelete.longitude == annotation.coordinate.longitude {
                context.delete(pinToDelete)
                self.appDelegate.saveContext()
            }
        }
        mapView.removeAnnotation(annotation)
    }
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDeletePin))
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //TOGGLES BETWEEN BEING ABLE TO EDIT/DELETE MAP ANNOTATIONS AND NOT
    @IBAction func editButtonTap(_ sender: Any) {
        
        let button =  sender as! UIBarButtonItem
        if button.title! == "Edit" {
            print("is editing now!")
            button.title = "Done"
            self.tap.isEnabled = true
            tapPinsToDeleteLabel.isHidden = false
            view.frame.origin.y -= tapPinsToDeleteLabel.frame.height / 2.6
        }
        else{
            print("is NOT editing now!")
            button.title = "Edit"
            self.tap.isEnabled = false
            tapPinsToDeleteLabel.isHidden = true
            view.frame.origin.y += tapPinsToDeleteLabel.frame.height / 2.6
        }
    }
    
    @objc func hideIndicator() {
        performUpdatesOnMain {
            self.activityView.stopAnimating()
            self.twoColorHorizontal()
            self.activityView.isHidden = true
            self.overlayView.isHidden = true
        }
    }
    
    func addAnnotationCoordinate(_ pin: Pin) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        mapView.addAnnotation(annotation)
    }
    
    fileprivate func setupFetchedResultsController() {
        
        let entityName = String(describing: Pin.self)
        let fetchRequest = NSFetchRequest<Pin>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "pin")
        fetchedResultsController.delegate = self
        
        if let result = try? context.fetch(fetchRequest) {
            arrayOfPins = result
            for pins in arrayOfPins {
                addAnnotationCoordinate(pins)
                print("fetched pins photos are\(pins.photos?.count)")
            }
        }
        
        do {
            try fetchedResultsController.performFetch()
            print("fetched pins photos are\(fetchRequest.propertiesToFetch?.count)")
            print("fetch successful")
            
        } catch {
            AlertView.alertPopUp(view: self, alertMessage: "could not fetch: \(error.localizedDescription)")
        }
        let fetchCount = try? context.count(for: fetchRequest)
        print("data controller on Map VC contains: \(fetchCount) Pin objects")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Date is: \(Date())")

        setupFetchedResultsController()
        view.addGestureRecognizer(tap)
        tap.numberOfTapsRequired = 1
        tapPinsToDeleteLabel.isHidden = true
        
        randomNumber(start: 1, to: 25)

        self.overlayView.isHidden = false
        self.twoColorHorizontal()

        mapView.delegate = self
        
        let initialLocation = CLLocation(latitude: 39.0997, longitude: -94.5786)
        let regionRadius: CLLocationDistance = 10000000
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
            self.hideIndicator()
        }
        centerMapOnLocation(location: initialLocation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pinFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
                do {
                    let fetchedPins = try context.fetch(pinFetch) as! [Pin]
                    print("NUMBER OF FETCHED PINS IN VIEW WILL APPEAR IS: \(fetchedPins.count)")

                } catch let error as NSError {
                     print("ERROR ON MAP VC VIEW WILL APPEAR FETCH REQUEST \(error.userInfo)")
                    AlertView.alertPopUp(view: self, alertMessage: "ERROR ON FETCH REQUEST - VIEW WILL APPEAR")
                }
        performUpdatesOnMain {
            self.activityView.startAnimating()
        }
      print("arrayOfPins count is: \(arrayOfPins.count)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    func randomNumber(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        if a > b {
            swap(&a, &b)
        }
        self.randomNumberResults = Int(arc4random_uniform(UInt32(b - a + 1))) + a
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapViewShouldReturn(_ mapView: MKMapView) -> Bool {
        mapView.resignFirstResponder()
        return true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? MapAnnotation else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            dequeuedView.animatesWhenAdded = true
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = false
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = view.annotation
        var pin = arrayOfPins.filter{$0.latitude == annotation?.coordinate.latitude && $0.longitude == annotation?.coordinate.longitude}.first
        //let pin = mapPin
        print("Pin is: \(pin)")
        
        if tapPinsToDeleteLabel.isHidden == true {
            
            let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
            photoAlbumVC.passedPin = pin
            photoAlbumVC.context = self.context
            photoAlbumVC.photoAlbum = self.arrayOfPhotos//photoAlbumVC.passedPin.photos?.allObjects as! [Photo]
            //print("passed pin photos are \(photoAlbumVC.passedPin.photos?.allObjects as! [Photo])")
            
                for selectedPin in self.arrayOfPins{
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let pred = NSPredicate(format: "pin = %@" , argumentArray: [pin as Any])
                    fetchRequest.predicate = pred
                    
                    //Create FetchedResultsController
                    photoAlbumVC.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "photos") as! NSFetchedResultsController<Photo>
                 }
            
            navigationController?.pushViewController(photoAlbumVC, animated: true)
            
            } else {
                if let pinToDelete = pin {
                    arrayOfPins.remove(at: arrayOfPins.index(of: pinToDelete)!)
                    context.delete(pinToDelete)
                    self.appDelegate.saveContext()
                }
                mapView.removeAnnotation(view.annotation!)
                print("Pin has been succefully deleted")
                self.appDelegate.saveContext()
                print("MapVC context has been succefully saved")
            }
    }
}

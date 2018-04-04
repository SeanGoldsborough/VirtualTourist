//
//
//  ViewController.swift
//  VirtualTouristV1
//
//  Created by Sean Goldsborough on 11/26/17.
//  Copyright © 2017 Sean Goldsborough. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var arrayOfPins = [Pin]()
    //var arrayOfPins: [Pin]?
    var mapPin: Pin?
    var onePhoto: Photo?
    var arrayOfPhotos = [Photo]()
    //var arrayOfPhotos: [Photo]!
    var selectedIndexPaths: [NSIndexPath]?
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var dataController:DataController!
    
    //var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>
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
    
    func saveContext() {
        do {
            try? context.save()
            print("save context function called in map vc")
        }catch {
            AlertView.alertPopUp(view: self, alertMessage: "ERROR: Unable to save context")
        }
    }
    
//    func initializeFetchedResultsController() {
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
//        let departmentSort = NSSortDescriptor(key: "department.name", ascending: true)
//        let lastNameSort = NSSortDescriptor(key: "lastName", ascending: true)
//        request.sortDescriptors = [departmentSort, lastNameSort]
//        
//        let moc = context
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil) as! NSFetchedResultsController<Pin>
//        fetchedResultsController.delegate = self
//        
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("Failed to initialize FetchedResultsController: \(error)")
//        }
//    }
    
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
            
            //appDelegate.saveContext()
            
            //let entity = String(describing: Pin.self)
            //let entity = NSEntityDescription.entity(forEntityName: "Pin", in: self.context)
            //print("BREAKPOINT!!!")
            //let mapPin = NSManagedObject(entity: Pin.entity(), insertInto: context) as! Pin
            //let mapPin = Pin(entity: Pin.entity(), insertInto: context)
            let mapPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context) as! Pin

            mapPin.latitude = locCoord.latitude
            mapPin.longitude = locCoord.longitude
            mapPin.creationDate = Date()
            
            print("mapPin lat is : \(mapPin.latitude)")
            
            arrayOfPins.insert(mapPin, at: 0)
            
            print("arrayOfPins count is: \(arrayOfPins.count)")
            
            appDelegate.saveContext()
            
            print("mapPin photos are : \(mapPin.photos)")
            
            //print("mapPins in FRC are : \(fetchedResultsController.fetchedObjects!.count)")
            
            FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(mapPin.latitude)", long: "\(mapPin.longitude)", pageNum: randomNumberResults, chosenPin: mapPin) { (photosURLs, error) in

                print("returnedPhotoURLs from FlickrGetPhotosCall On long press geusture is\(photosURLs)")

                guard let photosURLs = photosURLs else {
                    AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos")
                    return
                }

                //                    let entity = NSEntityDescription.entity(forEntityName: "Pin", in: self.dataController.viewContext)
                //                    let mapPin = NSManagedObject(entity: entity!, insertInto: self.dataController.viewContext) as! Pin

                let photo = Photo(context: self.context)
                let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.context)
                let photoModel = Photo(entity: Photo.entity(), insertInto: self.context)
                //let photoModel = NSManagedObject(entity: Photo.entity(), insertInto: self.context) as! Photo
                //photoModel.property1 = "some value"
                //photoModel.videoId = video.valueForKeyPath("snippet.resourceId.videoId") as? String

                for returnedURLs in photosURLs {
                    photoModel.photoURL = returnedURLs as! String
                    self.addPhotos(creationDate: photoModel.creationDate! as Date, photoURL: photoModel.photoURL!)
                    print("returnedPhotoURLs in photo model are\(photoModel.photoURL)")

                    do {
                        mapPin.photos = NSSet(object: photoModel)
                        try self.appDelegate.saveContext()
                        print("Photos photos count is : \(photoModel.creationDate)")
                        print("map pin photos: \(mapPin.photos)")
                        print("map pin debug: \(mapPin.debugDescription)")
                    }
                    catch {
                        AlertView.alertPopUp(view: self, alertMessage: "error loading photos to core data!")
                        print("Error loading photos to core data!: \(error)")
                    }
                }
            }
            
            self.mapView.addAnnotation(annotation)
            print("mapView.annotations.count is: \(mapView.annotations.count)")
            //print(" arrayOfPins.count is: \(self.arrayOfPins.count as? Int)")
            self.arrayOfPins.append(mapPin)
            //                let index = IndexPath(row: arrayOfPins.count - 1, section: 0)
            //                let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
            //                let collVC = photoAlbumVC.collectionView
            //                collVC?.insertItems(at: [index])
            appDelegate.saveContext()
            print("mapPin photos are : \(mapPin.photos?.count)")
            
        }
    }
    
    /// Adds a new photo to the end of the `photoalbum` array
    func addPhotos(creationDate: Date, photoURL: String ) {
        let photo = Photo(context: self.context)
        photo.photoURL = photoURL
        photo.creationDate = Date() as NSDate
        try? appDelegate.saveContext()
    }
    
    /// Deletes the photo at the specified index path
    func deletePhotos(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        context.delete(photoToDelete)
        try? appDelegate.saveContext()
    }
    
    @objc func tapToDeletePin() {
        let annotation = MKPointAnnotation()
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
//      let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
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
            print("fetch successful")
            
        } catch {
            //fatalError("could not fetch: \(error.localizedDescription)")
            AlertView.alertPopUp(view: self, alertMessage: "could not fetch: \(error.localizedDescription)")
        }
        
        let fetchCount = try? context.count(for: fetchRequest)
        
        print("data controller on Map VC contains: \(fetchCount) Pin objects")
        
    }
    
    // Create fetch request
//    func pinFetchRequest() -> [Pin] {
//        let context = CoreDataStack.sharedInstance().context
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil) as! NSFetchedResultsController<Pin>
//
//        // Get the saved pins
//        do {
//            return try context.fetch(fetchRequest) as! [Pin]
//        } catch {
//            print("There was an error fetching the list of pins.")
//            return [Pin]()
//        }
//    }
    
    //    // Map persistent data
    //    func mapSavedAnnotations() {
    //
    //        let pins = pinFetchRequest()
    //
    //        for pin in pins {
    //            let annotation = MKPointAnnotation()
    //            annotation.coordinate = pin.coordinate
    //            mapView.addAnnotation(annotation)
    //        }
    //    }
    
    func viewPhotosFromPin(_ tappedPin: Pin) {
        let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
        photoAlbumVC.passedPin = mapPin
        navigationController!.pushViewController(photoAlbumVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        
        
        view.addGestureRecognizer(tap)
        tap.numberOfTapsRequired = 1
        tapPinsToDeleteLabel.isHidden = true
        
        randomNumber(start: 1, to: 25)
        
        self.activityView.startAnimating()
        self.overlayView.isHidden = false
        self.twoColorHorizontal()
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.hideIndicator), userInfo: nil, repeats: false)
        
        mapView.delegate = self
        let initialLocation = CLLocation(latitude: 39.0997, longitude: -94.5786)
        let regionRadius: CLLocationDistance = 10000000
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        centerMapOnLocation(location: initialLocation)
        //        print("arrayOfPins count is: \(arrayOfPins.count)")
        //        print("arrayOfPins is: \(arrayOfPins)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO: THISSSSSSSSSDDDDDDDOOOOOOOOOOOOOEEEEEEEEESSSSSSSSSSNNNNNNNNNNNNNTTTTTTTTTTWWWWWWWWOOOOOOOOOOORRRRRRRRRRRKKKKKKKKKKK!!!!!!!!!
        
        let moc = self.context
        let pinFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        do {
            let fetchedPins = try moc.fetch(pinFetch) as! [Pin]
            AlertView.alertPopUp(view: self, alertMessage: "FETCH REQUEST - VIEW WILL APPEAR was called")
//                do {
//                    try context.fetch(Pin.fetchRequest())
                    //try context.fetch(Pin.fetchRequest())
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
        let pin = arrayOfPins.filter{$0.latitude == annotation?.coordinate.latitude && $0.longitude == annotation?.coordinate.longitude}.first
        //let pin = mapPin
        print("Pin is: \(pin)")
        
        if tapPinsToDeleteLabel.isHidden == true {
            
            let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
            //
            //                    photoAlbumVC.passedLat = view.annotation?.coordinate.latitude
            //                    photoAlbumVC.passedLong = view.annotation?.coordinate.longitude
            photoAlbumVC.passedPin = pin ?? mapPin
            //photoAlbumVC.context = self.context
            //photoAlbumVC.photoAlbum = photoAlbumVC.passedPin.photos?.allObjects as! [Photos]
            //print("passed pin photos are \(photoAlbumVC.passedPin.photos?.allObjects as! [Photos])")
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let pred = NSPredicate(format: "pin = %@" , argumentArray: [pin as Any])
            fetchRequest.predicate = pred
            
            //Create FetchedResultsController
            photoAlbumVC.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "photos") as! NSFetchedResultsController<Photo>
            
            navigationController?.pushViewController(photoAlbumVC, animated: true)
            
        } else {
            if let pinToDelete = pin {
                arrayOfPins.remove(at: arrayOfPins.index(of: pinToDelete)!)
                context.delete(pinToDelete)
                appDelegate.saveContext()
            }
            mapView.removeAnnotation(view.annotation!)
            print("Pin has been succefully deleted")
        }
    }
    
    //    // MARK: MKMapViewDelegate
    
    func mapViewShouldReturn(_ mapView: MKMapView) -> Bool {
        mapView.resignFirstResponder()
        return true
    }
    
}



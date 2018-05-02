////
////  OldCollVC.swift
////  VirtualTouristv2
////
////  Created by Sean Goldsborough on 4/29/18.
////  Copyright © 2018 Sean Goldsborough. All rights reserved.
////
//
//import Foundation
//import UIKit
//import MapKit
//import CoreData
//
//class CollectionViewController: UIViewController, MKMapViewDelegate {
//    
//    fileprivate let itemsPerRow: CGFloat = 3
//    
//    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 50.0, right: 20.0)
//    
//    var appDelegate = UIApplication.shared.delegate as! AppDelegate
//    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    
//    var fetchedResultsController: NSFetchedResultsController<Photo>!
//    var fetchedResultsControllerPin: NSFetchedResultsController<Pin>!
//    
//    var passedPin: Pin!
//    var photosInPin = 0
//    
//    var photoAlbum = [Photo]()
//    //var selectedIndexes = [IndexPath]()
//    var indexPathSelected = [IndexPath]()
//    //var indexPathToRemove = [IndexPath]()
//    
//    var urlArray = [String]()
//    //var photos: [NSManagedObject] = []
//    var blockOperations: [BlockOperation] = []
//    
//    var randomNumberResults: Int?
//    
//    //var collCell = CollectionViewCell()
//    
//    private let reuseIdentifier = "CollectionItem"
//    
//    @IBOutlet weak var collectionView: UICollectionView!
//    
//    @IBOutlet weak var mapViewColl: MKMapView!
//    
//    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
//    
//    @IBOutlet weak var bottomButton: UIButton!
//    
//    /// Adds a new photo to the end of the `photoalbum` array
//    //func addPhotos(creationDate: Date, photoURL: String, photoData: NSData, mapPin: Pin) {
//    //    func addPhotos(creationDate: Date, photoURL: String, mapPin: Pin) {
//    //        let photo = Photo(context: self.context)
//    //        photo.creationDate = Date()
//    //        photo.photoURL = photoURL
//    //        photo.pin = self.passedPin
//    //        //mapPin = passedPin
//    //
//    //        do{
//    //            let url = URL(string: photoURL)
//    //            var imageData = try NSData(contentsOf: url!)
//    //            //imageData = photoData
//    //
//    //            photo.photoData = imageData
//    //            print("photoData is: \(photo.photoData)")
//    //            //imageData
//    //
//    //        }
//    //        catch let error as NSError {
//    //            AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again.")
//    //        }
//    //
//    //        //photo.photoData = photoData
//    //        getImage(urlString: photoURL) { (photoData, error) in
//    //            print("photo data in add photos is\(photoData)")
//    //            //photo.photoData = photoData
//    //
//    //        }
//    //        //photo.photoData = photoData
//    //        //        FlickrAPIClient.sharedInstance().getImage(urlString: photoURL) { (photoDataResults, error) in
//    //        //            photo.photoData = photoDataResults as! NSData
//    //        //            print("photoDataResults are \(photoDataResults)")
//    //        //            print("photoDataResults are also \(photo.photoData)")
//    //        //        })
//    //
//    //        //        if photoDataResults != nil {
//    //        //            photo.photoData = photoDataResults as! NSData
//    //        //        }
//    //        performUpdatesOnMain {
//    //            self.photoAlbum.append(photo)
//    //            self.appDelegate.saveContext()
//    //            print("save context in addPhotos CVC was called")
//    //        }
//    //
//    //
//    //        //try? appDelegate.saveContext()
//    //    }
//    
//    fileprivate func getFlickrPhotos() {
//        
//        randomNumber(start: 1, to: 25)
//        
//        //TODO: When you are updating the data, first fetch the core data object using NSFetchRequest and then update the necessary data. Then make an attempt to save. You might be trying to update the data without fetching.
//        
//        FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(self.passedPin.latitude)", long: "\(self.passedPin.longitude)", pageNum: self.randomNumberResults!, chosenPin: self.passedPin) { (newPhotoURLs, error) in
//            print("refresh button has been pressed")
//            print("page number is \(self.randomNumberResults)")
//            print("getFlickrPhotos cvc results are \(newPhotoURLs)")
//            
//            //TODO add in some code to create new photo
//            
//            performUpdatesOnMain {
//                //self.photoAlbum.removeAll()
//                self.removeAllPhotos()
//                //self.context.delete(self.passedPin.photos)
//                self.bottomButton.isEnabled = false
//            }
//            
//            if newPhotoURLs != nil {
//                self.urlArray.removeAll()
//                self.urlArray = newPhotoURLs!
//                print("photos are in!")
//                print("url array is: \(self.urlArray)")
//                
//                performUpdatesOnMain {
//                    self.collectionView.reloadData()
//                    self.bottomButton.isEnabled = true
//                    self.appDelegate.saveContext()
//                }
//                
//            } else {
//                print(error ?? "error on refreshing photos")
//                performUpdatesOnMain {
//                    AlertView.alertPopUp(view: self, alertMessage: "No Photos Found")
//                }
//            }
//            
//            print("passedPin is: \(self.passedPin)")
//            
//            for returnedURLs in newPhotoURLs! {
//                //let pin = self.passedPin
//                print("pin lat  is: \(self.passedPin.latitude)")
//                //let photo = Photo(context: self.context)
//                let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.context)
//                let photoModel = Photo(entity: Photo.entity(), insertInto: self.context)
//                
//                let date = Date()
//                photoModel.creationDate = date
//                photoModel.photoURL = returnedURLs as! String
//                photoModel.pin = self.passedPin
//                
//                
//                //                for photo in photos! {
//                //                    let context = self.context
//                //                    if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
//                //                        photoTemp = Photo(entity: entity, insertInto: context)
//                //                        //photoTemp?.photoURL = photo["url_m"] as? String
//                //                        photoTemp?.pin = self.passedPin!
//                //                    }
//                //                }
//                
//                
//                
//                do{
//                    let url = URL(string: photoModel.photoURL!)
//                    var imageData = try NSData(contentsOf: url!)
//                    //imageData = photoData
//                    
//                    photoModel.photoData = imageData
//                    //print("photoData is: \(photoModel.photoData)")
//                    //imageData
//                    
//                }
//                catch let error as NSError {
//                    AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again.")
//                }
//                
//                //self.addPhotos(creationDate: photoModel.creationDate! as Date, photoURL: photoModel.photoURL!, photoData: photoModel.photoData!, mapPin: photoModel.pin!)
//                //self.addPhotos(creationDate: photoModel.creationDate! as Date, photoURL: photoModel.photoURL!, mapPin: photoModel.pin!)
//                print("Pin is: \(photoModel.pin)")
//                print("returnedPhotoURLs in photo model are\(photoModel.photoURL)")
//                //print("returnedPhotoData in photo model are\(photoModel.photoData)")
//                
//                //self.photoAlbum.append(photoModel)
//                print("photoAlbum/photo model are\(self.photoAlbum)")
//                print("photoAlbum count is \(self.photoAlbum.count)")
//            }
//            performUpdatesOnMain {
//                self.appDelegate.saveContext()
//                //self.collectionView.reloadData()
//                print("mapPin photos are : \(self.passedPin.photos?.count)")
//            }
//            
//        }
//    }
//    
//    
//    
//    func getImage(urlString: String, completionHandler: @escaping (_ results:NSData?,_ error:NSError?) -> ()){
//        do{
//            let url = URL(string: urlString)
//            let imageData = try NSData(contentsOf: url!)
//            completionHandler(imageData,nil)
//        }
//        catch let error as NSError {
//            completionHandler(nil,error)
//        }
//    }
//    
//    /// Adds a new photo to the end of the `photoalbum` array
//    func addPhotos(creationDate: Date, photoURL: String, photoData: NSData?, mapPin: Pin) {
//        let photo = Photo(context: self.context)
//        print("addPhotosCV was called - photo is in context?")
//        var date = Date()
//        photo.creationDate = date
//        print("addPhotosCV creationDate is: \(photo.creationDate)")
//        photo.photoURL = photoURL
//        photo.pin = self.passedPin
//        print("addPhotosCV was called")
//        
//        do{
//            let url = URL(string: photoURL)
//            var imageData = try NSData(contentsOf: url!)
//            photo.photoData = imageData
//            if photo.photoData != nil {
//                print("photo.photoDataCV has data!")
//            }
//            //print("photoData is: \(photo.photoData)")
//        }
//        catch let error as NSError {
//            AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again.")
//        }
//        
//        //        getImage(urlString: photoURL) { (photoData, error) in
//        //            //print("photo data in add photos is\(photoData)")
//        //            print("getImageCV was called")
//        //        }
//    }
//    
//    @IBAction func refreshRemoveButton(_ sender: Any) {
//        
//        performUpdatesOnMain {
//            print("refresh button has been pressed")
//            for photo in self.photoAlbum {
//                self.context.delete(photo as! Photo)
//                print("Passed Pin Photo count in for loop is: \(self.passedPin.photos?.count)")
//                self.appDelegate.saveContext()
//            }
//            
//            print("Passed Pin Photo count after loop is:  \(self.passedPin.photos?.count)")
//            self.photoAlbum.removeAll()
//            print("Photo count after loop is \(self.photoAlbum.count)")
//            //self.fetchPassedPinAgain()
//            self.appDelegate.saveContext()
//            self.collectionView.reloadData()
//            print("coll vc reloaded data")
//        }
//        
//        print("Passed Pin Photo count is now: \(self.passedPin.photos?.count)")
//        print("self.photoAlbum count is now: \(self.photoAlbum.count)")
//        
//        randomNumber(start: 1, to: 25)
//        
//        //USE FROM HERE: NEED TO EDIT THIS SO IT WORKS LIKE THE ONE IN MAP VIEW DOES AND THEN REFACTOR TO MAKE THEM ALL WORK FROM ONE PLACE ie FLICKERAPICLIENT
//        
//        //        FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(passedPin.latitude)", long: "\(passedPin.longitude)", pageNum: self.randomNumberResults!, chosenPin: passedPin) { (photosURLs, error) in
//        //
//        //            print("returnedPhotoURLs from FlickrGetPhotosCall On long press geusture is\(photosURLs)")
//        //
//        //            guard let photosURLs = photosURLs else {
//        //                AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos")
//        //                return
//        //            }
//        //
//        //            for returnedURLs in photosURLs {
//        //                let photo = Photo(context: self.context)
//        //                print("for returnedURLs in photosURLs is called - \(self.passedPin.photos)")
//        //                let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.context)
//        //                let photoModel = Photo(entity: Photo.entity(), insertInto: self.context)
//        //
//        //                //let photoModel = Photo()
//        //
//        //                var date = Date()
//        //                photoModel.creationDate = date
//        //                photoModel.photoURL = returnedURLs as! String
//        //                photoModel.pin = self.passedPin
//        //
//        //                do{
//        //                    let url = URL(string: photoModel.photoURL!)
//        //                    var imageData = try NSData(contentsOf: url!)
//        //                    photoModel.photoData = imageData
//        //                    if photo.photoData != nil {
//        //                        print("2photo.photoData has data!")
//        //                    }
//        //                }
//        //                catch let error as NSError {
//        //                    AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again.")
//        //                }
//        //
//        //                self.addPhotos(creationDate: photoModel.creationDate!, photoURL: photoModel.photoURL!, photoData: photoModel.photoData, mapPin: photoModel.pin!)
//        //                print("passedPin pin photos count: \(self.passedPin.photos?.count)")
//        //                print("map pin debug: \(self.passedPin.debugDescription)")
//        //                print("self.context is changed?: \(self.context.hasChanges)")
//        //            }
//        //            self.appDelegate.saveContext()
//        //        }
//        //
//        //        performUpdatesOnMain {
//        //
//        //            print("passedPin is: \(self.passedPin)")
//        //            print("passedPin photos are : \(self.passedPin.photos?.count)")
//        //            print("self.context is changed?:1 \(self.context.hasChanges)")
//        //        }
//        //    }
//        
//        
//        /////////
//        FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(self.passedPin.latitude)", long: "\(self.passedPin.longitude)", pageNum: self.randomNumberResults!, chosenPin: self.passedPin) { (newPhotoURLs, error) in
//            print("refresh button has been pressed")
//            self.photoAlbum.removeAll()
//            print("Photo count after loop  and Flickr call is \(self.photoAlbum.count)")
//            print("page number is \(self.randomNumberResults)")
//            print("getFlickrPhotos cvc results are \(newPhotoURLs)")
//            
//            print("returnedPhotoURLs from FlickrGetPhotosCall On long press geusture is\(newPhotoURLs)")
//            
//            guard let newPhotoURLs = newPhotoURLs else {
//                AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos")
//                return
//            }
//            
//            performUpdatesOnMain {
//                //self.context.delete(self.passedPin.photos)
//                self.bottomButton.isEnabled = false
//            }
//            
//            if newPhotoURLs != nil {
//                self.urlArray.removeAll()
//                self.urlArray = newPhotoURLs
//                print("photos are in!")
//                print("url array is: \(self.urlArray)")
//                
//                performUpdatesOnMain {
//                    self.collectionView.reloadData()
//                    self.bottomButton.isEnabled = true
//                    self.appDelegate.saveContext()
//                }
//            } else {
//                print(error ?? "error on refreshing photos")
//                performUpdatesOnMain {
//                    AlertView.alertPopUp(view: self, alertMessage: "No Photos Found")
//                }
//            }
//            print("passedPin is: \(self.passedPin)")
//            for returnedURLs in newPhotoURLs {
//                
//                let pin = self.passedPin
//                print("pin lat  is: \(pin?.latitude)")
//                let photo = Photo(context: self.context)
//                print("for returnedURLs in passedPinURLs is called - \(pin?.photos)")
//                let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.context)
//                let photoModel = Photo(entity: Photo.entity(), insertInto: self.context)
//                var date = Date()
//                photoModel.creationDate = date
//                photoModel.photoURL = returnedURLs as! String
//                photoModel.pin = self.passedPin
//                
//                photoModel.photoURL = returnedURLs as! String
//                
//                do{
//                    let url = URL(string: photoModel.photoURL!)
//                    var imageData = try NSData(contentsOf: url!)
//                    photoModel.photoData = imageData
//                    if photo.photoData != nil {
//                        print("2photo.photoData has data!")
//                    }
//                }
//                catch let error as NSError {
//                    AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again.")
//                }
//                
//                //self.addPhotos(creationDate: photoModel.creationDate! as Date, photoURL: photoModel.photoURL!, photoData: photoModel.photoData!, mapPin: self.passedPin!)
//                print("self.context is changed?: \(self.context.hasChanges)")
//                //self.addPhotos(creationDate: photoModel.creationDate!, photoURL: photoModel.photoURL!, mapPin: photoModel.pin!)
//                
//                print("Pin is: \(self.passedPin!)")
//                print("returnedPhotoURLs in photo model are\(photoModel.photoURL)")
//                print("returnedPhotoData in photo model are\(photoModel.photoData)")
//                
//                self.photoAlbum.append(photoModel)
//                print("photoAlbum/photo model are\(self.photoAlbum)")
//                print("photoAlbum count in refresh button is \(self.photoAlbum.count)")
//            }
//            performUpdatesOnMain {
//                //self.context.insert(self.photoAlbum)
//                self.collectionView.reloadData()
//                self.appDelegate.saveContext()
//                
//            }
//        }
//    }
//    
//    func randomNumber(start: Int, to end: Int) -> Int {
//        var a = start
//        var b = end
//        if a > b {
//            swap(&a, &b)
//        }
//        self.randomNumberResults = Int(arc4random_uniform(UInt32(b - a + 1))) + a
//        print("page number again is \(randomNumberResults)")
//        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
//    }
//    
//    func removeAllPhotos() {
//        
//        for object in fetchedResultsController.fetchedObjects! {
//            print("Photo to be deleted in removeAllPhotos is: \(object.objectID) && \(object.photoURL)")
//            context.delete(object as! Photo)
//            print("removeAllPhotos delete method has been called on: \(object.objectID) && \(object.photoURL)")
//            print("Passed Pin Photo count \(self.passedPin.photos?.count)")
//        }
//        
//        self.photoAlbum = []
//        print("PhotoAlbum Photo count is \(self.photoAlbum.count)")
//    }
//    
//    
//    fileprivate func setupFetchedResultsController() {
//        
//        // let entityName = String(describing: Photo.self)
//        //let fetchRequest = NSFetchRequest<Photo>(entityName: entityName)
//        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
//        //let myPredicate = NSPredicate(format: "pin == %@", self.passedPin!)
//        let myPredicate = NSPredicate(format: "pin == %@", argumentArray: [self.passedPin])
//        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
//        fetchRequest.predicate = myPredicate // condition
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        
//        
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController.delegate = self
//        
//        do {
//            try fetchedResultsController.performFetch()
//            print("CV fetch successful")
//            let fetchCount = try? context.count(for: fetchRequest)
//            print("data controller on CV VC contains: \(fetchCount) Photo objects")
//            
//        } catch {
//            //fatalError("could not fetch: \(error.localizedDescription)")
//            AlertView.alertPopUp(view: self, alertMessage: "CVcould not fetch: \(error.localizedDescription)")
//        }
//        
//        let fetchCount = try? context.count(for: fetchRequest)
//        
//        print("data controller on CV VC contains: \(fetchCount) Photo objects")
//        
//        //added 4/18
//        let fetchedObjects = fetchedResultsController.fetchedObjects
//        print(fetchedObjects?.count)
//        if fetchedObjects?.count != 0{
//            print("Count of images \(fetchedObjects?.count)")
//            
//            for image in fetchedObjects! {
//                let fetchedImage = image
//                self.photoAlbum.append(fetchedImage)
//                print("photoAlbum count in setupFRC is: \(self.photoAlbum.count)")
//            }
//            performUpdatesOnMain {
//                self.collectionView.reloadData()
//            }
//        }
//        if fetchedObjects?.count == 0 {
//            //getFlickrPhotos()
//            //getPhotosFromFlickr(pageNumber: randomNumberResults!)
//        }
//    }
//    
//    @objc func someFunc() {
//        
//        print("It Works")
//        // AlertView.alertPopUp(view: self, alertMessage: "Select a photo to delete.")
//        //AlertView.alertMessage(view: self, title: "Edit Photo Album", message: "Select a photo to delete.", numberOfButtons: 1, leftButtonTitle: "Continue", leftButtonStyle: 0, rightButtonTitle: "", rightButtonStyle: 0)
//    }
//    
//    var editButtonPressed = false
//    
//    @objc func editButtonTap(_ sender: Any) {
//        
//        let button =  sender as! UIBarButtonItem
//        if button.title! == "Edit" {
//            print("is editing now!")
//            button.title = "Done"
//            AlertView.alertMessage(view: self, title: "Edit Photo Album", message: "Select a photo to delete.", numberOfButtons: 1, leftButtonTitle: "Continue", leftButtonStyle: 0, rightButtonTitle: "", rightButtonStyle: 0)
//            self.editButtonPressed = true
//        }
//        else{
//            print("is NOT editing now!")
//            button.title = "Edit"
//            self.editButtonPressed = false
//        }
//    }
//    
//    
//    
//    func fetchPassedPinAgain() {
//        
//        let entityName = String(describing: Pin.self)
//        //let fetchRequest = NSFetchRequest<Pin>(entityName: entityName)
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        let latNeeded = self.passedPin!.latitude
//        let longNeeded = self.passedPin!.longitude
//        
//        print("coords needed are \(latNeeded) and \(longNeeded)")
//        
//        //        let latitudePredicate = NSPredicate(format: "latitude = %@", latNeeded)
//        //        let longitudePredicate = NSPredicate(format: "longitude = %@", longNeeded)
//        //        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [latitudePredicate, longitudePredicate])
//        
//        let predicateIsNumber = NSPredicate(format: "latitude == %@", NSNumber(value: latNeeded))
//        let predicateIsEnabled = NSPredicate(format: "longitude == %@", NSNumber(value: longNeeded))
//        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateIsNumber, predicateIsEnabled])
//        
//        //check here for the sender of the message
//        
//        fetchRequest.predicate = andPredicate
//        
//        //fetchRequest.predicate = andPredicate
//        print("fetchPredicate is \(fetchRequest.predicate)")
//        fetchedResultsControllerPin = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "pin") as! NSFetchedResultsController<Pin>
//        fetchedResultsControllerPin.delegate = self
//        
//        if let newPin = try? context.fetch(fetchRequest) {
//            print("new fetched pin results are\(newPin)")
//            self.passedPin = nil
//            print("old pin is\(self.passedPin)")
//            for pin in newPin {
//                self.passedPin = pin as! Pin
//                print("fetched pin is\(pin)")
//                print("fetched pin is also\(self.passedPin)")
//            }
//        }
//        
//        do {
//            try fetchedResultsControllerPin.performFetch()
//            print("fetched pins fetch again are\(fetchRequest.propertiesToFetch?.count)")
//            print("fetch successful")
//            
//            print("newly fetched pin is \(fetchRequest.propertiesToFetch?.count)")
//            
//        } catch {
//            AlertView.alertPopUp(view: self, alertMessage: "could not fetch: \(error.localizedDescription)")
//        }
//        let fetchCount = try? context.count(for: fetchRequest)
//        print("fetched pins fetch again are on Collection VC contains: \(fetchCount) Pin objects")
//        
//        
//    }
//    
//    
//    
//    ///////////////////////////////////////////////////////////////////////////////////////////////
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupFetchedResultsController()
//        //print("number of photosInPin are: \(passedPin.photos)")
//        print("photoAlbum count in viewDidLoad is: \(self.photoAlbum.count)")
//        randomNumber(start: 1, to: 50)
//        
//        print("passedPin is: \(passedPin)")
//        self.photosInPin = self.passedPin.photos!.count
//        print("number of photosInPin are: \(photosInPin)")
//        
//        if passedPin.photos!.count < 1 {
//            //getFlickrPhotos()
//        }
//        
//        
//        
//        //        navigationItem.rightBarButtonItem = editButtonItem
//        //        if editButtonItem.title = "Done" {
//        //            print("edit button is working and editing")
//        //        } else {
//        //            print("edit button is NOT working and editing")
//        //        }
//        
//        let rightButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editButtonTap))
//        self.navigationItem.rightBarButtonItem = rightButton
//        
//        //self.collCell.isSelected == false
//        //self.collCell.activityIndicator.startAnimating()
//        self.bottomButton.isEnabled = true
//        
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView?.allowsMultipleSelection = false
//        
//        mapViewColl.delegate = self
//        
//        let passedPinLocation = CLLocation(latitude: self.passedPin.latitude, longitude: self.passedPin.longitude)
//        let regionRadius: CLLocationDistance = 1000000
//        func centerMapOnLocation(location: CLLocation) {
//            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
//                                                                      regionRadius, regionRadius)
//            mapViewColl.setRegion(coordinateRegion, animated: true)
//        }
//        
//        centerMapOnLocation(location: passedPinLocation)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = CLLocationCoordinate2D(latitude: self.passedPin.latitude, longitude: self.passedPin.longitude)
//        mapViewColl.addAnnotation(annotation)
//        
//        performUpdatesOnMain {
//            //            self.fetchPassedPinAgain()
//            //self.setupFetchedResultsController()
//            self.collectionView.reloadData()
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("the photo album array count in viewWillAppear is: \(photoAlbum.count)")
//        
//        performUpdatesOnMain {
//            //self.setupFetchedResultsController()
//            self.collectionView.reloadData()
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        fetchedResultsController = nil
//    }
//    
//    // Configure Cell - what to display? - get it from object returned to "fetchedResultsController" earlier@
//    func configureCell(_ cell: CollectionViewCell, atIndexPath indexPath: IndexPath) {
//        print("in configureCell")
//        cell.activityIndicator.startAnimating()
//        cell.overlayView.isHidden = false
//        //TODO:  !!!! FIX THIS SO THAT IT WORKS RIGHT! MAYBE CALL DIFFERENT METHOD ON CELL?
//        // let rightButton = self.navigationItem.rightBarButtonItem
//        
//        //        if self.editButtonPressed == true {
//        //            cell.isUserInteractionEnabled = true
//        //        } else {
//        //            cell.isUserInteractionEnabled = false
//        //        }
//        
//        // MARK: TESTING ONLY
//        // try to get photo from the fetchedResultsController
//        let photos = [fetchedResultsController.fetchedObjects]
//        print("photos here is the fetchedObjects \(photos.count)")
//        
//        
//        
//        
//        // MARK - real code:
//        let photo = self.fetchedResultsController.object(at: indexPath)
//        
//        // return Photo object at the indexPath - includes - mediaURl, photoName & imageData, etc - check imageData == nil?
//        
//        // unwrap optional... 1. if first time, it's nil, if second time != nil
//        if let photoImageData = photo.photoData {
//            
//            // if != nil, then display
//            print("Grabbing CoreData's EXISTING imageData, no API is needed for this image, \(photo.photoURL)")
//            
//            let image = UIImage(data: photoImageData as Data)
//            //var image: NSData
//            do{
//                let url = URL(string: photo.photoURL!)
//                let imageData = try Data(contentsOf: url!)
//                let image = imageData
//                
//            }
//            catch let error as NSError {
//                print("error on configure cell\(error.localizedDescription)")
//            }
//            
//            
//            cell.cellImage.image = image
//            cell.activityIndicator.stopAnimating()
//            cell.activityIndicator.isHidden = true
//            cell.overlayView.isHidden = true
//            //cell.activityIndicator.stopAnimating()
//            
//        } else {
//            
//            // display UIImage with placeholder first!
//            // cell.photoImageView.image = #imageLiteral(resourceName: "placeHolder")
//            cell.cellImage.image = #imageLiteral(resourceName: "VirtualTourist_76")
//            cell.activityIndicator.stopAnimating()
//            cell.activityIndicator.isHidden = true
//            cell.overlayView.isHidden = true
//            //self.hideAI(cell, false) // show activity Indicator
//            
//            print("API to get ImageData should start! for \(photo.photoURL)")
//            
//            // call URLSession to get the ImageData
//            // getImageData() // need completion handler, get back the binary data back + display placeholder before data is back
//            let photoURL = photo.photoURL // Photo's url is string already - @NSManaged public var mediaURL: String?
//            
//            // API call
//            print("getImageData API call should be triggered")
//            
//            FlickrAPIClient.sharedInstance().getDataForPhoto(photo, photo.photoURL!, completionHandlerForGetImageData: { (imageData, error) in // "imageData" as NSData
//                
//                // print("API to get ImageData is starting! for \(photo.photoName)")
//                
//                if let error = error {
//                    print("ImageData cannot be retrieved from Flickr server")
//                } else { // error is nil
//                    // unwrap photoImageData + updating UI...
//                    if let photoImageData = imageData {
//                        
//                        // avoid blocking UI
//                        DispatchQueue.main.async {
//                            // add value to Photo's property "imageData" (NSData)
//                            photo.photoData = photoImageData
//                            
//                            // need to call .save on the current Context - to really save it to CoreData!
//                            // Call it with do/ try/ catch block - to avoid FAILURE
//                            do {
//                                try self.appDelegate.saveContext()
//                                print("Successuly saved property imageData to Photo")
//                            } catch {
//                                print("Save failed for - property imageData to Photo ")
//                            }
//                            
//                            // retrieve url from coreData again for the image...
//                            let image = UIImage(data: photoImageData as Data)
//                            
//                            //self.hideAI(cell, true) // hide activity Indicator
//                            cell.activityIndicator.stopAnimating()
//                            cell.activityIndicator.isHidden = true
//                            cell.overlayView.isHidden = true
//                            cell.cellImage.image = image
//                            print("displaying photo \(photo.photoURL) onto the screen")
//                        } // END of DispatchQueue.main.async {
//                        
//                    } // END of if let photoImageData = imageData {
//                } // END of if/ else block
//            }) // END of FlickrConvenience.sharedInstance().getImageData(photo, ima
//        } // END of if/else block of if let photoImageData
//        cell.activityIndicator.isHidden = true
//        // MARK: change Opaque of selected cell - distinguish selected or not
//        //        if let _ = indexPathSelected.index(of: indexPath) { // if found in [selectedIndexes]
//        //            cell.cellImage.alpha = 0.5
//        //
//        //        } else {
//        //            cell.cellImage.alpha = 1.0
//        //        }
//    } // END of func configureCell
//}
//
//// MARK: - Navigation
//
//extension CollectionViewController : UICollectionViewDataSource {
//    
//    //    func updateItems(updates: [CollectionViewCell]) {
//    //        collectionView.performBatchUpdates({
//    //            for update in updates {
//    //                switch update {
//    //                case .Add(let index):
//    //                    collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
//    //                    itemCount += 1
//    //                case .Delete(let index):
//    //                    collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
//    //                    itemCount -= 1
//    //                }
//    //            }
//    //        }, completion: nil)
//    //    }
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        //return 1
//        return fetchedResultsController.sections?.count ?? 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("the photo album array count in # of items in section is: \(photoAlbum.count)")
//        
//        print("Get numberOfItemsInSection", section, photoAlbum.count, fetchedResultsController.sections![section].numberOfObjects)
//        //let fetchedRC = fetchedResultsController
//        //return photosInPin
//        //        let sectionInfo = self.fetchedResultsController.sections![section]
//        //
//        //        print("number of Cells: \(sectionInfo.numberOfObjects)")
//        //        return sectionInfo.numberOfObjects
//        
//        return fetchedResultsController.sections![section].numberOfObjects
//        //return 21
//        //return photoAlbum.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        //print("cellForItemAt func actualally waorks!!!")
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
//        configureCell(cell, atIndexPath: indexPath)
//        //        cell.cellImage.image = #imageLiteral(resourceName: "VirtualTourist_76")
//        //        cell.activityIndicator.isHidden = false
//        //        cell.overlayView.isHidden = false
//        //        cell.activityIndicator.startAnimating()
//        //
//        //
//        //        if let imageData = try? Data(contentsOf: URL(string: self.photoAlbum[indexPath.row].photoURL!)!) {
//        //            cell.cellImage.image =  UIImage(data: imageData)
//        //            cell.activityIndicator.stopAnimating()
//        //            cell.activityIndicator.hidesWhenStopped = true
//        //            cell.overlayView.isHidden = true
//        
//        
//        //        }
//        
//        performUpdatesOnMain {
//            self.appDelegate.saveContext()
//        }
//        
//        return cell
//    }
//    
//    //    func deletePhotos(at indexPath: IndexPath) {
//    //        let photoToDelete = fetchedResultsController.object(at: indexPath)
//    //        context.delete(photoToDelete)
//    //        try? appDelegate.saveContext()
//    //    }
//    
//    //    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
//    //        print("didSelect func actualally waorks!!!")
//    ////
//    ////        if editButtonItem.title == "Done" {
//    ////            print("edit button works!")
//    ////
//    ////        } else if editButtonItem.title == "Edit" {
//    ////            print("edit button not yet working")
//    ////        }
//    ////
//    ////        let indexPaths = collectionView.indexPathsForSelectedItems!
//    ////        print(indexPaths)
//    ////
//    ////        let index = self.collectionView.indexPathsForSelectedItems?.first
//    ////        print("coll vc didSelect func index is \(index)")
//    ////
//    ////        performUpdatesOnMain {
//    ////            self.collectionView.deleteItems(at: [indexPath])
//    ////            self.collectionView.reloadData()
//    ////        }
//    //
//    //        let alert = UIAlertController(title: nil, message: "Delete Picture ? ", preferredStyle: .alert)
//    //        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in
//    //            self.context.delete(self.photoAlbum[indexPath.row])
//    //            self.photoAlbum.remove(at: indexPath.row )
//    //
//    //            DispatchQueue.main.async {
//    //                do {
//    //                    try self.context.save()
//    //                    self.collectionView.deleteItems(at: [indexPath])
//    //                    collectionView.reloadData()
//    //                }
//    //                catch{
//    //                    print("Error \(error.localizedDescription)")
//    //                }
//    //
//    //            }
//    //
//    //        }))
//    //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
//    //            alert.dismiss(animated: true, completion: nil)
//    //        }))
//    //        self.present(alert, animated: true, completion: nil)
//    //    }
//    
//    func deletePhoto(at indexPath: IndexPath) {
//        let photoToDelete = fetchedResultsController.object(at: indexPath)
//        self.context.delete(photoToDelete)
//        try? appDelegate.saveContext()
//    }
//    
//    
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
//        
//        deletePhoto(at: indexPath)
//        collectionView.reloadData()
//        //self.context.delete(self.photoAlbum[indexPath.row])
//        
//        
//        //        let photo = photoAlbum[indexPath.item]
//        //
//        //        if editButtonPressed == true {
//        //            performUpdatesOnMain {
//        //                cell.isUserInteractionEnabled = true
//        //            }
//        //
//        //        } else {
//        //            performUpdatesOnMain {
//        //                cell.isUserInteractionEnabled = false
//        //            }
//        //        }
//        //
//        //        let indexPaths = collectionView.indexPathsForSelectedItems!
//        //
//        //        print("selected index path of cell is \(indexPaths)")
//        //        print("photoAlbum count is \(self.photoAlbum.count)")
//        //
//        //        let alert = UIAlertController(title: nil, message: "Confirm Delete Picture?", preferredStyle: .alert)
//        //        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
//        //            print("photoAlbumIndexPath is \(self.photoAlbum[indexPath.row])")
//        //            self.context.delete(self.photoAlbum[indexPath.row])
//        //            print("photoAlbum photo deleted FRC is also: \(self.fetchedResultsController.fetchedObjects?.count)")
//        //            self.photoAlbum.remove(at: indexPath.row )
//        //            self.appDelegate.saveContext()
//        //
//        //
//        //            self.collectionView.performBatchUpdates({
//        //                let indexPaths = collectionView.indexPathsForSelectedItems!
//        //                //let indexPaths = Array(3...5).map { IndexPath(item: $0, section: 0) }
//        //                self.collectionView.deleteItems(at: indexPaths)
//        //                self.collectionView.insertItems(at: [IndexPath(item: 3, section: 0)])
//        //                print("collVC batch updates called")
//        //            }, completion: nil)
//        //
//        //            print("photoAlbum count is now\(self.photoAlbum.count)")
//        //            //collectionView.reloadData()
//        //
//        //            performUpdatesOnMain {
//        //                do {
//        //                    try self.appDelegate.saveContext()
//        //                    self.collectionView.deleteItems(at: [indexPath])
//        //                    //self.collectionView.reloadData()
//        //                    print("collVC reload called")
//        //
//        //                    print("photoAlbum photo deleted is: \(indexPath)")
//        //                    print("photoAlbum photo deleted is also: \(self.fetchedResultsController.fetchedObjects?.count)")
//        //                    //self.collectionView!.insertItems(at: indexPaths)
//        //                    print("photoAlbum item inserted is: \(self.photoAlbum.count)")
//        //                }
//        //                catch{
//        //                    print("Error \(error.localizedDescription)")
//        //                }
//        //
//        //            }
//        //
//        //        }))
//        //        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
//        //
//        //            alert.dismiss(animated: true, completion: nil)
//        //            //self.collCell.isSelected = true
//        //        }))
//        //        self.present(alert, animated: true, completion: nil)
//        // self.collCell.isSelected = false
//        //configureCell(cell, atIndexPath: indexPath)
//        //self.collectionView.reloadData()
//    }
//}
//
//extension CollectionViewController: UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//}
//
////EXTENSION DELEGATE TO GET CONTROLLER TO EXCECUTE DELETION CODE ON VIEW (CELL)
////extension CollectionViewController: CollectionViewCellDelegate {
////    func delete(cell: CollectionViewCell) {
////        if editButtonItem.title == "Done" {
////            print("edit button works!")
////                        collCell.isSelected = true
////                        collCell.isEditing = true
////
////            if let indexPath = collectionView?.indexPath(for: cell) {
////                //TODO COMMENTED OUT PHOTO ALBUM AS PER VIDEO 8 IN SIMPLIFYING CORE DATA LESSON
////                let item = photoAlbum[indexPath.item]
////                // delete photo from data source?
////                photoAlbum.remove(at: indexPath.item)
////                //TODO: FIX THIS!!!
////                //            let photoToDelete = fetchedResultsController.object(at: indexPath)
////                //                dataController.viewContext.delete(photoToDelete)
////                //                try? dataController.viewContext.save()
////            }
////        } else {
////                        collCell.isSelected = false
////                        collCell.isEditing = false
////        }
////    }
////}
//
//extension CollectionViewController: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = view.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
//        
//        return CGSize(width: widthPerItem, height: widthPerItem)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return sectionInsets.left
//    }
//}
////  EXTENSION TO DOWNLOAD IMAGE DATA FROM IMAGE URL
////extension UIImageView {
////    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
////        contentMode = mode
////        URLSession.shared.dataTask(with: url) { (data, response, error) in
////            guard
////                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
////                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
////                let data = data, error == nil,
////                let image = UIImage(data: data)
////                else { return }
////
////            performUpdatesOnMain {
////                self.image = image
////            }
////
////            }.resume()
////    }
////    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
////        guard let url = URL(string: link) else { return }
////        downloadedFrom(url: url, contentMode: mode)
////    }
////}
//
////extension CollectionViewController: NSFetchedResultsControllerDelegate {
////  //TODO FIX TO MEME
////    func fetchedRCSearch() {
////        if let fetchedRC = fetchedResultsController {
////            do {
////                try fetchedRC.performFetch()
////            } catch let e as NSError {
////               AlertView.alertPopUp(view: self, alertMessage: "error on fetch")
////            }
////        }
////    }
////
//////    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////////        collectionView.beginUpdates()
////////        collectionView.updateUserActivityState()
////////        collectionView.beginInteractiveMovementForItem(at: indexPath)
//////    }
//////
////    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
////        switch type {
////        case .insert:
////            self.collectionView.insertItems(at: [newIndexPath!])
////        case .delete:
////            self.collectionView.deleteItems(at: [newIndexPath!])
////        default:
////            break
////        }
////    }
////}
//
//extension CollectionViewController:NSFetchedResultsControllerDelegate {
//    //Maybe use this? 4/25
//    //        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//    //
//    //            switch type {
//    //
//    //            case .insert: collectionView.insertItems(at: [newIndexPath!])
//    //
//    //            case .delete: collectionView.deleteItems(at: [indexPath!])
//    //
//    //            case .update: collectionView.reloadItems(at: [indexPath!])
//    //
//    //            default:
//    //                return
//    //            }
//    //        }
//    
//    //    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//    //        switch type {
//    //        case .insert:
//    //            collectionView.insertItems(at: [newIndexPath!])
//    //            break
//    //        case .delete:
//    //            collectionView.deleteItems(at: [indexPath!])
//    //            break
//    //        case .update:
//    //            collectionView.reloadItems(at: [indexPath!])
//    //        case .move:
//    //            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
//    //        }
//    //    }
//    //
//    //    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//    //        let indexSet = IndexSet(integer: sectionIndex)
//    //        switch type {
//    //        case .insert: collectionView.insertSections(indexSet)
//    //        case .delete: collectionView.deleteSections(indexSet)
//    //        case .update, .move:
//    //            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
//    //        }
//    //    }
//    //
//    //
//    //    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//    //        collectionView.beginUpdates()
//    //        collectionView.
//    //    }deinit
//    //
//    //    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//    //        collectionView.endUpdates()
//    //    }
//    
//    //https://gist.github.com/nazywamsiepawel/e88790a1af1935ff5791c9fe2ea19675
//    //might need this stuff:
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        
//        if type == NSFetchedResultsChangeType.insert {
//            print("Insert Object: \(newIndexPath)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.insertItems(at: [newIndexPath!])
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.update {
//            print("Update Object: \(indexPath)")
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.reloadItems(at: [indexPath!])
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.move {
//            print("Move Object: \(indexPath)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.delete {
//            print("Delete Object: \(indexPath)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.deleteItems(at: [indexPath!])
//                    }
//                })
//            )
//        }
//    }
//    
//    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        
//        
//        if type == NSFetchedResultsChangeType.insert {
//            print("Insert Section: \(sectionIndex)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.update {
//            print("Update Section: \(sectionIndex)")
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.delete {
//            print("Delete Section: \(sectionIndex)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                    }
//                })
//            )
//        }
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        collectionView!.performBatchUpdates({ () -> Void in
//            for operation: BlockOperation in self.blockOperations {
//                operation.start()
//            }
//        }, completion: { (finished) -> Void in
//            self.blockOperations.removeAll(keepingCapacity: false)
//        })
//    }
//    
//    //    deinit {
//    //        for operation: BlockOperation in blockOperations {
//    //            operation.cancel()
//    //        }
//    //
//    //        blockOperations.removeAll(keepingCapacity: false)
//    //    }
//    
//    
//}
//
//
//
//
//

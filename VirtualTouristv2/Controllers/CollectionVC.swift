//
//  OldCollVC.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 4/29/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController, MKMapViewDelegate {

    fileprivate let itemsPerRow: CGFloat = 3

    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 50.0, right: 20.0)

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var fetchedResultsController: NSFetchedResultsController<Photo>!
    //var fetchedResultsControllerPin: NSFetchedResultsController<Pin>!

    var passedPin: Pin!
    var photosInPin = 0
    var photoAlbum = [Photo]()

    var selectedIndexes = [IndexPath]()
    var deletedIndexPaths: [IndexPath]!
    var insertedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!

    var urlArray = [String]()

    var randomNumberResults: Int?

    private let reuseIdentifier = "CollectionItem"

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityOverlay: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var mapViewColl: MKMapView!

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBOutlet weak var bottomButton: UIButton!
    
    fileprivate func setupFetchedResultsController() {
        print("setupFetchedResultsController has been called")
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let myPredicate = NSPredicate(format: "pin == %@", argumentArray: [self.passedPin])
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = myPredicate
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        
        // Start the fetched results controller
        do {
            try fetchedResultsController.performFetch()

            //let fetchCount = try? context.count(for: fetchRequest)
            
        } catch let error as NSError {
            
            AlertView.alertPopUp(view: self, alertMessage: "CVcould not fetch: \(error.localizedDescription)")
        }
        //let fetchCount = try? context.count(for: fetchRequest)
        
        //TODO: delete this
//        if fetchCount! < 1 {
//            print("fetchCount is: \(fetchCount)")
//            //getFlickrPhotos()
//        }
    }

    fileprivate func getFlickrPhotos() {
        
        activityOverlay.isHidden = false
        activityIndicator.startAnimating()
        bottomButton.isEnabled = false

        randomNumber(start: 1, to: 25)
        
        FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(self.passedPin.latitude)", long: "\(self.passedPin.longitude)", pageNum: self.randomNumberResults!, chosenPin: self.passedPin) { (newPhotoURLs, error) in

            guard let newPhotoURLs = newPhotoURLs else {
                performUpdatesOnMain {
                    self.bottomButton.isEnabled = true
                    AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos")
                }
                return
            }
            
            if newPhotoURLs.count < 1 {
                performUpdatesOnMain {
                    self.bottomButton.isEnabled = true
                    AlertView.alertPopUp(view: self, alertMessage: "No Photos Found (newPhotoURLs.count)")
                }
                
            } else if newPhotoURLs != nil {
                self.urlArray.removeAll()
                self.urlArray = newPhotoURLs

                performUpdatesOnMain {
                    self.bottomButton.isEnabled = true
                    self.activityOverlay.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            } else {
                print(error ?? "error on refreshing photos")
                performUpdatesOnMain {
                    self.bottomButton.isEnabled = true
                    self.activityOverlay.isHidden = true
                    self.activityIndicator.stopAnimating()
                    AlertView.alertPopUp(view: self, alertMessage: "No Photos Found")
                }
            }
            print("passedPin is: \(self.passedPin)")
            
            //Attaches URLs to Pin
            for returnedURLs in newPhotoURLs {
                performUpdatesOnMain {
                    let pin = self.passedPin
                    let photo = Photo(context: self.context)
                    let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.context)
                    let photoModel = Photo(entity: Photo.entity(), insertInto: self.context)
                    var date = Date()
                
                    photoModel.creationDate = date
                    photoModel.photoURL = returnedURLs as! String
                    photoModel.pin = self.passedPin
                    photoModel.photoURL = returnedURLs as! String
                
                    self.photoAlbum.append(photoModel)
                    print("save cause error?")
                    self.appDelegate.saveContext()
                }
            }
        }
    }
    
//    private func storePhotos(_ photos: [Photo], forPin: Pin) {
//        func showErrorMessage(msg: String) {
//            AlertView.alertPopUp(view: self, alertMessage: "No Photos Found")
//        }
//
//        for photo in photos {
//            performUpdatesOnMain {
//                if let url = photo.photoURL {
//
//                    _ = Photo(imageUrl: url, forPin: passedPin, context: self.context)
//                    self.appDelegate.saveContext()
//                }
//            }
//        }
//    }
    
    @IBAction func refreshRemoveButton(_ sender: Any) {
        
        activityOverlay.isHidden = false
        activityIndicator.startAnimating()
        bottomButton.isEnabled = false

        performUpdatesOnMain {

            for photo in self.photoAlbum {
                self.context.delete(photo as! Photo)
            }
            self.photoAlbum.removeAll()
        }
        
        print("is refreshRemove first save call creating error?")
        self.appDelegate.saveContext()

        randomNumber(start: 1, to: 25)

        FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(self.passedPin.latitude)", long: "\(self.passedPin.longitude)", pageNum: self.randomNumberResults!, chosenPin: self.passedPin) { (newPhotoURLs, error) in

            guard let newPhotoURLs = newPhotoURLs else {
                performUpdatesOnMain {
                    self.bottomButton.isEnabled = true
                    self.activityOverlay.isHidden = true
                    self.activityIndicator.stopAnimating()
                    AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos")
                }
                return
            }
            
            if newPhotoURLs.count < 1 {
                
                performUpdatesOnMain {
                    self.bottomButton.isEnabled = true
                    AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos (newPhotoURLs.count)")
                }
            } else if newPhotoURLs != nil {
                self.urlArray.removeAll()
                self.urlArray = newPhotoURLs
                print("photos are in!")
                print("url array is: \(self.urlArray)")

                performUpdatesOnMain {
                    self.urlArray.removeAll()
                    self.urlArray = newPhotoURLs
                    self.bottomButton.isEnabled = true
                }
            } else {
                performUpdatesOnMain {
                    self.bottomButton.isEnabled = true
                    AlertView.alertPopUp(view: self, alertMessage: "No Photos Found")
                }
            }

            for returnedURLs in newPhotoURLs {
                let pin = self.passedPin
                let photo = Photo(context: self.context)
                
                let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.context)
                let photoModel = Photo(entity: Photo.entity(), insertInto: self.context)
                var date = Date()
                photoModel.creationDate = date
                photoModel.photoURL = returnedURLs as! String
                photoModel.pin = self.passedPin
                photoModel.photoURL = returnedURLs as! String

                do{
                    let url = URL(string: photoModel.photoURL!)
                    var imageData = try NSData(contentsOf: url!)
                    photoModel.photoData = imageData
                    if photo.photoData != nil {
                        print("2photo.photoData has data!")
                    }
                }
                catch let error as NSError {
                    AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again.")
                }
                
                self.photoAlbum.append(photoModel)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        
        let fetchedObjects = fetchedResultsController.fetchedObjects
        print(fetchedObjects?.count)
        if fetchedObjects?.count != 0{
           
            for image in fetchedObjects! {
                let fetchedImage = image
                self.photoAlbum.append(fetchedImage)
            }
        }
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

    func removeAllPhotos() {

        for object in fetchedResultsController.fetchedObjects! {
            context.delete(object as! Photo)
        }
        self.photoAlbum = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        randomNumber(start: 1, to: 50)

        setupFetchedResultsController()
        self.photosInPin = self.passedPin.photos!.count
        self.activityOverlay.isHidden = true

        if self.passedPin.photos!.count == 0 && fetchedResultsController.fetchedObjects?.count == 0 {
            self.activityOverlay.isHidden = false
            getFlickrPhotos()
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView?.allowsMultipleSelection = false
      

        mapViewColl.delegate = self
        let passedPinLocation = CLLocation(latitude: self.passedPin.latitude, longitude: self.passedPin.longitude)
        let regionRadius: CLLocationDistance = 1000000
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                      regionRadius, regionRadius)
            mapViewColl.setRegion(coordinateRegion, animated: true)
        }

        centerMapOnLocation(location: passedPinLocation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: self.passedPin.latitude, longitude: self.passedPin.longitude)
        mapViewColl.addAnnotation(annotation)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("the photo album array count in viewWillAppear is: \(photoAlbum.count)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }

}

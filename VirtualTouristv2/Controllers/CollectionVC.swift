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
    var fetchedResultsControllerPin: NSFetchedResultsController<Pin>!

    var passedPin: Pin!
    var photosInPin = 0
    var photoAlbum = [Photo]()

    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
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
       
        //let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let myPredicate = NSPredicate(format: "pin == %@", argumentArray: [self.passedPin])
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = myPredicate
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self as! NSFetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController.performFetch()
            print("CV fetch successful")
            let fetchCount = try? context.count(for: fetchRequest)
            print("data controller on CV VC contains: \(fetchCount) Photo objects")
            
        } catch let error as NSError {
            //fatalError("could not fetch: \(error.localizedDescription)")
            print("error on setup fetch is: \(error.localizedDescription)")
            AlertView.alertPopUp(view: self, alertMessage: "CVcould not fetch: \(error.localizedDescription)")
        }
        let fetchCount = try? context.count(for: fetchRequest)
        print("data controller on CV VC contains: \(fetchCount) Photo objects")
        
        if fetchCount! < 1 {
            print("fetchCount is: \(fetchCount)")
            //getFlickrPhotos()
        }
    }

    fileprivate func getFlickrPhotos() {
        
        performUpdatesOnMain {
            print("getFlickrPhotos CALLED!")
            //self.photoAlbum.removeAll()
            //self.removeAllPhotos()
            //self.context.delete(self.passedPin.photos)
            self.activityOverlay.isHidden = false
            self.activityIndicator.startAnimating()
            self.bottomButton.isEnabled = false
            //self.appDelegate.saveContext()
            //self.collectionView.reloadData()
        }

        randomNumber(start: 1, to: 25)
        
        FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(self.passedPin.latitude)", long: "\(self.passedPin.longitude)", pageNum: self.randomNumberResults!, chosenPin: self.passedPin) { (newPhotoURLs, error) in
            print("FlickrAPIClient.sharedInstance().getFlickrPhotos CALLED!")
            print("page number is \(self.randomNumberResults)")
            print("getFlickrPhotos cvc results are \(newPhotoURLs)")
            
            performUpdatesOnMain {
                //                self.photoAlbum.removeAll()
                //self.collectionView.reloadData()
                self.bottomButton.isEnabled = true
                self.activityOverlay.isHidden = true
                self.activityIndicator.stopAnimating()
                //self.appDelegate.saveContext()
            }
            print("Photo count after loop  and Flickr call is \(self.photoAlbum.count)")
            print("page number is \(self.randomNumberResults)")
            print("getFlickrPhotos cvc results are \(newPhotoURLs)")
            print("returnedPhotoURLs from FlickrGetPhotosCall On long press geusture is\(newPhotoURLs)")
            
            guard let newPhotoURLs = newPhotoURLs else {
                performUpdatesOnMain {
                    //self.context.delete(self.passedPin.photos)
                    self.bottomButton.isEnabled = true
                    AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos")
                }
                return
            }
            
            if newPhotoURLs.count < 1 {
                AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos (newPhotoURLs.count)")
                performUpdatesOnMain {
                    //self.context.delete(self.passedPin.photos)
                    self.bottomButton.isEnabled = true
                }
            } else if newPhotoURLs != nil {
                self.urlArray.removeAll()
                self.urlArray = newPhotoURLs
                print("photos are in!")
                print("url array is: \(self.urlArray)")
                
                performUpdatesOnMain {
//                    self.urlArray.removeAll()
//                    self.urlArray = newPhotoURLs
                    //self.collectionView.reloadData()
                    self.bottomButton.isEnabled = true
                    //self.appDelegate.saveContext()
                }
            } else {
                print(error ?? "error on refreshing photos")
                performUpdatesOnMain {
                    AlertView.alertPopUp(view: self, alertMessage: "No Photos Found")
                }
            }
            print("passedPin is: \(self.passedPin)")
            
            for returnedURLs in newPhotoURLs {
                let pin = self.passedPin
                print("refresh button pin lat  is: \(pin?.latitude)")
                let photo = Photo(context: self.context)
                print("for returnedURLs in passedPinURLs is called - \(pin?.photos)")
                //Fetch Error Before
                print("FIRST LINE BEFORE FETCH problem")
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
                        print("2photo.photoData has data!\(imageData?.bytes)")
                    } else {
                        print("2photo.photoData has NO data!\(imageData?.bytes)")
                    }
                }
                catch let error as NSError {
                    AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again.")
                }
                //Fetch Error After
                print("FIRST LINE AFTER FETCH problem")
                print("self.context is changed?: \(self.context.hasChanges)")
                print("Pin is: \(self.passedPin!)")
                print("returnedPhotoURLs in photo model are\(photoModel.photoURL)")
                print("returnedPhotoData in photo model are\(photoModel.photoData)")
                
                self.photoAlbum.append(photoModel)
                print("photoAlbum/photo model are\(self.photoAlbum)")
                print("photoAlbum count in refresh button is \(self.photoAlbum.count)")
            }
        }
    }

    @IBAction func refreshRemoveButton(_ sender: Any) {

        performUpdatesOnMain {
            print("refresh button has been pressed")
            self.activityOverlay.isHidden = false
            self.activityIndicator.startAnimating()
            self.bottomButton.isEnabled = false
            
            for photo in self.photoAlbum {
                print("photo to be deleted is \(photo)")
                self.context.delete(photo as! Photo)
                print("Passed Pin Photo count in for loop is: \(self.passedPin.photos?.count)")
                print("about to save on refreshRemoveButton")
                //self.appDelegate.saveContext()
            }

            print("Passed Pin Photo count after loop is:  \(self.passedPin.photos?.count)")
            self.photoAlbum.removeAll()
            print("Photo count after loop is \(self.photoAlbum.count)")
            //self.fetchPassedPinAgain()
            //self.appDelegate.saveContext()
            //self.collectionView.reloadData()
            print("coll vc reloaded data")
        }

        print("Passed Pin Photo count is now: \(self.passedPin.photos?.count)")
        print("self.photoAlbum count is now: \(self.photoAlbum.count)")

        randomNumber(start: 1, to: 25)

        /////////
        FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(self.passedPin.latitude)", long: "\(self.passedPin.longitude)", pageNum: self.randomNumberResults!, chosenPin: self.passedPin) { (newPhotoURLs, error) in
            print("refresh button has been pressed")
            

            print("Photo count after loop  and Flickr call is \(self.photoAlbum.count)")
            print("page number is \(self.randomNumberResults)")
            print("getFlickrPhotos cvc results are \(newPhotoURLs)")
            print("returnedPhotoURLs from FlickrGetPhotosCall On long press geusture is\(newPhotoURLs)")

            guard let newPhotoURLs = newPhotoURLs else {
                performUpdatesOnMain {
                    //self.context.delete(self.passedPin.photos)
                    self.bottomButton.isEnabled = true
                    self.activityOverlay.isHidden = true
                    self.activityIndicator.stopAnimating()
                    AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos")
                }
                return
            }
            
            if newPhotoURLs.count < 1 {
                AlertView.alertPopUp(view: self, alertMessage: "Error on downloading photos (newPhotoURLs.count)")
                performUpdatesOnMain {
                    //self.context.delete(self.passedPin.photos)
                    self.activityOverlay.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.bottomButton.isEnabled = true
                }
            } else if newPhotoURLs != nil {
                self.urlArray.removeAll()
                self.urlArray = newPhotoURLs
                print("photos are in!")
                print("url array is: \(self.urlArray)")

                performUpdatesOnMain {
                    self.urlArray.removeAll()
                    self.urlArray = newPhotoURLs
                    //self.collectionView.reloadData()
//                    self.bottomButton.isEnabled = true
//                    self.activityOverlay.isHidden = true
//                    self.activityIndicator.stopAnimating()
                    //self.appDelegate.saveContext()
                }
            } else {
                print(error ?? "error on refreshing photos")
                performUpdatesOnMain {
                    AlertView.alertPopUp(view: self, alertMessage: "No Photos Found")
                }
            }
            print("passedPin is: \(self.passedPin)")
            for returnedURLs in newPhotoURLs {
                let pin = self.passedPin
                print("refresh button pin lat  is: \(pin?.latitude)")
                let photo = Photo(context: self.context)
                print("for returnedURLs in passedPinURLs is called - \(pin?.photos)")
                
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
                print("self.context is changed?: \(self.context.hasChanges)")
                print("Pin is: \(self.passedPin!)")
                print("returnedPhotoURLs in photo model are\(photoModel.photoURL)")
                print("returnedPhotoData in photo model are\(photoModel.photoData)")

                self.photoAlbum.append(photoModel)
                print("photoAlbum/photo model are\(self.photoAlbum)")
                print("photoAlbum count in refresh button is \(self.photoAlbum.count)")
            }
        }
        
        let fetchedObjects = fetchedResultsController.fetchedObjects
        print(fetchedObjects?.count)
        if fetchedObjects?.count != 0{
            print("Count of images on refresh \(fetchedObjects?.count)")
            
            for image in fetchedObjects! {
                let fetchedImage = image
                self.photoAlbum.append(fetchedImage)
                print("photoAlbum count ion refresh is: \(self.photoAlbum.count)")
            }
            
//            performUpdatesOnMain {
//                //                self.photoAlbum.removeAll()
//                //self.collectionView.reloadData()
//                self.bottomButton.isEnabled = true
//                self.activityOverlay.isHidden = true
//                self.activityIndicator.stopAnimating()
//                //self.appDelegate.saveContext()
//            }
        }
    }

    func randomNumber(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        if a > b {
            swap(&a, &b)
        }
        self.randomNumberResults = Int(arc4random_uniform(UInt32(b - a + 1))) + a
        print("page number again is \(randomNumberResults)")
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }

    func removeAllPhotos() {

        for object in fetchedResultsController.fetchedObjects! {
            print("Photo to be deleted in removeAllPhotos is: \(object.objectID) && \(object.photoURL)")
            context.delete(object as! Photo)
            print("removeAllPhotos delete method has been called on: \(object.objectID) && \(object.photoURL)")
            print("Passed Pin Photo count \(self.passedPin.photos?.count)")
        }
        self.photoAlbum = []
        print("PhotoAlbum Photo count is \(self.photoAlbum.count)")
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()
        print("photoAlbum count in viewDidLoad is: \(self.photoAlbum.count)")        
        randomNumber(start: 1, to: 50)
        
//        performUpdatesOnMain {
//            self.activityOverlay.isHidden = true
//            self.activityIndicator.stopAnimating()
//            self.bottomButton.isEnabled = true
//        }
        
        setupFetchedResultsController()
        print("passedPin is: \(passedPin)")
        self.photosInPin = self.passedPin.photos!.count

        if self.passedPin.photos!.count == 0 {
            print("number of photosInPin are: \(self.photosInPin)")
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

    func setupCell(_ cell: CollectionViewCell, atIndexPath indexPath: IndexPath) {
        print("in setupCell")
        performUpdatesOnMain {
            cell.activityIndicator.startAnimating()
            cell.overlayView.isHidden = false
        }

        
//        let photos = [fetchedResultsController.fetchedObjects]
//        print("photos here is the fetchedObjects \(photos.count)")

        let photo = self.fetchedResultsController.object(at: indexPath)
        if let photoImageData = photo.photoData {
            print("Getting photo data from CoreData: \(photo.photoURL)")

            let image = UIImage(data: photoImageData as Data)

            do{
                let url = URL(string: photo.photoURL!)
                let imageData = try Data(contentsOf: url!)
                let image = imageData
            }
            catch let error as NSError {
                print("error on configure cell\(error.localizedDescription)")
            }
            cell.cellImage.image = image
            performUpdatesOnMain {
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.isHidden = true
                cell.overlayView.isHidden = true
                
                self.bottomButton.isEnabled = true
                self.activityOverlay.isHidden = true
                self.activityIndicator.stopAnimating()
            }
            
        } else {
            //cell.cellImage.image = #imageLiteral(resourceName: "VirtualTourist_76")
            cell.cellImage.image = nil
            cell.cellImage.backgroundColor = UIColor.white
//            performUpdatesOnMain {
//                cell.activityIndicator.stopAnimating()
//                cell.activityIndicator.isHidden = true
//                cell.overlayView.isHidden = true
//            }

            print("API to get ImageData should start! for \(photo.photoURL)")
            let photoURL = photo.photoURL
            print("getImageData API call should be triggered")

            FlickrAPIClient.sharedInstance().getDataForPhoto(photo, photo.photoURL!, completionHandlerForGetImageData: { (imageData, error) in

                if let error = error {
                    print("ImageData cannot be retrieved from Flickr server")
                    AlertView.alertPopUp(view: self, alertMessage: "Unable to load images in config cell.")
                } else {
                    if let photoImageData = imageData {
                        performUpdatesOnMain {
                            photo.photoData = photoImageData
                            let image = UIImage(data: photoImageData as Data)
                            cell.activityIndicator.stopAnimating()
                            cell.activityIndicator.isHidden = true
                            cell.overlayView.isHidden = true
                            cell.cellImage.image = image
                            print("displaying photo \(photo.photoURL) onto the screen")
                        }

                    } else {
                        performUpdatesOnMain {
                            cell.activityIndicator.isHidden = false
                            cell.activityIndicator.startAnimating()
                            cell.overlayView.isHidden = true
                            cell.cellImage.image = #imageLiteral(resourceName: "VirtualTourist_76")
                        }
                    }
                }
            })
        }
    }
}

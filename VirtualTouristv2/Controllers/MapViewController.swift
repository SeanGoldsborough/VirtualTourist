//
//  MapViewController.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 4/2/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
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
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var deleteLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tapPinsToDeleteLabel2: UIButton!
    
    @IBOutlet weak var tapPinsToDeleteLabel: UILabel!
    
    //LONG PRESS ON SCREEN TO ADD A NEW MAP PIN/ANNOTATION
    @IBAction func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        
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
            //self.twoColorHorizontal()
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
            }
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            AlertView.alertPopUp(view: self, alertMessage: "could not fetch: \(error.localizedDescription)")
        }
        let fetchCount = try? context.count(for: fetchRequest)
        performUpdatesOnMain {
            self.activityView.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        view.addGestureRecognizer(tap)
        tap.numberOfTapsRequired = 1
        tapPinsToDeleteLabel.isHidden = true

        self.overlayView.isHidden = false
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
                } catch let error as NSError {
                    AlertView.alertPopUp(view: self, alertMessage: "ERROR ON FETCH REQUEST - VIEW WILL APPEAR")
                }

    }
    
  
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
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
        
        if tapPinsToDeleteLabel.isHidden == true {

            let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
            photoAlbumVC.passedPin = pin
            photoAlbumVC.context = self.context
            photoAlbumVC.photoAlbum = self.arrayOfPhotos
            
                for selectedPin in self.arrayOfPins{
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let pred = NSPredicate(format: "pin = %@" , argumentArray: [pin as Any])
                    fetchRequest.predicate = pred
                    
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
                self.appDelegate.saveContext()
            }
    }
}

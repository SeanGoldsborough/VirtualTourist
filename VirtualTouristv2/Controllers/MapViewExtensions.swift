//
//  MapViewExtensions.swift
//  VirtualTouristV1
//
//  Created by Sean Goldsborough on 3/13/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

extension MapViewController {
    
    // MARK: Show/Hide Label
    
    func labelWillShow(_ notification: Notification) {
        if !labelOnScreen {
            view.frame.origin.y -= labelHeight(notification)
        }
    }
    
    func labelWillHide(_ notification: Notification) {
        if labelOnScreen {
            view.frame.origin.y += labelHeight(notification)
        }
    }
    
    func labelDidShow(_ notification: Notification) {
        labelOnScreen = true
    }
    
    func labelDidHide(_ notification: Notification) {
        labelOnScreen = false
    }
    
    func labelHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        
        //TODO: CHANGE THIS TO PERTAIN TO TAP TO DELETE BUTTON/LABEL
        let labelSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return  tapPinsToDeleteLabel.frame.height
        //return keyboardSize.cgRectValue.height
    }
    
    func resignIfFirstResponder(_ mapView: MKMapView) {
        if mapView.isFirstResponder {
            mapView.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(mapView)
    }
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func twoColorHorizontal() {
        let backgroundGradient = CAGradientLayer()
        
        let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
}




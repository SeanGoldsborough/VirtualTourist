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
        
        //TODO: CHANGE THIS TO PERTAIN TO TAP TO DELETE LABEL
        let labelSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return  tapPinsToDeleteLabel.frame.height
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
}




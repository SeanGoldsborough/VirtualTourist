//  GCD.swift
//  VirtualTouristV1
//
//  Created by Sean Goldsborough on 11/26/17.
//  Copyright © 2017 Sean Goldsborough. All rights reserved.
//

import Foundation

func performUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

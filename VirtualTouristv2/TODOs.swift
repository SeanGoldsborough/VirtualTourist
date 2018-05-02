//
//  TODOs.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 4/3/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//

import Foundation
//
//Pin and Photo objects are being saved but the Photo objects have no associated Pin somehow
//
//Need to create and use a function that converts the URL strings into Data and saves this data to the photos of each Pin under Photo.photoData
//
//KEEP GETTING THIS:
//map pin debug: <VirtualTouristv2.Pin: 0x60800049e1e0> (entity: Pin; id: 0xd000000000980000 <x-coredata://238A239E-E698-409B-80CA-FFFC773E1391/Pin/p38> ; data: {
//creationDate = "2018-04-04 01:16:07 +0000";
//latitude = "22.9847783590094";
//longitude = "-102.5975888107984";
//photos =     (
//"0x604000237520 <x-coredata:///Photo/t1501A281-37E5-44EF-A6F5-91CBA27615004>"
//);
//})
//ERROR ON APP DELEGATE SAVE CONTEXT METHOD ["NSDetailedErrors": <__NSArrayM 0x60c000644d40>(
//Error Domain=NSCocoaErrorDomain Code=1570 "The operation couldn’t be completed. (Cocoa error 1570.)" UserInfo={NSValidationErrorObject=<VirtualTouristv2.Photo: 0x600000692980> (entity: Photo; id: 0x600000623660 <x-coredata:///Photo/t1501A281-37E5-44EF-A6F5-91CBA27615006> ; data: {
//creationDate = "2018-04-04 01:16:08 +0000";
//photoData = nil;
//photoURL = "https://farm9.staticflickr.com/8598/30391705145_eb93648282.jpg";
//pin = nil;
//}), NSValidationErrorKey=pin, NSLocalizedDescription=The operation couldn’t be completed. (Cocoa error 1570.)},
//Error Domain=NSCocoaErrorDomain Code=1570 "The operation couldn’t be completed. (Cocoa error 1570.)"


//
//  AG_MKAnnotation.swift
//  Lesson_37_MKMapView_Part1
//
//  Created by Admin on 28.10.2020.
//  Copyright © 2020 AlexGermek. All rights reserved.
//

import UIKit
import MapKit

class AG_MKAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init()
    var title: String?
    var subtitle: String?

}

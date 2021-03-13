//
//  UIViewExtension.swift
//  Lesson_37_MKMapView_Part1
//
//  Created by Admin on 03.11.2020.
//  Copyright © 2020 AlexGermek. All rights reserved.
//

import UIKit
import MapKit

extension UIView{
    func superAnnotationView() -> MKAnnotationView?{
        
        if self.isKind(of: MKAnnotationView.self){
            return self as? MKAnnotationView
        }
        
        if self.superview == nil{
            return nil
        }
        
        return self.superview?.superAnnotationView()
    }
}

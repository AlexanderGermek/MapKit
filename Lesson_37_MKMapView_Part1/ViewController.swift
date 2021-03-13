//
//  ViewController.swift
//  Lesson_37_MKMapView_Part1
//
//  Created by Admin on 28.10.2020.
//  Copyright © 2020 AlexGermek. All rights reserved.
//

import UIKit
import MapKit


//расширение для запуска карты
extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            print("location:: (location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }

}


class ViewController: UIViewController, MKMapViewDelegate {
    
    var directions = MKDirections.init(request: MKDirections.Request())
    let geoCoder = CLGeocoder.init()
    let locationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init()
    var currentTitle = 0
    
    @IBOutlet weak var myMapView: MKMapView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        //Для отображения геопозиции Юзера:
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

//        myMapView.showsUserLocation = true
        
        let buttonAdd = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action:  #selector(actionAdd(sender:)))
        let buttonSearch = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action:  #selector(actionSearch(sender:)))
        self.navigationItem.rightBarButtonItems = [buttonSearch, buttonAdd]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Map Style", style: .plain, target: self, action: #selector(changeMapStyle))
        
    }
    
    deinit {
        if self.geoCoder.isGeocoding{
            self.geoCoder.cancelGeocode()
        }
        
        if self.directions.isCalculating{
            self.directions.cancel()
        }
    }

    //MARK: Funstions ----------------------------------------------------------------------------------------------------------------
    @objc func changeMapStyle() {
        
        let ac = UIAlertController(title: "Choose map style", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "hybrid", style: .default, handler: setMapStyle))
        ac.addAction(UIAlertAction(title: "hybridFlyover", style: .default, handler: setMapStyle))
        ac.addAction(UIAlertAction(title: "mutedStandard", style: .default, handler: setMapStyle))
        ac.addAction(UIAlertAction(title: "satellite", style: .default, handler: setMapStyle))
        ac.addAction(UIAlertAction(title: "satelliteFlyover", style: .default, handler: setMapStyle))
        ac.addAction(UIAlertAction(title: "standard", style: .default, handler: setMapStyle))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    func setMapStyle(_ action: UIAlertAction) {
        
        guard let mapStyleName = action.title else { return }
        
        switch  mapStyleName {
        case "hybrid":
            myMapView.mapType = .hybrid
        case "hybridFlyover":
            myMapView.mapType = .hybridFlyover
        case "mutedStandard":
            myMapView.mapType = .mutedStandard
        case "satellite":
            myMapView.mapType = .satellite
        case "satelliteFlyover":
            myMapView.mapType = .satelliteFlyover
        default:
            myMapView.mapType = .standard
        }
    }

    //MARK: Actions ------------------------------------------------------------------------------------------------------------------
    @objc func actionAdd(sender: UIBarButtonItem) {
        
        let annotation: AG_MKAnnotation = AG_MKAnnotation.init()
        annotation.title = "test title \(currentTitle)"
        annotation.subtitle = "test subtitle \(currentTitle)"
        annotation.coordinate = self.myMapView.region.center
        
        currentTitle += 1
        self.myMapView.addAnnotation(annotation)
    }
    
    @objc func actionSearch(sender: UIBarButtonItem){
        
        let user = self.myMapView.annotations[0]
        var zoomRect = MKMapRect.init(origin: MKMapPoint.init(user.coordinate), size: MKMapSize.init(width: 0, height: 0))
        
        for annotation in self.myMapView.annotations{
            let location = annotation.coordinate //сферические - долгота широта
            let center = MKMapPoint.init(location) // декартовы - x y
            let delta = Double(20000)
            let rect = MKMapRect.init(x: center.x - delta, y: center.y - delta, width: 2 * delta, height: 2 * delta)
            zoomRect = rect.union(zoomRect)
        }
        
        zoomRect = self.myMapView.mapRectThatFits(zoomRect)
        self.myMapView.setVisibleMapRect(zoomRect,
                                         edgePadding: UIEdgeInsets.init(top: 100, left: 100, bottom: 100, right: 100),
                                         animated: true)
        
    }
    
    //MARK: MKMapViewDelegate ---------------------------------------------------------------------------------------------------------
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self){
            return nil
        }
        
        let identifier = "Annotation"
        var pin = self.myMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: identifier)
            pin?.pinTintColor = .black
            pin?.animatesDrop = true
            pin?.canShowCallout = true
            pin?.isDraggable = true
            
            let descriptionBtn = UIButton.init(type: .detailDisclosure)
            descriptionBtn.addTarget(self, action: #selector(actionDescription(sender:)), for: .touchUpInside)
            pin?.rightCalloutAccessoryView = descriptionBtn
            
            let directionBtn = UIButton.init(type: .contactAdd)
            directionBtn.addTarget(self, action: #selector(actionDirection(sender:)), for: .touchUpInside)
            pin?.leftCalloutAccessoryView = directionBtn

        }else{
            pin?.annotation = annotation
        }
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        if newState == .ending{
            let location = view.annotation?.coordinate
            let point = MKMapPoint.init(location!)
            
            print("location = \(String(describing: location)), point = \(point) ")
        }
    }
    
    //Отрисовка каждой дорожки:
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    //MARK: ActionsForMap -------------------------------------------------------------------------------------------------------------
    //Отображение адреса по нажатию на детали Пина
    @objc func actionDescription(sender: UIButton) {
        
        let annotationView = sender.superAnnotationView()
        
        if annotationView != nil{
            let coordinate = annotationView?.annotation?.coordinate
            let location = CLLocation.init(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
            
            if self.geoCoder.isGeocoding{
                self.geoCoder.cancelGeocode()
            }
            
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: {
                [unowned self]  placemarks, error in
                
                var message = ""
                
                if error != nil{
                    message = error!.localizedDescription
                }else{
                    if placemarks != nil{
                        message = placemarks![0].description
                    }else{
                        message = "No placemarks Found"
                    }
                }
                
                self.showAlertWith(message: message, andTitle: "Description")
            })
            
        }
    }
    
    //Alert:
    func showAlertWith(message: String, andTitle title: String){
        
        let alertController = UIAlertController(
            title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Прорисовка маршрута от точки к точке
    @objc func actionDirection(sender: UIButton) {
        
        let annotationView = sender.superAnnotationView()
        
        if annotationView != nil{
            
            if self.directions.isCalculating{
                self.directions.cancel()
            }
            
            let coordinate = annotationView?.annotation?.coordinate
            let request    = MKDirections.Request()
            request.requestsAlternateRoutes = true
            request.transportType = .automobile
            
            request.source = MKMapItem.forCurrentLocation()
            
            let placemark   = MKPlacemark(coordinate: coordinate!)
            let destination = MKMapItem(placemark: placemark)
            request.destination = destination
            
            self.directions = MKDirections(request: request)
            directions.calculate { [unowned self] response, error in
                    guard let unwrappedResponse = response else { return }
                
                if error != nil{
                    self.showAlertWith(message: error!.localizedDescription, andTitle: "Error")
                } else if unwrappedResponse.routes.count == 0 {
                    self.showAlertWith(message: error!.localizedDescription, andTitle: "Error")
                } else {
                    self.myMapView.removeOverlays(self.myMapView.overlays)
                    var array = [MKPolyline]()
                    for route in unwrappedResponse.routes {
                        array.append(route.polyline)
                    }
                    
                    self.myMapView.addOverlays(array, level: MKOverlayLevel.aboveRoads)
                }
            }

        }
    }
    
}


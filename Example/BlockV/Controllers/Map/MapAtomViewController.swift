//
//  MapAtomViewController.swift
//  BlockV_Example
//
//  Created by Jonathan Harris on 1/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import CoreLocation
import BLOCKv
import MapKit
import SDWebImage

class VatomPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: URL?
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
        
        super.init()
    }
    
    func setImage(imageUrl: URL){
        self.image = imageUrl
    }
    
    //Not using here
    var region: MKCoordinateRegion {
        let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        return MKCoordinateRegion.init(center: coordinate, span: span)
    }
}

class CustomPinAnnotation: MKPinAnnotationView {
    var customPinImage: String?
}

class MapAtomViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var annotations: [MKAnnotation] = []
    
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        if BLOCKv.isLoggedIn {
            self.performSegue(withIdentifier: "showProfileSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "showLoginSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() == true {

            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied ||
                CLLocationManager.authorizationStatus() == .notDetermined {

                locationManager.requestWhenInUseAuthorization()
            }

            locationManager.desiredAccuracy = 1
            locationManager.delegate = self
            locationManager.startUpdatingLocation()

        } else {
            print("Please turn on location services")
        }
    }
    
    func discoverVatoms(){
        print("---Bottom Left---")
        print(self.mapView.bottomLeftCoordinate().latitude)
        print(self.mapView.bottomLeftCoordinate().longitude)
        print("---Top Right---")
        print(self.mapView.topRightCoordinate().latitude)
        print(self.mapView.topRightCoordinate().longitude)
        
        // For test purpose, bottom left and top right pin
//        let pin = VatomPin(pinTitle:"Bottom Left", pinSubTitle:"xyz", location:CLLocationCoordinate2D.init(latitude: self.mapView.bottomLeftCoordinate().latitude, longitude: self.mapView.bottomLeftCoordinate().longitude))
//        self.annotations.append(pin)
//        self.mapView.addAnnotation(pin)
//
//        let pin2 = VatomPin(pinTitle:"Top Right", pinSubTitle:"xyz", location:CLLocationCoordinate2D.init(latitude: self.mapView.topRightCoordinate().latitude, longitude: self.mapView.topRightCoordinate().longitude))
//        self.annotations.append(pin2)
//        self.mapView.addAnnotation(pin2)
        
        BLOCKv.geoDiscover(bottomLeftLat: self.mapView.bottomLeftCoordinate().latitude,
                           bottomLeftLon: self.mapView.bottomLeftCoordinate().longitude,
                           topRightLat: self.mapView.topRightCoordinate().latitude,
                           topRightLon: self.mapView.topRightCoordinate().longitude,
                           filter: .vatoms) { (vatomModels, error) in

                            // ensure no error
                            guard error == nil else {
                                print(error?.localizedDescription)
                                return
                            }

                            // handle success
                            for model in vatomModels {
                                print("------")
                                print(model.props.title)
                                print(model.props.resources[0].url)
                                print(model.props.geoPosition.coordinates[1])
                                print(model.props.geoPosition.coordinates[0])
                                print("------")
                                let pin = VatomPin(pinTitle:model.props.title, pinSubTitle:model.props.description, location:CLLocationCoordinate2D.init(latitude: model.props.geoPosition.coordinates[1], longitude: model.props.geoPosition.coordinates[0]))
                                
                                guard let activatedImageURL = model.props.resources.first(where: { $0.name == "ActivatedImage"} )?.url else {
                                    continue
                                }
                                
                                guard let encodedURL = try? BLOCKv.encodeURL(activatedImageURL) else {
                                    continue
                                }
                                
                                print(encodedURL)
                                
                                pin.setImage(imageUrl: encodedURL)
                                self.annotations.append(pin)
                            }
                            
                            self.mapView.addAnnotations(self.annotations)
        }
        
        
    }
    
    //MARK - CLLocation Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.delegate = self
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Unable to access your current location")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is VatomPin) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        guard let vatomPin = annotation as? VatomPin else {
            return annotationView
        }
        if let image = vatomPin.image {
            SDWebImageDownloader.shared().downloadImage(with: image, options: SDWebImageDownloaderOptions.init(rawValue: 0), progress: nil, completed: { (image, data, error, finished) in
                annotationView?.image = image?.resize(targetSize: CGSize.init(width:
                    40.0, height: 40.0))
            })
        }else{
            let pinImage = UIImage(named: "annotation")
            annotationView?.image = pinImage
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotation title == \(String(describing: view.annotation?.title!))" )
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        self.annotations.removeAll()
        self.discoverVatoms()
    }
}

extension MKMapView {
    func topLeftCoordinate() -> CLLocationCoordinate2D {
        return self.convert(.zero, toCoordinateFrom: self)
    }
    
    func topRightCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint.init(x: self.frame.width, y: 0), toCoordinateFrom: self)
    }
    
    func bottomLeftCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint.init(x: 0, y: self.frame.height), toCoordinateFrom: self)
    }
    
    func bottomRightCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint.init(x: self.frame.width, y: self.frame.height), toCoordinateFrom: self)
    }
}


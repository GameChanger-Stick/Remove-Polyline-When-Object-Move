//
//  ViewController.swift
//  Remove Polyline When Object Move
//  Created by Sandip Gill on 10/15/20.
//  Copyright © 2020 apptunix. All rights reserved.


import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

class ViewController: UIViewController,CLLocationManagerDelegate {
    var mohaliLatLNG = (30.7046,76.7179)
    var endLocation = (30.3610,76.8485)
   var testPoint1 = CLLocationCoordinate2D(latitude: 30.69834, longitude: 76.72325000000001)
   var testPoint2 = CLLocationCoordinate2D(latitude: 30.69057, longitude: 76.71213)
     var testPoint3 = CLLocationCoordinate2D(latitude: 30.676720000000003, longitude: 76.70360000000001)

     


    var closeCordinate = CLLocationCoordinate2D(latitude: 30.472580000000004, longitude: 76.72682) //Mohali
 var amabala = CLLocationCoordinate2D(latitude: 30.6425, longitude: 76.8173) //Zirkpur
    var locationManager = CLLocationManager()
    @IBOutlet var mapView: GMSMapView!
    var newPath = GMSMutablePath()
    var newPolyLine = GMSPolyline()
    var currentPolyLine = GMSPolyline()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
         self.locationManager.startUpdatingLocation()
        self.showPathWithGMSPath(path: self.newPath, newCoordinates: CLLocationCoordinate2D(latitude: mohaliLatLNG.0, longitude: mohaliLatLNG.1) )
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
             self.showPathWithGMSPath(path: self.newPath, newCoordinates: self.testPoint3)
                             }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showPathWithGMSPath(path: self.newPath, newCoordinates: self.testPoint1)
                                    }
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    self.showPathWithGMSPath(path: self.newPath, newCoordinates: self.testPoint2) 
                                    }
    }
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D,completion:@escaping (Bool,String,Int,String,String,Int,[Any])->()){
        //print(source)
        getData(url: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(googleKey)", parameter: nil, header: nil, isLoader: true, msg: "") { (response,status)  in
            if let responseDict = response as? [String:Any]{
                if let routes = responseDict["routes"] as? [Any], let overPolyline = routes.first as? [String:Any],let dictPolyline = overPolyline["overview_polyline"] as? [String:Any],let points = dictPolyline["points"] as? String,let legsArr = overPolyline["legs"] as? [Any],let legfirstDict = legsArr.first as? [String:Any],let duration = legfirstDict["duration"]as?[String:Any],let time = duration["value"]as?Int,let timeValue = duration["text"]as?String,
                    let distanceDict = legfirstDict["distance"]as?[String:Any],let distance = distanceDict["text"]as?String,let distanceValue = distanceDict["value"]as?Int {
                    var arr = [[String : Any]]()
                    if let arrSteps = legfirstDict["steps"] as? [[String : Any]] {
                        arrSteps.forEach({ (dict) in
                            let dict = dict["start_location"] as? [String : Any]
                            arr.append(dict ?? [:])
                        })
                    }
                    completion(true,points,time,timeValue,distance,distanceValue,arr)
                }
                else{
                    completion(false,"",0,"","",0,[])
                }
            }
            else{
                completion(false,"",0,"","",0,[])
            }
        }
    }
    
    func getData(url:String,parameter:[String:String]?,header:[String:String]?,isLoader:Bool,msg:String, completion:@escaping (NSDictionary?,Int)->()){
    //    print(url)
        if(isLoader){
        }
        AF.request(url, method: .get, parameters: parameter, encoding: JSONEncoding.default, headers: nil).responseJSON{
                response in
                switch(response.result){
                case .success(let value):
                //    print(value)
                    if let data = value as? NSDictionary{
                     //   print(data)
                        completion(data,response.response?.statusCode ?? 0)
                    }
                    else{
                        completion(nil,response.response?.statusCode ?? 0)
                    }
                    break
                case .failure(let error):
                 //   print(error.localizedDescription)
                    completion(nil,0)
                    break
                }
        }
    }
    func drawPath(sourceLocation:CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D){
       //     print(sourceLocation)
         //   print(destinationLocation)
            let destinationMarker = GMSMarker()
            destinationMarker.position = destinationLocation
            destinationMarker.icon = UIImage(named: "destination")
            destinationMarker.map = mapView
            let sourceMarker = GMSMarker()
            sourceMarker.position = sourceLocation
            sourceMarker.icon = UIImage(named: "currentLoc")
            sourceMarker.map = mapView
            self.getPolylineRoute(from: sourceLocation, to: destinationLocation) { (status, polyline,time,timeValue,distance,distanceValue,pointsArr) in
                if(status){
                    self.showPath(polyStr: polyline)
                }
            }
        }
  
    
    
}

extension ViewController : GMSMapViewDelegate{
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //  let camera = GMSCameraPosition.camera(withLatitude: mohaliLatLNG.0, longitude: mohaliLatLNG.1, zoom: 17.0)
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        self.mapView?.animate(to: camera)
        drawPath(sourceLocation:location!.coordinate, destinationLocation: CLLocationCoordinate2D(latitude: endLocation.0, longitude: endLocation.1))
    }
}

extension CLLocationCoordinate2D {

    /// Compare two coordinates
    /// - parameter coordinate: another coordinate to compare
    /// - return: bool value
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {

        if self.latitude != coordinate.latitude &&
            self.longitude != coordinate.longitude {
            return false
        }
        return true
    }
}

extension ViewController{
    //MARK- NEW FUNCTIONS
    func showPath(polyStr :String){ //FROM API
               guard let path = GMSMutablePath(fromEncodedPath: polyStr) else {return }
      self.newPolyLine.map = nil
        self.newPolyLine.map = nil
             self.mapView.clear()
      
        for i in 0..<path.count(){
            self.newPath.add(path.coordinate(at: i))
            print("LAST CORDINATE:",path.coordinate(at: i))
        }
            let polyLine = GMSPolyline(path: path)
                polyLine.strokeWidth = 3.0
        polyLine.strokeColor = .red
                polyLine.map = self.mapView
               var bounds = GMSCoordinateBounds()
               for index in 1...path.count() {
                   bounds = bounds.includingCoordinate(path.coordinate(at: UInt(index)))
               }
    self.currentPolyLine =  polyLine
             //  isPathCreated = true
            self.mapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50))
        }
    
    //Show Path Again
    func showPathWithGMSPath(path:GMSMutablePath?,newCoordinates:CLLocationCoordinate2D){ //FROM SAVED PATH
        if path?.count() == 0{
            //Add Path From API
              self.drawPath(sourceLocation: CLLocationCoordinate2D(latitude: mohaliLatLNG.0, longitude: mohaliLatLNG.1), destinationLocation:  CLLocationCoordinate2D(latitude: endLocation.0, longitude: endLocation.1))
            return
        }
        if  let newC = self.getClosestLatLng(path: path!, coordinateCheck: newCoordinates){
        self.closeCordinate = newC
        let Xpth = GMSMutablePath()
            for i in 0..<path!.count(){
                if path!.coordinate(at: i).isEqual(to:  self.closeCordinate){
                Xpth.removeAllCoordinates()
             }else{
                Xpth.add(path!.coordinate(at: i))
            }
         }
            self.newPath = Xpth
        self.PolyLineAgain(Ypath: Xpth)
        }
    }
    //CHECK WHICH COORDINATE IS CLOSE P1
    func getClosestLatLng(path:GMSMutablePath,coordinateCheck:CLLocationCoordinate2D)-> CLLocationCoordinate2D?{
           var clLot = [CLLocation]()
             for i in 0..<path.count(){
               let location2d = path.coordinate(at: i)
               let cllocation = CLLocation(latitude: location2d.latitude, longitude: location2d.longitude)
               clLot.append(cllocation)
           }
         let closestCord =   self.locationInLocations(locations: clLot, closestToLocation: CLLocation(latitude: coordinateCheck.latitude, longitude: coordinateCheck.longitude))
          return closestCord?.coordinate ?? nil
       }
    
      //CHECK WHICH COORDINATE IS CLOSE P2
    func locationInLocations(locations: [CLLocation], closestToLocation locationCurrent: CLLocation) -> CLLocation? {
       if locations.count == 0 {
         return nil
       }
       var smallestDistance: CLLocationDistance?
        var closestLocation: CLLocation?
       for location in locations {
         let distance = location.distance(from: locationCurrent)
         if smallestDistance == nil || distance < smallestDistance! {
           closestLocation = location
           smallestDistance = distance
         }
       }
         if smallestDistance! > Double(30){
             //CREATE NEW PATH  //DRIVER TAKE ANOTHER ROUTE
                 self.drawPath(sourceLocation: amabala, destinationLocation:  CLLocationCoordinate2D(latitude: endLocation.0, longitude: endLocation.1))
             return nil
         }else{
             return closestLocation
         }
         print("closestLocation: \(closestLocation), distance: \(smallestDistance)")
     }
    //ADD POLYLINE AGAIN TO MAP
    func PolyLineAgain(Ypath:GMSMutablePath){
        mapView.clear()
       
                                              self.newPolyLine.map = nil
                                                                     let polyLine = GMSPolyline(path: Ypath)
                                                                            polyLine.strokeWidth = 3.0
                                              polyLine.strokeColor = .red
                                                                           polyLine.map = self.mapView
                                                                           var bounds = GMSCoordinateBounds()
                                                                           for index in 1...Ypath.count() {
                                                                               bounds = bounds.includingCoordinate(Ypath.coordinate(at: UInt(index)))
                                                                           }
                                          polyLine.map = self.mapView
        //self.currentPolyLine = polyLine
          DispatchQueue.main.asyncAfter(deadline: .now()) {
               self.currentPolyLine.map = nil
          }
      }
}

//
//  ViewController.swift
//  Mapkit
//
//  Created by secret on 15/12/28.
//  Copyright © 2015年 secret. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

let screenHeight = UIScreen.mainScreen().bounds.size.height
let screenWidth = UIScreen.mainScreen().bounds.size.width

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    var locationMananger:CLLocationManager!
    var mapBgView:MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        mapBgView = MKMapView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        mapBgView.mapType = MKMapType.Standard
        mapBgView.scrollEnabled = true
        mapBgView.zoomEnabled = true
        mapBgView.delegate = self
        self.view.addSubview(mapBgView)
        
        
        //初始化定位管理类
        locationMananger = CLLocationManager()
        //设置定位精确度
        locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        //重新定位的最小变化距离
        locationMananger.distanceFilter = 50
        if (UIDevice.currentDevice().systemVersion >= "8.0.0"){
            //8.0之后
//            locationMananger.requestWhenInUseAuthorization()
            locationMananger.requestAlwaysAuthorization()
        }
        locationMananger.delegate = self
        
        //判断是否支持定位
        if CLLocationManager.locationServicesEnabled(){
            //开启定位
            locationMananger.startUpdatingLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            //取得最新一次的定位信息
            let locationInfo:CLLocation = locations.last! as CLLocation
            //声明一个编码变量
            let geo:CLGeocoder = CLGeocoder()
//            //传入一个地理位置的字符串，通过该地理位置编码出经纬度信息
//            geo.geocodeAddressString("后街", completionHandler: { (arr:[CLPlacemark]?, error:NSError?) -> Void in
//                
//            })
//            //精确的区域
//            geo.geocodeAddressString("后街", inRegion: CLRegion(), completionHandler: { (arr:[CLPlacemark]?, error:NSError?) -> Void in
//                
//            })
            
            //根据给定的经纬度地址反向解析得到字符串地址
            geo.reverseGeocodeLocation(locationInfo, completionHandler: { (arr:[CLPlacemark]?, error:NSError?) -> Void in
                if arr?.count > 0 {
                    //arr中包含多个地址
                    //CLPlacemark 包含所有的位置信息
                    let place:CLPlacemark = (arr?.last)! as CLPlacemark
                    print("国家：\(place.country)")
                    print("当前城市：\(place.locality)")
                    
                    self.loadLocationLatitudeAndLongitude(locationInfo.coordinate.latitude, longitude: locationInfo.coordinate.longitude, title: "\(place.country)\(place.locality)", subTitle: "\(place.name)")
                }
            })
            
            
            
            print(locationInfo.coordinate.latitude)
        }
    }
    
    
    func loadLocationLatitudeAndLongitude(latiude:Double, longitude:Double, title:String, subTitle:String){
        let coor:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latiude, longitude: longitude)
        let sp:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let rg:MKCoordinateRegion = MKCoordinateRegion(center: coor, span: sp)
        mapBgView.setRegion(rg, animated: true)
        let annotion:MKPointAnnotation = MKPointAnnotation()
        annotion.coordinate = coor
        annotion.title = title
        annotion.subtitle = subTitle
        mapBgView.addAnnotation(annotion)
    }
    
    
    
    
    
    
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  ViewController2.swift
//  Mapkit
//
//  Created by secret on 15/12/28.
//  Copyright © 2015年 secret. All rights reserved.
//

import UIKit
import MapKit


class ViewController2: UIViewController,MKMapViewDelegate {

    /*
    地图显示
    覆盖层
    大头针
    水印
    */
    
    var mapView:MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化地图空间
        mapView = MKMapView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        //设置地图模式
        /**
        Standard 标准
        case Satellite
        case Hybrid
        **/
        mapView.mapType = MKMapType.Standard
        //可滑动
        mapView.scrollEnabled = true
        //可缩放
        mapView.zoomEnabled = true
        //可旋转
        mapView.rotateEnabled = true
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        self.locateTolatitudeAndLongtitude(22.55088562, longti: 113.9663327)
        
        let tap:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "MapViewTap1:")
        mapView.userInteractionEnabled = true
        mapView.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    func locateTolatitudeAndLongtitude(latitu:Double, longti:Double){
        //声明一个coord
        let coor:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitu, longitude: longti)
        //设置精确范围
        let sp:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        //由经纬度和精确度组成新的区域范围
        let rg:MKCoordinateRegion = MKCoordinateRegion(center: coor, span: sp)
        
        //设置地图显示精确度和范围
        mapView.setRegion(rg, animated: true)
        
        //初始化一个大头针变量
        let annotation:MKPointAnnotation = MKPointAnnotation()
        //设置大头针区域
        annotation.coordinate = coor
        //设置主标题
        annotation.title = "这是深圳市!"
        //设置副标题
        annotation.subtitle = "我在这里上班！！！"
        //添加大头针
        mapView.addAnnotation(annotation)
    }
    func MapViewTap1(press:UILongPressGestureRecognizer){
        //! 强制拆包 表示一定存在，否则crash
        //通过文件路径，找到文件在沙盒中的绝对路径
        let url:NSURL = NSBundle.mainBundle().URLForResource("1", withExtension: "png")!
        //以url区创建一个水印准则
        let titleLayer:MKTileOverlay = MKTileOverlay(URLTemplate: url.description)
        mapView.addOverlay(titleLayer)
    }
    
    
    func MapViewTap(press:UILongPressGestureRecognizer){
        //取得屏幕的物理坐标点
        let point:CGPoint = press.locationInView(mapView)
        //将物理坐标点转换成coor
        let coor:CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
        //以coor生成一个CLLocation
//        let location:CLLocation = CLLocation(latitude: coor.latitude, longitude: coor.longitude)
        //定义一个圆形覆盖层(并未真正创建了)
        let circle:MKCircle = MKCircle(centerCoordinate: coor, radius: 100)
        mapView.addOverlay(circle)
        /**
        MKOverlay 覆盖层
        
        MKCircle 圆形覆盖层
        MKPolygon 多边形覆盖层
        MKPolyline 多变现覆盖层
        MKTileOverlay 水印
        **/
        
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        /*
        圆形覆盖层
        
        //创建真正的课件覆盖层
        let circleRender:MKCircleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
        //填充色
        circleRender.fillColor = UIColor.redColor()
        //描边色
        circleRender.strokeColor = UIColor.blackColor()
        circleRender.alpha = 0.2
        
        return circleRender
        */
        
        
        //水印
        let titleRen:MKTileOverlayRenderer = MKTileOverlayRenderer(tileOverlay: overlay as! MKTileOverlay)
        titleRen.alpha = 0.3
        return titleRen
        
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

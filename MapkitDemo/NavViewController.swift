//
//  NavViewController.swift
//  MapkitDemo
//
//  Created by secret on 15/12/29.
//  Copyright © 2015年 secret. All rights reserved.
//

import UIKit
import MapKit

class NavViewController: UIViewController,MKMapViewDelegate {
    
    var startField:UITextField!
    var deretField:UITextField!
    var navi:UIButton!
    var _mapView:MKMapView!
    var geo:CLGeocoder!//反编码管理类
    var _startLocation:CLLocation!//出发点位置信息
    var _dereLocation:CLLocation!//目的地位置信息
    
    var navPath:MKPolyline!//导航路线
    var startMark:CLPlacemark!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.loadMapView()
        self.initSubView()
        
    }
    
    func loadMapView() {
        _mapView = MKMapView(frame: self.view.frame)
        _mapView.mapType = MKMapType.Standard
        _mapView.scrollEnabled = true
        _mapView.zoomEnabled = true
        _mapView.rotateEnabled = true
        _mapView.delegate = self
        self.view.addSubview(_mapView)
        self.locateTolatitudeAndLongtitude(22.55088562, longti: 113.9663327)
    }
    
    
    func initSubView() {
        
        startField = UITextField(frame: CGRectMake((screenWidth - 175)/2, 20, 175, 20))
        deretField = UITextField(frame: CGRectMake((screenWidth - 175)/2, 50, 175, 20))
        startField.borderStyle = UITextBorderStyle.RoundedRect
        deretField.borderStyle = UITextBorderStyle.RoundedRect
        startField.placeholder = "输入出发地"
        deretField.placeholder = "输入目的地"
        startField.font = UIFont.systemFontOfSize(13)
        deretField.font = UIFont.systemFontOfSize(13)
        self.view.addSubview(startField)
        self.view.addSubview(deretField)
        
        
        navi = UIButton(type: UIButtonType.Custom)
        navi.frame = CGRectMake(startField.frame.origin.x + startField.bounds.size.width + 10, 30, 60, 20)
        navi.setTitle("开始导航", forState: UIControlState.Normal)
        navi.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        navi.titleLabel?.font = UIFont.systemFontOfSize(13)
        navi.layer.borderColor = UIColor.blackColor().CGColor
        navi.layer.borderWidth = 1
        navi.layer.masksToBounds = true
        navi.layer.cornerRadius = 4.0
        navi.addTarget(self, action: "starNavGation:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(navi)
    }
    
    func starNavGation(sender:UIButton) {
        
        startField.resignFirstResponder()
        deretField.resignFirstResponder()
        
        if startField.text == nil || deretField.text == nil || startField.text == "" || deretField.text == ""
        {
            
            let alert:UIAlertController = UIAlertController(title: "温馨提示：", message: "出发地或目的地无效", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            
//            let alert = UIAlertView.init(title: "温馨提示：", message: "出发地或目的地无效", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
            
            return
        }
        //编码起始地
        self.coderwithString(startField.text!)
            
    }
    
    
    
    func coderwithString(address:String){
        //初始化
        geo = CLGeocoder()
        geo.geocodeAddressString(address) { (placeMark:[CLPlacemark]?, error:NSError?) -> Void in
            if placeMark?.count > 0 //实际操作中，这里需要筛选处理
            {
                
                let placrmarks = placeMark![0] as CLPlacemark
                if address == self.startField.text{
                    //保存好编码后的位置信息
                    self._startLocation = placrmarks.location! as CLLocation
                    //创建出发地大头针
                    let annotion:MKPointAnnotation = MKPointAnnotation()
                    annotion.coordinate = (placrmarks.location?.coordinate)!
                    annotion.title = "出发地"
                    //添加起始地大头针
                    self._mapView.addAnnotation(annotion)
                    self.startMark = placrmarks//placeMark信息保留
                    self.locateTolatitudeAndLongtitude((placrmarks.location?.coordinate.latitude)!, longti: (placrmarks.location?.coordinate.longitude)!)
                    //编码目的地
                    self.coderwithString(self.deretField.text!)
                    
                }else{
                    //保存好编码后的位置信息
                    self._dereLocation = placrmarks.location! as CLLocation
                    //创建目的地大头针
                    let annotion:MKPointAnnotation = MKPointAnnotation()
                    annotion.coordinate = (placrmarks.location?.coordinate)!
                    annotion.title = "目的地"
                    //添加目的地大头针
                    self._mapView.addAnnotation(annotion)
                    /**********  到这里，位置信息编码结束
                      ************/
                    
                    //启动导航
                    self.startNavagationWithMark(placrmarks)
                    
                }
            }
        }
    }
    
    func startNavagationWithMark(placemark:CLPlacemark){
        
//        _mapView.removeOverlay(self.navPath)//移除上次定位线路，但在iOS9.0不适用
//        初始化一个导航请求
        let request:MKDirectionsRequest = MKDirectionsRequest()
//        self.getItemWithMark(startMark)
        //设置出发地
        request.source = self.getItemWithMark(startMark)
        //设置目的地
        request.destination = self.getItemWithMark(placemark)
        //创建响应头
        let mkdirection:MKDirections = MKDirections(request: request)
        mkdirection.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error:NSError?) -> Void in
            //查询返回的第一条线路
            let route:MKRoute = (response?.routes[0])! as MKRoute
            self.navPath = route.polyline
            //添加到地图
            self._mapView.addOverlay(self.navPath, level: MKOverlayLevel.AboveLabels)
        }
    }
    
    //设置地点
    func getItemWithMark(mark:CLPlacemark) -> MKMapItem{
        //通过MKPlacemark创建一个CLPlacemark
        let mkp:MKPlacemark = MKPlacemark(placemark: mark)
        let item:MKMapItem = MKMapItem(placemark: mkp)
        
        
        return item
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        //初始化导航路线
        let naRende:MKPolylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        //设置导航路线颜色
        naRende.strokeColor = UIColor.redColor()
        //设置导航
        naRende.lineWidth = 5
        
        return naRende
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //设置标示符，和创建cell类似
        let identy:String = "identi"
        var pinView:MKPinAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier(identy) as? MKPinAnnotationView
        if nil == pinView{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identy)
            
        }
        
        if annotation.title! == "出发地" {
            //设置出发地大头针颜色
            pinView?.pinTintColor = UIColor.greenColor()
        }else{
            //设置目的地大头针颜色
            pinView?.pinTintColor = UIColor.redColor()
        }
        
        return pinView
    }
    
    func locateTolatitudeAndLongtitude(latitu:Double, longti:Double){
        //声明一个coord
        let coor:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitu, longitude: longti)
        //设置精确范围
        let sp:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        //由经纬度和精确度组成新的区域范围
        let rg:MKCoordinateRegion = MKCoordinateRegion(center: coor, span: sp)
        
        //设置地图显示精确度和范围
        _mapView.setRegion(rg, animated: true)
        
        //初始化一个大头针变量
//        let annotation:MKPointAnnotation = MKPointAnnotation()
//        //设置大头针区域
//        annotation.coordinate = coor
//        //设置主标题
//        annotation.title = "这是深圳市!"
//        //设置副标题
//        annotation.subtitle = "我在这里上班！！！"
//        //添加大头针
//        _mapView.addAnnotation(annotation)
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

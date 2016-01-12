//
//  ViewController1.swift
//  Mapkit
//
//  Created by secret on 15/12/28.
//  Copyright © 2015年 secret. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController1: UIViewController,CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager!
    var znzLayer:CALayer!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //指南针  方向检测
        self.view.backgroundColor = UIColor.whiteColor();
//        initZnzlayer()
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        //判断是否能进行方向检测
        if CLLocationManager.headingAvailable(){
            //开启方向检测
            locationManager.startUpdatingHeading()
        }
        

        // Do any additional setup after loading the view.
    }
    //成功检测到当前设备方向改变
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //将设备的方向角度转换成弧度
        let heading:Double = -1 * M_1_PI * newHeading.magneticHeading / 180.0
        //创建不断改变CALayer的transform属性动画
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "transform")
        //获取指南针图层初始值
        let fromValue:CATransform3D = znzLayer.transform
        //设置动画初始值
        animation.fromValue = NSValue(CATransform3D: fromValue)
        //绕Z轴旋转Heading弧度的变化值
        let toValue:CATransform3D = CATransform3DMakeRotation(CGFloat(heading), 0, 0, 1)
        //设置最终变化值
        animation.toValue = NSValue(CATransform3D: toValue)
        //设置动画时间，动画时间越短，反应越灵敏
        animation.duration = 0.5
        //当前动画结束后自动移除
        animation.removedOnCompletion = true
        //将最终的动画加载给指南针图层
        znzLayer.transform = toValue
        //把指南针动画加到图层中
        znzLayer.addAnimation(animation, forKey: nil)
        
    }
    //判断是否允许当前设备展示方向改变量
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        return true
    }
    
    
    func initZnzlayer() {
        //获取宽高
        
        
        let line = UIView(frame: CGRectMake(screenWidth/2, 0, 1, screenHeight))
        line.backgroundColor = UIColor.blackColor()
        self.view.addSubview(line)
        
        znzLayer = CALayer()
        znzLayer.frame = CGRectMake((screenWidth - 100)/2, (screenHeight-100)/2, 100, 100)
        znzLayer.contents = UIImage(named: "1")?.CGImage
        self.view.layer.addSublayer(znzLayer)
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

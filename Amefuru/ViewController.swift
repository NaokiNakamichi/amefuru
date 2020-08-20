//
//  ViewController.swift
//  Amefuru
//
//  Created by 中道直基 on 2020/08/16.
//  Copyright © 2020 中道直基. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,AmefuruDelegate {
    
    
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var tenkiLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var notificationLabel: UILabel!
    
    var location = "東京"
    var time = "6:00"
    let weatherData = WeatherData()
    
    var tenki_oneday = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationLabel.text = String(time)
        locationLabel.text = String(location)
        tenkiLabel.text = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: "time") != nil{
            
            time = UserDefaults.standard.object(forKey: "time") as! String
            
            notificationLabel.text = String(time)
            
        }
        
        if UserDefaults.standard.object(forKey: "location") != nil{
            
            location = UserDefaults.standard.object(forKey: "location") as! String
            
            locationLabel.text = String(location)
            
            
            let locationid = weatherData.locationDic[location]!
            
            var text = "https://api.openweathermap.org/data/2.5/forecast?id=\(locationid)&units=metric&lang=ja&appid=beb93facb9fc78ad5605bd5c7ecf6303"
            
            let url = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (responce) in
            
            switch responce.result{
                
            case .success:
                for i in 0...4{
                    
                    let json:JSON = JSON(responce.data as Any)
                    let tenki = json["list"][i]["weather"][0]["main"].string
                    
                    self.tenki_oneday.append(tenki!)
                    
                    
                }
                //self.tenki_oneday.contains("Rain")
                if self.tenki_oneday.contains("Rain"){
                    self.background.image = UIImage(named: "ame2")
                    self.tenkiLabel.text = "傘を持っていこう"
                } else{
                    
                    self.background.image = UIImage(named: "sky")
                    self.tenkiLabel.text = "今日は晴れ！"
                }
                
                print(self.tenki_oneday)
                
                self.tenki_oneday = []
                
                break
                    
                case .failure(let error):
                    //print(error)
                
                
                break
                    
                
                
                }
                
                
            
        }
        
            
        }
        
        
        
        
    }
    
    func showNowSetting(location:String, time:String) {
        locationLabel.text = location
        notificationLabel.text = time
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setting"{
            
            let settingVC = segue.destination as! SettingViewController
            
            settingVC.time = time
            
            settingVC.location = location
            
            settingVC.delegate = self
            
            
            
        }
    }
    
    
    
    
    
    
}


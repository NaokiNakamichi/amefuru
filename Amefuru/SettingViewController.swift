//
//  SettingViewController.swift
//  Amefuru
//
//  Created by 中道直基 on 2020/08/16.
//  Copyright © 2020 中道直基. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol AmefuruDelegate {
    func showNowSetting(location:String,time:String)
}

class SettingViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    var delegate:AmefuruDelegate?
    
    var location = String()
    var time = String()
    var timeDate = Date()
    
    let weatherData = WeatherData()
    
    var tenki_oneday = [String]()

    
    var request:UNNotificationRequest!
    
    
    
    @IBOutlet weak var desicionButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    
    @IBOutlet weak var locationTextField: UITextField!
    
    
    var datePicker: UIDatePicker = UIDatePicker()
    
    var pickerView: UIPickerView = UIPickerView()
    
    
    
    
    
    let dataList = [
        "東京","大阪","福岡","北海道","兵庫"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        
        datePicker.datePickerMode = UIDatePicker.Mode.time
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        textField.inputView = datePicker
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        let toolbarLocation = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let doneItemLocation = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneLocation))
        
        toolbarLocation.setItems([doneItemLocation], animated: true)
        
        
        
        // インプットビュー設定
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
        
        locationTextField.inputView = pickerView
        locationTextField.inputAccessoryView = toolbarLocation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: "time") != nil{
            
            time = UserDefaults.standard.object(forKey: "time") as! String
            
            textField.text = String(time)
            
        }
        
        if UserDefaults.standard.object(forKey: "location") != nil{
            
            location = UserDefaults.standard.object(forKey: "location") as! String
            
            locationTextField.text = String(location)
            
        }
    }
    
    
    
    // 決定ボタン押下
    @objc func done() {
        textField.endEditing(true)
        
        // 日付のフォーマット
        let f = DateFormatter()
        f.timeStyle = .short
        f.locale = Locale(identifier: "ja_JP")
        let settime = datePicker.date
        textField.text = f.string(from: settime)
        timeDate = settime
        
        time = f.string(from: settime)
        
    }
    
    @objc func doneLocation() {
        locationTextField.endEditing(true)
        
    }
    
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
     
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return dataList[row]
    }
     
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        // 処理
        locationTextField.text = dataList[row]
        location = dataList[row]
    }
    

    @IBAction func desicion(_ sender: Any) {
        
        // 現在時刻の1分後に設定
        let date2 = timeDate
        let targetDate = Calendar.current.dateComponents(
                   [.hour, .minute],
                   from: date2)
        
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        

        
        // トリガーの作成
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: targetDate, repeats: true)
        
        
        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = "今日は雨が降るかも！"
        
        content.body = "傘が必要か確認しよう"
        content.sound = UNNotificationSound.default
        
        // 通知リクエストの作成
        request = UNNotificationRequest.init(identifier: "CalendarNotification",content: content,trigger: trigger)
        
        
        
        // 通知リクエストの登録
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
        
    

        
        UserDefaults.standard.set(time,forKey: "time")
        UserDefaults.standard.set(location,forKey: "location")
        delegate?.showNowSetting(location: location, time: time)

        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func getData(id:Int) {
        location = UserDefaults.standard.object(forKey: "location") as! String
        
        print(location)
        time = UserDefaults.standard.object(forKey: "time") as! String
        
        let locationid = weatherData.locationDic[location]!
        print(locationid)
        
        
        var text = "https://api.openweathermap.org/data/2.5/forecast?id=\(locationid)&units=metric&lang=ja&appid=beb93facb9fc78ad5605bd5c7ecf6303"
        
        print(text)
        
        let url = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (responce) in
            
            switch responce.result{
                
            case .success:
                for i in 0...7{
                    
                    let json:JSON = JSON(responce.data as Any)
                    let tenki = json["list"][i]["weather"][0]["main"].string
                    
                    self.tenki_oneday.append(tenki!)
                    
                    
                }
                
                if self.tenki_oneday.contains("Clear"){
                    print("foo")
                }
                
                
                
                
                break
                
            case .failure(let error):
                print(error)
            }
            
                
            
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

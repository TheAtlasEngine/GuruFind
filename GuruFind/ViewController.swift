//
//  ViewController.swift
//  GuruFind
//
//  Created by Kosuke Nishimura on 2018/06/15.
//  Copyright © 2018年 Kosuke.Nishimura. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let searchRangeList = ["300m", "500m", "1000m", "2000m", "3000m"]
    var searchRange: String?
    
    var latitude: Double?
    var longitude: Double?
    
    var locationManager: CLLocationManager = CLLocationManager()

    @IBOutlet weak var locationInfoStatusLabel: UILabel!
    @IBOutlet weak var searchRangeField: UITextField!
    @IBAction func searchButton(_ sender: Any) {
    }
    @IBAction func getLocationInfo(_ sender: Any) {
        getLocationInformation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ナビゲーションバーを表示しない
        navigationController!.setNavigationBarHidden(true, animated: true)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        
        let toolbar =  UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.sizeToFit()
        toolbar.isUserInteractionEnabled = true
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        toolbar.setItems([doneButton], animated: false)
        
        self.searchRangeField.inputView = picker
        self.searchRangeField.inputAccessoryView = toolbar
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //メッセージ出力メソッド
    func alertMessage(_ title: String, _ msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //---------------------------------------------------
    // pickerView Delegate
    //---------------------------------------------------
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.searchRangeList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.searchRangeList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.searchRangeField.text = self.searchRangeList[row]
        switch self.searchRangeList[row] {
        case "300m":
            self.searchRange = "1"
            break
        case "500m":
            self.searchRange = "2"
            break
        case "1000m":
            self.searchRange = "3"
            break
        case "2000m":
            self.searchRange = "4"
            break
        case "3000m":
            self.searchRange = "5"
            break
        default:
            self.searchRange = "2"
        }
    }
    @objc func done() {
        self.searchRangeField.resignFirstResponder()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //---------------------------------------------------
    // locationManager Delegate
    //---------------------------------------------------

    //位置情報の取得メソッド
    func getLocationInformation() {
        self.locationInfoStatusLabel.text = "現在地を取得中・・・"
        print("In the getLocationInformation")
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted:
                alertMessage("位置情報サービスの利用が制限されています", "「設定」⇒「一般」⇒「機能制限」")
                break
            case .denied:
                alertMessage("位置情報の利用が許可されていません", "「設定」⇒「プライバシー」⇒「位置情報サービス」⇒「Gurufind」")
                break
            case .authorizedAlways:
                locationManager.requestLocation()
                break
            case .authorizedWhenInUse:
                locationManager.requestLocation()
                break
            default:
                break
            }
        } else {
            alertMessage("位置情報サービスが無効です", "「設定」⇒「プライバシー」⇒「位置情報サービス」")
            return
        }
        return
    }
    
    //位置情報の取得に失敗した時
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alertMessage("現在地の取得に失敗しました", "現在地を再取得するか、アプリを再起動してください")
        self.locationInfoStatusLabel.text = "現在地を取得できませんでした"
    }
    
    //位置情報サービスの許可が変わった時
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        getLocationInformation()
    }
    
    //位置情報を取得した時
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            return
        }
        self.locationInfoStatusLabel.text = "現在地を取得しました"
        print("coordinate = \(coordinate)")
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    //---------------------------------------------------
    // Prepare for the next view
    //---------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tableVC = segue.destination as! TableViewController
        if self.searchRange == nil {
            tableVC.searchRange = "2"
        } else {
            tableVC.searchRange = self.searchRange!
        }
        
        tableVC.latitude = "\(self.latitude!)"
        tableVC.longitude = "\(self.longitude!)"
        
        //テスト（地元だと田舎すぎてぐるなびの情報が乏しい・・・）
        //新宿駅
        //let latitude = 35.689
        //let longitude = 139.692
        //tableVC.latitude = "\(latitude)"
        //tableVC.longitude = "\(longitude)"
    }
}

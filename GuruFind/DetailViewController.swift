//
//  DetailViewController.swift
//  GuruFind
//
//  Created by Kosuke Nishimura on 2018/06/17.
//  Copyright © 2018年 Kosuke.Nishimura. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class DetailViewController: UIViewController {

    @IBOutlet weak var restNameLabel: UILabel!
    @IBOutlet weak var restAddressLabel: UILabel!
    @IBOutlet weak var restTelLabel: UILabel!
    @IBOutlet weak var restOpentimeLabel: UILabel!
    @IBOutlet weak var restImageView: UIImageView!
    
    var restInfoBuff: Restaurant = Restaurant()
    
    var cacheImage = NSCache<AnyObject, UIImage>()
    var hasImage1: Bool = true
    var hasImage2: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if restInfoBuff.name.contains("\n") {
            self.restNameLabel.text = "情報がありません"
        } else {
            self.restNameLabel.text = restInfoBuff.name
        }
        if restInfoBuff.address.contains("\n") {
            self.restAddressLabel.text = "住所：情報がありません"
        } else {
            self.restAddressLabel.text = "住所：\(restInfoBuff.address)"
        }
        if restInfoBuff.tel.contains("\n") {
            self.restTelLabel.text = "電話番号：情報がありません"
        } else {
            self.restTelLabel.text = "電話番号：\(restInfoBuff.tel)"
        }
        if restInfoBuff.opentime.contains("\n") {
            self.restOpentimeLabel.text = "営業時間：情報がありません"
        } else {
            self.restOpentimeLabel.text = restInfoBuff.opentime
        }
        if self.restOpentimeLabel.text!.contains("<BR>") {
            self.restOpentimeLabel.text = self.restOpentimeLabel.text!.replacingOccurrences(of: "<BR>", with: "\n")
        }
        
        self.hasImage1 = hasImageFromWeb(imageView: restImageView, stringURL: self.restInfoBuff.image_url.shop_image1)
        self.hasImage2 = hasImageFromWeb(imageView: restImageView, stringURL: self.restInfoBuff.image_url.shop_image2)
        
        if hasImageFromWeb(imageView: restImageView, stringURL: self.restInfoBuff.image_url.shop_image1) {
            //No code
        } else {
            self.hasImage1 = false
            if hasImageFromWeb(imageView: restImageView, stringURL: self.restInfoBuff.image_url.shop_image2) {
                //No code
            } else {
                self.hasImage2 = false
            }
        }
        if self.hasImage1 == false && self.hasImage2 == false {
            self.restImageView.image = UIImage(named: "noImage")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hasImageFromWeb(imageView: UIImageView, stringURL: String) -> Bool {
        if stringURL.contains("{") {
            //画像なし
            return false
        }
        
        if let requestUrl = URL(string: encodeStrToUrlStr(stringURL)!) {
            if let cacheImage = self.cacheImage.object(forKey: requestUrl as AnyObject) {
                imageView.image = cacheImage
                return true
            } else {
                Alamofire.request(requestUrl).responseImage { response in
                    guard let image = response.result.value else {
                        return
                    }
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
                return true
            }
        } else {
            //requestUrlが生成できなかった
            return false
        }
    }
    func encodeStrToUrlStr(_ string: String) -> String? {
        guard let encodedStr = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        return encodedStr
    }

}

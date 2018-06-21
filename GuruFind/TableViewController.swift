//
//  TableViewController.swift
//  GuruFind
//
//  Created by Kosuke Nishimura on 2018/06/17.
//  Copyright © 2018年 Kosuke.Nishimura. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class TableViewController: UITableViewController {
    
    //---------------------------------------------------
    //ぐるなびAPIへの準備
    //---------------------------------------------------
    let keyid: String = "14bc6c7888536ecbdaec632acd6e50be"
    let entryURL: String = "https://api.gnavi.co.jp/RestSearchAPI/20150630/"
    var requestUrl: String = ""
    
    //parameters
    var searchRange: String?
    var longitude: String?
    var latitude: String?
    let format: String = "json"
    let hitPerPage: String = "100"
    var parameters: Parameters = Parameters()
    
    var restaurantArray: [Restaurant] = [Restaurant]()
    var restInfoBuff: Restaurant = Restaurant()
    
    var cacheImage = NSCache<AnyObject, UIImage>()
    var hasImage1: Bool = true
    var hasImage2: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        
        //ナビゲーションバーを表示
        navigationController!.setNavigationBarHidden(false, animated: true)
        
        self.parameters = ["keyid": keyid, "format": format, "range": searchRange!, "longitude": longitude!, "latitude": latitude!, "hit_per_page": hitPerPage]
        //セルの情報を取得
        createTableData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    //セルに表示する情報を各構造体へ格納
    func createTableData() {
        self.requestUrl = entryURL + "?"
        for key in self.parameters.keys {
            let value = self.parameters[key]
            self.requestUrl += "\(key)=\(value!)&"
        }
        
        print(requestUrl)
        
        //JSONDecoderを使いたかったが incorrect formatのエラーが出てどうしても解決できなかった。
        Alamofire.request(requestUrl).responseJSON { response in
            
            // serialized json response
            guard let object = response.result.value else {
                print("ERROR: object -> Failured")
                return
            }
            let json = JSON(object)
            //print("json = \(json)")
            print("total_hit_count = \(json["total_hit_count"])")
            
            
            guard let jsonRestArray = json["rest"].array else {
                print("ERROR: jsonArray -> Failured")
                return
            }
            
            for restInfo in jsonRestArray {
                let name = "\(restInfo["name"])"
                
                let access = restInfo["access"]
                let station = "\(access["station"])"
                let station_exit = "\(access["station_exit"])"
                let walk = "\(access["walk"])"
                let line = "\(access["line"])"
                let note = "\(access["note"])"
                
                let imageUrl = restInfo["image_url"]
                let image1 = "\(imageUrl["shop_image1"])"
                let image2 = "\(imageUrl["shop_image2"])"
                
                let address = "\(restInfo["address"])"
                let tel = "\(restInfo["tel"])"
                let opentime = "\(restInfo["opentime"])"
                
                let imageStruct = ImageUrl(image1: image1, image2: image2)
                let accessStruct = Access(station: station, station_exit: station_exit, walk: walk, line: line, note: note)
                let restStruct = Restaurant(name: name, access: accessStruct, image_url: imageStruct, address: address, tel: tel, opentime: opentime)
                
                self.restaurantArray.append(restStruct)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurantArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell

        // Configure the cell...
        let restData = restaurantArray[indexPath.row]
        let access = restData.access
        
        cell.restNameLabel.text = restData.name
        
        //アクセスの情報
        //情報があるかどうかで場合わけ
        //ない場合 = "{\n}"なので「{」があったら情報なし
        var accessInfoStatus: [String: String] = ["路線": "情報なし", "最寄駅": "情報なし", "駅の出口": "情報なし", "移動時間": "情報なし"]
        var accessInfoString: String = ""
        if access.line.contains("{") == false {
            accessInfoStatus["路線"] = access.line
        }
        if access.station.contains("{") == false {
            accessInfoStatus["最寄駅"] = access.station
        }
        if access.station_exit.contains("{") == false {
            accessInfoStatus["駅の出口"] = access.station_exit
        }
        if access.walk.contains("{") == false {
            accessInfoStatus["移動時間"] = access.walk + "分"
        }
        for key in accessInfoStatus.keys{
            if let value = accessInfoStatus[key] {
                if key != accessInfoStatus.keys.sorted().last {
                    accessInfoString += "\(key): \(value)\n"
                } else {
                    accessInfoString += "\(key): \(value)"
                }
            } else { continue }
        }
        cell.restAccessLabel.text = accessInfoString
        
        //画像を設定
        //なかったらnoImage.pngをつかう
        if hasImageFromWeb(imageView: cell.restImageView, stringURL: restData.image_url.shop_image1) {
            //No code
        } else {
            self.hasImage1 = false
            if hasImageFromWeb(imageView: cell.restImageView, stringURL: restData.image_url.shop_image2) {
                //No code
            } else {
                self.hasImage2 = false
            }
        }
        
        if self.hasImage1 == false && self.hasImage2 == false {
            cell.restImageView.image = UIImage(named: "noImage")
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow
        let detailVC = segue.destination as! DetailViewController
        detailVC.restInfoBuff = self.restaurantArray[indexPath!.row]
    }
}

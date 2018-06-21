//
//  Structs.swift
//  GuruFind
//
//  Created by Kosuke Nishimura on 2018/06/17.
//  Copyright © 2018年 Kosuke.Nishimura. All rights reserved.
//

import Foundation

struct Restaurants: Codable {
    var total_hit_count: String
    var hit_per_page: String
    var page_offset: String
    var rest: [Restaurant]
    
    init() {
        self.total_hit_count = ""
        self.hit_per_page = ""
        self.page_offset = ""
        self.rest = [Restaurant()]
    }
    
    init(total_hit_count: String, hit_per_page: String, page_offset: String, rest: [Restaurant]) {
        self.total_hit_count = total_hit_count
        self.hit_per_page = hit_per_page
        self.page_offset = page_offset
        self.rest = rest
    }
}

struct Restaurant: Codable {
    var name: String
    var access: Access
    var image_url: ImageUrl
    var address: String
    var tel: String
    var opentime: String
    
    init() {
        self.name = ""
        self.access = Access()
        self.image_url = ImageUrl()
        self.address = ""
        self.tel = ""
        self.opentime = ""
    }
    
    init(name: String, access: Access, image_url: ImageUrl, address: String, tel: String, opentime: String) {
        self.name = name
        self.access = access
        self.image_url = image_url
        self.address = address
        self.tel = tel
        self.opentime = opentime
    }
}

struct Access: Codable {
    var station: String
    var station_exit: String
    var walk: String
    var line: String
    var note: String
    
    init() {
        self.station = ""
        self.station_exit = ""
        self.walk = ""
        self.line = ""
        self.note = ""
    }
    
    init(station: String, station_exit: String, walk: String, line: String, note: String) {
        self.station = station
        self.station_exit = station_exit
        self.walk = walk
        self.line = line
        self.note = note
    }
}

struct ImageUrl: Codable {
    var shop_image1: String
    var shop_image2: String
    
    init() {
        self.shop_image1 = ""
        self.shop_image2 = ""
    }
    
    init (image1: String, image2: String) {
        self.shop_image1 = image1
        self.shop_image2 = image2
    }
}

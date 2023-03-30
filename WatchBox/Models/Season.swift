//
//  Season.swift
//  WatchBox
//
//  Created by Iyinoluwa Tugbobo on 3/29/23.
//

import Foundation

struct Season: Decodable {
    let air_date: String?
    let episode_count: Int?
    let name: String?
    let overview: String?
    let poster_path: String?
    let season_number: Int?
}

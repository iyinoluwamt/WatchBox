//
//  Episode.swift
//  WatchBox
//
//  Created by Iyinoluwa Tugbobo on 3/29/23.
//

import Foundation

struct Episode: Decodable {
    let air_date: String
    let season_number: Int
    let episode_number: Int
    let name: String
    let overview: String
    let vote_average: Float
    let vote_count: Int
}

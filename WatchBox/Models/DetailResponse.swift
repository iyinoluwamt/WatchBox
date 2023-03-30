//
//  Detail.swift
//  WatchBox
//
//  Created by Iyinoluwa Tugbobo on 3/29/23.
//

import Foundation

struct DetailResponse: Decodable {
    let name: String
    let id: Int
    let overview: String
    let genres: [Genre]
    
    let backdrop_path: String
    let created_by: [Creator]
    let first_air_date: String

    let homepage: String
    let in_production: Bool
    
    let last_episode_to_air: Episode?
    let next_episode_to_air: Episode?
    
    let networks: [Network]
    let number_of_episodes: Int
    let number_of_seasons: Int
    let seasons: [Season]
    let status: String
    let tagline: String
    let vote_average: Float
    let vote_count: Int
    
    
}

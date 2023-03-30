//
//  Movie.swift
//  WatchBox
//
//  Created by Iyinoluwa Tugbobo on 3/29/23.
//

import Foundation

struct TMDBResponse: Decodable { var results: [Show] }

struct Show: Decodable {
    var id: Int
    
    var name: String
    var overview: String
    var first_air_date: String
    var genre_ids: [Int]
    
    var origin_country: [String]

    var popularity: Float
    var vote_average: Float
    var vote_count: Int
    
    var backdrop_path: String?
    var poster_path: String?
    
//    var overview: String
//    var popularity: Float
//    var poster_path: String
//    var release_date: String
//    var vote_average: Float
//    var vote_count: Int
}

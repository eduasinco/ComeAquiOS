//
//  Objects.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//
import UIKit

public class User: Decodable{
    var id: Int?
    var username: String?
    var email: String?
    var first_name: String?
    var last_name: String?
    var full_name: String?
    var bio: String?
    var phone_number: String?
    var phone_code: Int?
    var profile_photo: String?
    var is_active: Bool?
    var is_admin: Bool?
    var background_photo: String?
    var rating: Float?
    var rating_n: Int?
    var timeZone : String?
}

public class FoodPostImageObject: Decodable{
    var id: Int?
    var food_photo: String?
}

public class FoodPostObject: Decodable{
    var id: Int?
    var owner: User?
    var plate_name: String?
    
    var formatted_address: String?
    var place_id: String?
    var lat: Double?
    var lng: Double?
    var street_n: String?
    var route: String?
    var administrative_area_level_2: String?
    var administrative_area_level_1: String?
    var country: String?
    var postal_code: String?
    var max_dinners: Int?
    var dinners_left: Int?
    var time_to_show: String?
    var time_range: String?
    var start_time: String?
    var end_time: String?
    var price: Int?
    var price_to_show: String?
    var food_type: String?
    var description: String?
    var status: String?
    var images: [FoodPostImageObject]?
    
    var favourite: Bool?
    var rating: Float?
    var visible: Bool?
}

public class FavouritePost: Decodable{
    var id: Int?
    var owner: User?
    var post: FoodPostObject?
}

public class CommentObject: Decodable{
    var id: Int?
    var owner: User?
    // var post: FoodPostObject?
    var comment: CommentObject?
    var replies: [CommentObject]?
    var message: String?
    var votes_n: Int?

    var is_user_up_vote: Bool?
    var is_max_depth: Bool?
    var depth: Int?
    var is_last: Bool?
    var created_at: String?
}

//
//  Objects.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//
import UIKit

public class User: Decodable{
    var id: Int!
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
    var confirmed_orders: [OrderObject]?
    
    var favourite: Bool?
    var rating: Float?
    var visible: Bool?
    
    var reviews: [ReviewObject]?
    var created_at: String?
    
}
public class ReviewObject: Decodable {
    var id: Int?
    var owner: User?
    var review: String?
    var star_reason: String?
    var rating: Float?
    var replies: [ReviewReplyObject]?
    var created_at: String?
}
public class ReviewReplyObject: Decodable {
    var id: Int?
    var owner: User?
    var review: ReviewObject?
    var reply: String?
    var created_at: String?
}



public class FavouritePost: Decodable{
    var id: Int?
    var owner: User?
    var post: FoodPostObject?
}

public class OrderObject: Decodable{
    var id: Int?
    var owner: User?
    var post: FoodPostObject?
    var poster: User?
    var order_status: String?
    var seen: Bool?
    var slightly_seen: Bool?
    var reviewed_post: Bool?
    var reviewed_guest: Bool?
    var additional_guests: Int?
    var order_price: Int?
    
    var created_at: String?
}

public class NotificationObject: Decodable {
    var id: Int?
    var owner: User?
    var from_user: User?
    var type: String?
    var title: String?
    var body: String?
    var extra: String?
    var createdAt: String?
    var type_id: Int?
}

public class PaymentMethodObject: Decodable {
    var id: String?
    var last4: String?
    var exp_month: Int?
    var exp_year: Int?
    var chosen: Bool?
    var brand: String?
}


public class StripeAccountInfoObject: Decodable {
    var id: String?
    var business_profile: BusinessProfile?
    var individual: Individual?
    var payouts_enabled: Bool?
    var requirements: Requirements?
    var external_accounts: ExternalAccounts?
    var error_message: String?
}
public class Individual: Decodable {
    var id: String?
    var id_number: Int?
    var address: Address?
    var dob: DOB?
    var email: String?
    var first_name: String?
    var last_name: String?
    var phone: String?
    var ssn_last_4_provided: Bool?
    var verification: Verification?
}
public class Address: Decodable {
    var city: String?
    var country: String?
    var line1: String?
    var line2: String?
    var postal_code: String?
    var state: String?
}
public class DOB: Decodable {
    var day: Int?
    var month: Int?
    var year: Int?
}
public class Requirements: Decodable {
    var currently_due: [String]?
}
public class BusinessProfile: Decodable {
    var url: String?
}
public class ExternalAccounts: Decodable {
    var url: [Account]?
}
public class Account: Decodable {
    var id: String?
    var account: String?
    var bank_name: String?
    var country: String?
    var last4: String?
    var routing_number: String?
}
public class Verification: Decodable {
    var status: String?
    var document: Document?
}
public class Document: Decodable{
    var back: String?
    var front: String?
}

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
    var error_message: String?
    var is_user_blocked: Bool?
    var are_you_blocked_by_the_user: Bool?
    
    lazy var profile_photo_: String? = {
        guard let profile_photo = self.profile_photo else { return nil }
//        if !profile_photo.contains("http") {
//            return SERVER + profile_photo
//        }
        return profile_photo
    }()
    
    lazy var background_photo_: String? = {
        guard let background_photo = self.background_photo else { return nil }
//        if !background_photo.contains(SERVER) {
//            return SERVER + background_photo
//        }
        return background_photo
    }()
}

public class FoodPostImageObject: Decodable{
    var id: Int?
    var food_photo: String?
    
    lazy var food_photo_: String? = {
        guard let food_photo = self.food_photo else { return nil }
//        if !food_photo.contains(SERVER) {
//            return SERVER + food_photo
//        }
        return food_photo
    }()
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
    var time_range: String?
    var start_time: String?
    var end_time: String?
    var price: Int?
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
    
    lazy var time_to_show: String? = {
        guard let start_time = self.start_time, let end_time = self.end_time else { return nil}
        return Date.hhmmHappenedNowTodayYesterdayWeekDay(start: start_time, end: end_time)
    }()
    lazy var created_at_to_show: String? = {
        guard let created_at = self.created_at else { return nil}
        return Date.hYesterdayWeekDay(isoDateString: created_at)
    }()
}
public class ReviewObject: Decodable {
    var id: Int?
    var owner: User?
    var review: String?
    var star_reason: String?
    var rating: Float?
    var replies: [ReviewReplyObject]?
    var created_at: String?
    
    lazy var created_at_to_show: String? = {
        guard let created_at = self.created_at else { return nil}
        return Date.hYesterdayWeekDay(isoDateString: created_at)
    }()
}
public class ReviewReplyObject: Decodable {
    var id: Int?
    var owner: User?
    var review: ReviewObject?
    var reply: String?
    var created_at: String?
    
    lazy var created_at_to_show: String? = {
        guard let created_at = self.created_at else { return nil}
        return Date.hYesterdayWeekDay(isoDateString: created_at)
    }()
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
    var reviewed_post: Bool?
    var reviewed_guest: Bool?
    var additional_guests: Int?
    var order_price: Int?
    var created_at: String?
    
    var seen: Bool?
    var slightly_seen: Bool?
    
    lazy var created_at_to_show: String? = {
        guard let created_at = self.created_at else { return nil}
        return Date.hYesterdayWeekDay(isoDateString: created_at)
    }()
    
    var error_message: String?
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
    var data: [Account]?
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

public class ChatObject: Decodable {
    var id: Int?
    var users: [User]?
    var last_message : MessageObject?
    var created_at : String?
    var user_chat_status: [UserChatStatus]?
    
    lazy var created_at_to_show: String? = {
        guard let created_at = self.created_at else { return nil}
        return Date.hYesterdayWeekDay(isoDateString: created_at)
    }()
    
    lazy var user_chat_status_dict: [Int: Int]? = {
        guard let user_chat_status = self.user_chat_status else { return nil }
        var dict: [Int: Int] = [:]
        for status in user_chat_status {
            dict[status.user_id!] = status.unseen_messages_count!
        }
        return dict
    }()
}

public class PlaneChatObject: Decodable {
    var id: Int?
    var users: [User]?
    var created_at : String?
    var user_chat_status: [UserChatStatus]?
    
    lazy var created_at_to_show: String? = {
        guard let created_at = self.created_at else { return nil}
        return Date.hYesterdayWeekDay(isoDateString: created_at)
    }()
}

public class UserChatStatus: Decodable {
    var user_id: Int?
    var seen: Bool?
    var unseen_messages_count: Int?
}

public class MessageObject: Decodable {
    var id: Int?
    var sender: User?
    var message: String?
    var created_at: String?
    
    var newDay: Bool? = false
    var topSpace: Bool? = false
    var lastInGroup: Bool? = false
    var isOwner: Bool? = false
    
    lazy var h: String? = {
        guard let created_at = self.created_at else { return nil}
        return Date.h(isoDateString: created_at)
    }()
    
    lazy var created_at_to_show: String? = {
        guard let created_at = self.created_at else { return nil}
        return Date.hYesterdayWeekDay(isoDateString: created_at)
    }()
    
    lazy var created_at_week_day: String? = {
        guard let created_at = self.created_at else { return nil}
        return Date.todayYesterdayWeekDay(isoDateString: created_at)
    }()
}

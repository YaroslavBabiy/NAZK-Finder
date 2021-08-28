//
//  SearchPerson.swift
//  NAZK Finder
//
//  Created by Yaroslav Babiy on 27.08.2021.
//

import Foundation

struct PersonResponse: Decodable {
    let error: Int?
    let data: [Person]?
    let count: Int?
    let notice: String?
}

struct Person: Decodable {
    let data: PersonData
    let corruption_affected: Int
    let user_declarant_id: Int
    let id: String
}

struct PersonData: Decodable {
    let step_1: Step_1
}

struct Step_1: Decodable {
    let data: Step_1_Data
}

struct Step_1_Data: Decodable {
    let firstname: String
    let lastname: String
    let workPost: String
}

struct SearchPerson {
    let id: String
    let firstname: String
    let user_declarant_id: Int
    let lastname: String
    let workPost: String
    var comment: String?
}

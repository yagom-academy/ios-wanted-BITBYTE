//
//  ReviewTableViewHeaderViewModel.swift
//  CustomKeyboard
//
//  Created by 백유정 on 2022/07/12.
//

import Foundation

class ReviewTableViewHeaderViewModel {
    private let networkService = ReviewAPIService()
    
    func postReview(content: String, _ completion: @escaping (Result<Post, APIError>) -> Void) -> Review {
        networkService.postReview(content: content, completion)
        
        let user = User(userName: "Me", profileImage: URL.profileImageURL)
        let review = Review(user: user, content: content, createdAt: dateToString(Date()))
        
        return review
    }
    
    private func dateToString(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let res = formatter.string(from: time).replacingOccurrences(of: "_", with: "T")
        return res
    }
}

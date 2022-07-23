//
//  HomeViewModel.swift
//  CustomKeyboard
//
//  Created by rae on 2022/07/11.
//

import Foundation
import Combine

final class HomeViewModel {
    @Published var reviews: [Review] = []
    @Published var isUploaded = false
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func reviewsCount() -> Int {
        return reviews.count
    }
    
    func review(at index: Int) -> Review {
        return reviews[index]
    }
    
    func fetch() {
        let reviewsEndpoint = APIEndpoints.getReviews()
        
        networkManager.fetchData(endpoint: reviewsEndpoint, dataType: ReviewResponse.self) { [weak self] result in
            switch result {
            case .success(let reviewResponse):
                self?.reviews = reviewResponse.data
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func submit(contentString: String) {
        let content = Content(content: contentString)
        
        guard let bodyData = try? JSONEncoder().encode(content) else {
            print("JSONEncoder Error")
            return
        }
        
        let postEndpoint = APIEndpoints.postReview(bodyData: bodyData)
        
        networkManager.postRequest(endpoint: postEndpoint) { result in
            switch result {
            case .success(let data):
                let content = String(decoding: data, as: UTF8.self)
                let review = Review(user: User(userName: "User", profileImage: ""),
                                    content: content,
                                    createdAt: "")
                self.reviews.insert(review, at: 0)
                self.isUploaded = true
            case .failure(let error):
                print(error.localizedDescription)
                self.isUploaded = false
            }
        }
    }
}

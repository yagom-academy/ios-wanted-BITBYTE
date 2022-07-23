//
//  ReviewDataManager.swift
//  CustomKeyboard
//
//  Created by 조성빈 on 2022/07/12.
//

import Foundation

struct ReviewDataManager {
        
    func getData(_ url : String, completion : @escaping (ReviewList) -> Void ) {
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                if let safeData = data {
                    guard let result = self.parseJSON(safeData) else {return}
                    completion(result)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data : Data) -> ReviewList? {
        let decorder = JSONDecoder()
        do {
            let decodeData = try decorder.decode(ReviewList.self, from: data)
            return decodeData
        } catch {
            return nil
        }
    }
    
    func postData(_ url : String, _ content : String, completion : @escaping (String?) -> Void) {
        
        guard let url = URL(string: url) else {return}
        let data = uploadData(content: content)

        guard let uploadData = try? JSONEncoder().encode(data) else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            let successRange = 200..<300
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {return}
            if successRange.contains(statusCode) {
                guard let data = data else {
                    return
                }
                completion(String(data: data, encoding: .utf8))
            }
        }
        task.resume()
    }
}

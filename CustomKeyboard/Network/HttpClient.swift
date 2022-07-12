//
//  HttpClient.swift
//  CustomKeyboard
//
//  Created by 신의연 on 2022/07/12.
//
// URLSesstion으로 할지 멘토님한테 질문
import Foundation

class HttpClient {
    private let baseUrl: String

    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    // TODO: - UrlSession 으로
    func getJson(params: [String: Any], completed: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            
            do {
                let url = URL(string: self.baseUrl)
                let data = try Data(contentsOf: url!)
                DispatchQueue.main.async {
                    completed(Result.success(data))
                }
            } catch {
                DispatchQueue.main.async {
                    completed(Result.failure(error))
                }
            }
        }
    }
    
    func getJson(completed: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            
            do {
                guard let url = URL(string: self.baseUrl) else { return }
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    completed(Result.success(data))
                }
            } catch {
                DispatchQueue.main.async {
                    completed(Result.failure(error))
                }
            }
        }
    }
    
    
}

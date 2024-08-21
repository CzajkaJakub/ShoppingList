//
//  HttpRequestService.swift
//  ShoppingList
//
//  Created by jczajka on 16/08/2024.
//

import Foundation

public class HttpRequestService {
    
    public static func sendGetRequest(urlPath: String, completion: @escaping (Result<Data, Error>) -> Void)  {
        
        guard let url = URL(string: urlPath) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Data"])))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
}

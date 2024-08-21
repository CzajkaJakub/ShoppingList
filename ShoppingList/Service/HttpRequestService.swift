//
//  HttpRequestService.swift
//  ShoppingList
//
//  Created by Patrycja on 16/08/2024.
//

import Foundation
public class HttpRequestService {
    

    public static func sendGetRequest(barCodeNumber: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v3/product/" + barCodeNumber + ".json") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }


    
    public static func sendPostRequest(barCodeNumber: String) {
        // Step 1: Define the URL
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v3/product/" + barCodeNumber + ".json")  else {
            print("Invalid URL")
            return
        }

        // Step 2: Create the URLRequest object and configure it
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Step 3: Define the JSON data to send
        let json: [String: Any] = ["key1": "value1", "key2": 123]
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }

        // Step 4: Attach the JSON data to the request
        request.httpBody = jsonData

        // Step 5: Create a URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Step 6: Handle the response
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Step 7: Parse the data (if needed)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("Response JSON: \(json)")
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }

        // Step 8: Start the task
        task.resume()
    }

}

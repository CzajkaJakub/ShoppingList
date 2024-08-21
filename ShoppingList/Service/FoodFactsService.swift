//
//  FoodFactsService.swift
//  ShoppingList
//
//  Created by jczajka on 17/08/2024.
//

import Foundation

public class FoodFactsService {
    
    public static func fetchProductDataByBarCode(barCode: String, completion: @escaping (ProductDto?) -> Void) {
        
        let formattedFoodApiWithBarCode = String(format: Constants.openFoodFactsBarHttpLink, barCode)
        
        HttpRequestService.sendGetRequest(urlPath: formattedFoodApiWithBarCode) { result in
            switch result {
            case .success(let data):
                do {
                    // Decode the JSON data to ProductDto
                    let productDto = try JSONDecoder().decode(ProductDto.self, from: data)
                    completion(productDto)
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(nil)
                }
                
            case .failure(let error):
                print("Error: \(error)")
                completion(nil)
            }
        }
    }
}

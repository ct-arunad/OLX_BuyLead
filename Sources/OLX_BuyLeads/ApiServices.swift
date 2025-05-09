//
//  ApiServices.swift
//  CTE_BuyLeads
//
//  Created by Aruna on 25/03/25.
//

import Foundation

public class ApiServices {
    
    enum APIError: Error {
        case invalidURL
        case requestFailed(statusCode: Int)
        case requestFailedwithresponse(response: String)
        case noData
        case decodingError
        case other(Error)
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .requestFailed(let statusCode):
                return "Request failed with status code: \(statusCode)"
            case .requestFailedwithresponse(let response):
                return "Request failed with response: \(response)"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .other(let error):
                return error.localizedDescription
            }
        }
    }
    struct APIRequest {
        let url: URL
        let method: String
        let headers: [String: String]?
        let body: Data?
    }
    private var accessToken: String?
      private var refreshToken: String?
    
    func sendRawDataWithHeaders(parameters: [String: Any], headers: [String: String],url : String, completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        
        var requestparameters = parameters
        var requestheaders = headers
        let urlString = url // Replace with your API URL
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set header for JSON
       
           for (key, value) in requestheaders {
               request.setValue(value, forHTTPHeaderField: key)
           }
           // Convert parameters to JSON data
           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: requestparameters, options: [])
           } catch {
               completion(.failure(.other(error)))
               return
           }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error as! ApiServices.APIError))
                           return
                       }
                       guard let httpResponse = response as? HTTPURLResponse else {
                           completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil) as! ApiServices.APIError))
                           return
                       }

                       if httpResponse.statusCode == 403 { // Token expired
                           self.refreshToken { result in
                               switch result {
                               case .success(let newToken):
                                   // Update the token and retry the original request
                                   self.accessToken = newToken
                                   requestheaders["Authorization"] = "Bearer \(newToken)"
                                   if(requestparameters["action"] as! String == "homeapi"){
                                       requestparameters["refresh_token"] = MyPodManager.refresh_token
                                   }
                                   self.sendRawDataWithHeaders(parameters: requestparameters, headers: requestheaders, url: urlString, completion: completion)
                               case .failure(let error):
                                   completion(.failure(.other(error)))
                               }
                           }
                       } else {
                           // Return the original data
                           do {
                                  let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                               completion(.success(json!))
                                
                              } catch {
                                  completion(.failure(.requestFailed(statusCode: httpResponse.statusCode)))
                              }
                       }
                   }
                   task.resume()
    }
    // Function to refresh the token
    private func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        
        let headers = ["x-origin-Panamera":"dev","Api-Version":"134","client-language":"en-in","Authorization":"Bearer \(MyPodManager.refresh_token)"] as! [String:String]

        let refreshUrl = URL(string: "https://fcgapi.olx.in/dealer/v1/auth/refresh_token")!
            var request = URLRequest(url: refreshUrl)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        let parameters = ["user_id":MyPodManager.user_id] as! [String:Any]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            return
        }

          let task = URLSession.shared.dataTask(with: request) { data, response, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }

              guard let data = data else {
                  completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                  return
              }

              do {
                  let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                  if let newToken = json?["access_token"] as? String {
                      MyPodManager.requestDataFromHost(accesstoken: json?["access_token"] as! String, userid: json?["user_id"] as! String, refreshtoken: json?["refresh_token"] as! String)
                      completion(.success(newToken))
                  } else {
                      completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
                  }
              } catch {
                  completion(.failure(error))
              }
          }
          task.resume()
      }
    
    

    
    func fetchdatawithGETAPI(headers: [String: String],url : String,authentication: String, completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        
        var requestHeader = headers
       let urlString = url // Replace with your API URL
       guard let url = URL(string: urlString) else { return }
       var request = URLRequest(url: url)
          request.httpMethod = "GET"
          request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set header for JSON
       if(authentication.count != 0){
           let body: [String: Any] = [
               "Authorization":authentication
           ]
           request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
       }
          for (key, value) in headers {
              request.setValue(value, forHTTPHeaderField: key)
          }
       let task = URLSession.shared.dataTask(with: request) { data, response, error in
       if let error = error {
           completion(.failure(.other(error)))
           return
       }
       guard let data = data else {
           completion(.failure(.noData))
           return
       }
       do {
           let httpResponse = response as? HTTPURLResponse
           if(httpResponse!.statusCode == 200){
              let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
              completion(.success(jsonResponse ?? [:]))
              }
           else if(httpResponse!.statusCode == 403) { // Token expired
               self.refreshToken { result in
                   switch result {
                   case .success(let newToken):
                       // Update the token and retry the original request
                       self.accessToken = newToken
                       requestHeader["Authorization"] = "Bearer \(newToken)"
                       self.fetchdatawithGETAPI(headers: requestHeader, url: urlString, authentication: "", completion: completion)
                   case .failure(let error):
                       completion(.failure(.other(error)))
                   }
               }
           }
           else{
               let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse!.statusCode)
               completion(.failure(.requestFailedwithresponse(response: message)))
           }
       } catch {
           //print(response.debugDescription as Any)
           completion(.failure(.other(error)))
       }
   }
   
   task.resume()
   }
    
    func isValidPhoneNumber(_ phone: String) -> Bool {
        let mobileRegex = "^[6-9][0-9]{9}$"
          let predicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
          return predicate.evaluate(with: phone)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
}

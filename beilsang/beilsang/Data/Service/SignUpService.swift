//
//  SignUpService.swift
//  beilsang
//
//  Created by Seyoung on 2/11/24.
//

import Foundation
import Alamofire

class SignUpService {
    static let shared = SignUpService()
    private init() {}
    
    func nameCheck(name: String?, completionHandler: @escaping (_ data: nameCheckResponse) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        
        DispatchQueue.main.async {
            let addPath = "?name=\(name ?? "")"
            let url = APIConstants.duplicateCheck + addPath
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            print("Request URL: \(url)")
            print("Request Headers: \(headers)")
            
            AF.request(url, method: .get, encoding: URLEncoding.queryString, headers: headers).validate().responseDecodable(of: nameCheckResponse.self) { response in
                print("Received response from server")
                switch response.result {
                case .success:
                    print("Response: \(response)")
                    guard let result = response.value else {
                        print("Response value is nil")
                        return
                    }
                    completionHandler(result)
                    print("GET 요청 성공")
                case .failure(let error):
                    switch error.responseCode{
                    case 401:
                        print("토큰 만료")
                        TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                            self.nameCheck(name: name) { reResponse in
                                completionHandler(reResponse)
                            }
                        }
                    default : print("네트워크 fail")
                    }
                }
            }
        }
    }
    
    func nicknameExist(completionHandler: @escaping (_ data: nameCheckResponse) -> Void) {
        guard let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken),
              let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken) else {
            print("Token is missing")
            return
        }
        
        let url = APIConstants.nicknameExist
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        print("Request URL: \(url)")
        print("Request Headers: \(headers)")
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: nameCheckResponse.self) { response in
            print("Received response from server")
            print(response)
            switch response.result {
            case .success:
                print("Response: \(response)")
                guard let result = response.value else {
                    print("Response value is nil")
                    return
                }
                completionHandler(result)
                print("닉네임 존재 여부 GET 요청 성공")
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let responseCode = error.responseCode, responseCode == 401 {
                    print("토큰 만료")
                    TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in
                        // Refresh token completion
                    }) {
                        // Retry the nicknameExist request after refreshing token
                        self.nicknameExist(completionHandler: completionHandler)
                    }
                } else {
                    print("네트워크 fail")
                }
            }
        }
    }

    
    
    func signUp(accessToken: String, gender : String, nickName : String, birth : String, address : String?, keyword : String, discoveredPath : String?, resolution : String, recommendNickname : String?, completion: @escaping (NetworkResult<Any>) -> Void) {
        let url = APIConstants.signUpURL
        let headers: HTTPHeaders = [
            "accept": "*/*",
            "Content-Type": "application/json"
        ]
        let body: Parameters = ["accessToken" : accessToken,
                                "gender": gender,
                                "nickName": nickName,
                                "birth" : birth,
                                "address" : address ?? "",
                                "keyword" : keyword,
                                "discoveredPath" : discoveredPath ?? "",
                                "resolution" : resolution,
                                "recommendNickname" : recommendNickname ?? ""]
        
        let dataRequest = AF.request(url,
                                     method: .post,
                                     parameters: body,
                                     encoding: JSONEncoding.default,
                                     headers: headers)
        
        dataRequest.responseData { response in
            //debugPrint(response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.value else { return }
                print("요청 성공")
                
                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)
                
            case .failure:
                completion(.pathErr)
            }
        }
    }

    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        switch statusCode {
        case ..<300 : return isVaildData(data: data)
        case 401 : return .tokenExpired
        case 400, 402..<500: return .pathErr
        case 500..<600 : return .serverErr
        default : return .networkFail
        }
    }
    
    //통신이 성공하고 원하는 데이터가 올바르게 들어왔을때 처리하는 함수
    private func isVaildData(data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder() //서버에서 준 데이터를 Codable을 채택
        
        guard let decodedData = try? decoder.decode(SignUpResponse.self, from: data)
                //데이터가 변환이 되게끔 Response 모델 구조체로 데이터를 변환해서 넣고, 그 데이터를 NetworkResult Success 파라미터로 전달
        else { return .networkFail }
        
        return .success(decodedData as Any)
    }
}

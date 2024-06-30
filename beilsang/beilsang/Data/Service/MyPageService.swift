//
//  MyPageService.swift
//  beilsang
//
//  Created by 강희진 on 2/9/24.
//

import Foundation
import Alamofire


class MyPageService {
    
    static let shared = MyPageService()
    private init() {}
    
    
    // MARK: - get
    // 마이페이지 뷰 get
    func getMyPage(baseEndPoint:BaseEndpoint, addPath:String?,  completionHandler: @escaping (_ data: GetMyPage) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        
        DispatchQueue.main.async {
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            guard let addPath = addPath else { return }
            let url = baseEndPoint.requestURL + addPath
            print(url)
            
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: GetMyPage.self, completionHandler:{ response in
                switch response.result{
                case .success:
                    guard let result = response.value else {return}
                    completionHandler(result)
                    print("get 요청 성공")
                    // 호출 실패 시 처리 위함
                case .failure(let error):
                    switch error.responseCode{
                    case 401:
                        print("토큰 만료")
                        TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                            self.getMyPage(baseEndPoint: baseEndPoint, addPath: addPath) { reResponse in
                                completionHandler(reResponse)
                            }
                        }
                    default : print("네트워크 fail")
                    }
                    print(error)
                    print("get 요청 실패")
                }
            })
        }
    }
    // 포인트 뷰 get
    func getPoint(baseEndPoint:BaseEndpoint, addPath:String?,  completionHandler: @escaping (_ data: GetPoint) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
        
        guard let addPath = addPath else { return }
        let url = baseEndPoint.requestURL + addPath
        print(url)
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: GetPoint.self, completionHandler:{ response in
            switch response.result{
            case .success:
                guard let result = response.value else {return}
                completionHandler(result)
                print("get 요청 성공")
                // 호출 실패 시 처리 위함
            case .failure(let error):
                switch error.responseCode{
                case 401:
                    print("토큰 만료")
                    TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                        self.getPoint(baseEndPoint: baseEndPoint, addPath: addPath) { reResponse in
                            completionHandler(reResponse)
                        }
                    }
                default : print("네트워크 fail")
                }
                print(error)
                print("get 요청 실패")
            }
        })
    }
    // 마이 챌린지 피드의 피드 리스트 get
    func getFeedList(baseEndPoint:BaseEndpoint, addPath:String?,  completionHandler: @escaping (_ data: GetFeedModel) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        DispatchQueue.main.async {
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            guard let addPath = addPath else { return }
            let url = baseEndPoint.requestURL + addPath
            print(url)
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: GetFeedModel.self, completionHandler:{ response in
                switch response.result{
                case .success:
                    guard let result = response.value else {return}
                    completionHandler(result)
                    print("get 요청 성공")
                // 호출 실패 시 처리 위함
                case .failure(let error):
                    switch error.responseCode{
                    case 401:
                        print("토큰 만료")
                        TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                            self.getFeedList(baseEndPoint: baseEndPoint, addPath: addPath) { reResponse in
                                completionHandler(reResponse)
                            }
                        }
                    default : print("네트워크 fail")
                    }
                    print(error)
                    print("get 요청 실패")
                }
            })
        }
    }
    // 찜 챌린지, 카테고리별 챌린지 리스트(발견)
    func getChallengeList(baseEndPoint:BaseEndpoint, addPath:String?,  completionHandler: @escaping (_ data: GetChallenge) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        DispatchQueue.main.async {
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            guard let addPath = addPath else { return }
            let url = baseEndPoint.requestURL + addPath
            print(url)
            
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: GetChallenge.self, completionHandler:{ response in
                switch response.result{
                case .success:
                    guard let result = response.value else {return}
                    completionHandler(result)
                    print("get 요청 성공")
                // 호출 실패 시 처리 위함
                case .failure(let error):
                    switch error.responseCode{
                    case 401:
                        print("토큰 만료")
                        TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                            self.getChallengeList(baseEndPoint: baseEndPoint, addPath: addPath) { reResponse in
                                completionHandler(reResponse)
                            }
                        }
                    default : print("네트워크 fail")
                    }
                    print(error)
                    print("get 요청 실패")
                }
            })
        }
    }
    // 카테고리 별 챌린지 리스트
    func getMyPageChallengeList(baseEndPoint:BaseEndpoint, addPath:String?,  completionHandler: @escaping (_ data: GetMyPageChallenge) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        DispatchQueue.main.async {
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            guard let addPath = addPath else { return }
            let url = baseEndPoint.requestURL + addPath
            print(url)
            
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: GetMyPageChallenge.self, completionHandler:{ response in
                debugPrint(response)
                switch response.result{
                case .success:
                    guard let result = response.value else {return}
                    completionHandler(result)
                    print("get 요청 성공")
                    // 호출 실패 시 처리 위함
                case .failure(let error):
                    switch error.responseCode{
                    case 401:
                        print("토큰 만료")
                        TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                            self.getMyPageChallengeList(baseEndPoint: baseEndPoint, addPath: addPath) { reResponse in
                                completionHandler(reResponse)
                            }
                        }
                    default : print("네트워크 fail")
                    }
                    print(error)
                    print("get 요청 실패")
                }
            })
        }
    }
    // 닉네임 중복 체크
    func getDuplicateCheck(baseEndPoint:BaseEndpoint, addPath:String?,  completionHandler: @escaping (_ data: GetDuplicateCheck) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        DispatchQueue.main.async {
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            guard let addPath = addPath else { return }
            let url = baseEndPoint.requestURL + addPath
            print(url)
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: GetDuplicateCheck.self, completionHandler:{ response in
                switch response.result{
                case .success:
                    guard let result = response.value else {return}
                    completionHandler(result)
                    print("get 요청 성공")
                    // 호출 실패 시 처리 위함
                case .failure(let error):
                    switch error.responseCode{
                    case 401:
                        print("토큰 만료")
                        TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                            self.getDuplicateCheck(baseEndPoint: baseEndPoint, addPath: addPath) { reResponse in
                                completionHandler(reResponse)
                            }
                        }
                    default : print("네트워크 fail")
                    }
                    print(error)
                    print("get 요청 실패")
                }
            })
        }
    }
    // 피드 상세 정보 보기
    func getMyPageFeedDetail(baseEndPoint:BaseEndpoint, addPath:String?,  completionHandler: @escaping (_ data: GetMyPageFeedDetail) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        DispatchQueue.main.async {
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            guard let addPath = addPath else { return }
            let url = baseEndPoint.requestURL + addPath
            print(url)
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: GetMyPageFeedDetail.self, completionHandler:{ response in
                switch response.result{
                case .success:
                    guard let result = response.value else {return}
                    completionHandler(result)
                    print("get 요청 성공")
                    // 호출 실패 시 처리 위함
                case .failure(let error):
                    switch error.responseCode{
                    case 401:
                        print("토큰 만료")
                        TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                            self.getMyPageFeedDetail(baseEndPoint: baseEndPoint, addPath: addPath) { reResponse in
                                completionHandler(reResponse)
                            }
                        }
                    default : print("네트워크 fail")
                    }
                    print(error)
                    print("get 요청 실패")
                }
            })
        }
    }
    
    // MARK: - post
    // 피드 찜 버튼 누르기
    func postLikeButton(baseEndPoint:BaseEndpoint, addPath:String?, completionHandler: @escaping (_ data: BaseModel) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        
        guard let addPath = addPath else { return }
        let url = baseEndPoint.requestURL + addPath
        print(url)
        
        AF.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: BaseModel.self, completionHandler:{ response in
            switch response.result{
            case .success:
                guard let result = response.value else {return}
                completionHandler(result)
                print("post 요청 성공")
                // 호출 실패 시 처리 위함
            case .failure(let error):
                switch error.responseCode{
                case 401:
                    print("토큰 만료")
                    TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                        self.postLikeButton(baseEndPoint: baseEndPoint, addPath: addPath) { reResponse in
                            completionHandler(reResponse)
                        }
                    }
                default : print("네트워크 fail")
                }
                print(error)
                print("post 요청 실패")
            }
        })
    }
    
    // MARK: - patch
    // AccountInfoView
    func patchAccountInfo(baseEndPoint:BaseEndpoint, addPath:String?, parameter: Dictionary<String, Any>, completionHandler: @escaping (_ data: PatchAccountInfo) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        
        guard let addPath = addPath else { return }
        let url = baseEndPoint.requestURL + addPath
        print(url)
        
        AF.request(url, method: .patch, parameters: parameter, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: PatchAccountInfo.self, completionHandler:{ response in
            switch response.result{
            case .success:
                guard let result = response.value else {return}
                completionHandler(result)
                print("patch 요청 성공")
                // 호출 실패 시 처리 위함
            case .failure(let error):
                switch error.responseCode{
                case 401:
                    print("토큰 만료")
                    TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                        self.patchAccountInfo(baseEndPoint: baseEndPoint, addPath: addPath, parameter: parameter) { reResponse in
                            completionHandler(reResponse)
                        }
                    }
                default : print("네트워크 fail")
                }
                print(error)
                print("patch 요청 실패")
            }
        })
    }
    
    func patchProfileImage(imageData: Data, completionHandler: @escaping (_ data: PatchProfileImage?) -> Void) {
            guard let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken),
                  let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken) else {
                print("필요한 값이 없습니다.")
                return
            }
            
            let url = "https://beilsang.com/api/profile/image" // 실제 URL로 변경하세요
            
            // HTTP Headers : 요청 헤더
            let header: HTTPHeaders = [
                "accept": "*/*",
                "Content-Type": "multipart/form-data",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "profileImage", fileName: "profile.jpg", mimeType: "image/jpeg")
            }, to: url, method: .patch, headers: header)
            .validate()
            .responseDecodable(of: PatchProfileImage.self) { response in
                debugPrint(response)
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else { return }
                    switch statusCode {
                    case ..<300:
                        guard let result = response.value else { return }
                        completionHandler(result)
                        print("프로필 이미지 patch 요청 성공")
                    default:
                        print("네트워크 실패")
                    }
                case .failure(let error):
                    guard let statusCode = response.response?.statusCode else { return }
                    switch statusCode {
                    case 401:
                        print("토큰 만료")
                        TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in
                            self.patchProfileImage(imageData: imageData, completionHandler: completionHandler)
                        }) {
                            print("토큰 갱신 실패")
                        }
                    default:
                        print("네트워크 실패")
                    }
                    print(error)
                    print("프로필 이미지 patch 요청 실패")
                }
            }
        }
    
    // MARK: - delete
    // 피드 찜 버튼 누르기
    func deleteLikeButton(baseEndPoint:BaseEndpoint, addPath:String?, completionHandler: @escaping (_ data: BaseModel) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        
        guard let addPath = addPath else { return }
        let url = baseEndPoint.requestURL + addPath
        print(url)
        
        AF.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: BaseModel.self, completionHandler:{ response in
            switch response.result{
            case .success:
                guard let result = response.value else {return}
                completionHandler(result)
                print("post 요청 성공")
                // 호출 실패 시 처리 위함
            case .failure(let error):
                switch error.responseCode{
                case 401:
                    print("토큰 만료")
                    TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                        self.deleteLikeButton(baseEndPoint: baseEndPoint, addPath: addPath) { reResponse in
                            completionHandler(reResponse)
                        }
                    }
                default : print("네트워크 fail")
                }
                print(error)
                print("post 요청 실패")
            }
        })
    }
    
    // 카카오 회원탈퇴
    func DeleteKakaoWithDraw(completionHandler: @escaping (_ data: WithDrawResponse) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "accept": "*/*"
        ]
        let body: Parameters = ["accesstoken": accessToken]
        
        let url = APIConstants.kakaoWithDrawURL
        print(url)
        
        AF.request(url, method: .delete, parameters: body, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: WithDrawResponse.self, completionHandler:{ response in
            switch response.result{
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                switch statusCode{
                case ..<300 :
                    guard let result = response.value else {return}
                    completionHandler(result)
                    print("delete 요청 성공")
                case 401 :
                    print("토큰 만료")
                    TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                        self.DeleteKakaoWithDraw { reResponse in
                            completionHandler(reResponse)
                        }
                    }
                default : print("네트워크 fail")
                }
                // 호출 실패 시 처리 위함
            case .failure(let error):
                print(error)
                print("delete 요청 실패")
            }
        })
    }
    // 애플 회원탈퇴
    func DeleteAppleWithDraw(completionHandler: @escaping (_ data: WithDrawResponse) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        let authorizationCode = KeyChain.read(key: Const.KeyChainKey.authorizationCode)!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "accept": "*/*"
        ]
        
        let body: Parameters = ["accessToken": accessToken,
                                "authorizationCode": authorizationCode]
        
        let url = APIConstants.appleWithDrawURL
        print(url)
        
        AF.request(url, method: .delete, parameters: body, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: WithDrawResponse.self, completionHandler:{ response in
            switch response.result{
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                print(statusCode )
                switch statusCode{
                case ..<300 :
                    guard let result = response.value else {return}
                    completionHandler(result)
                    print("delete 요청 성공")
                case 401 :
                    print("토큰 만료")
                    TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                        self.DeleteAppleWithDraw { reResponse in
                            completionHandler(reResponse)
                        }
                    }
                default : print("네트워크 fail")
                }
                // 호출 실패 시 처리 위함
            case .failure(let error):
                print(error)
                print("delete 요청 실패")
            }
        })
    }
}


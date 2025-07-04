//
//  NotificationService.swift
//  beilsang
//
//  Created by Seyoung on 6/20/24.
//

import Foundation
import Alamofire
import ModelsShared
import UtilityShared
import NetworkCore

class NotificationService {
    
    static let shared = NotificationService()
    private init() {}
    
    func getNotificationData(completionHandler: @escaping (_ data: NotificationModel) -> Void) {
        let accessToken = KeyChain.read(key: Const.KeyChainKey.serverToken)!
        let refreshToken = KeyChain.read(key: Const.KeyChainKey.refreshToken)!
        
        DispatchQueue.main.async {
            let url = APIConstants.notificationURL
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            AF.request(url, method: .get, encoding: URLEncoding.queryString, headers: headers).validate().responseDecodable(of: NotificationModel.self, completionHandler:{ response in
                switch response.result{
                case .success:
                    guard let statusCode = response.response?.statusCode else { return }
                    switch statusCode{
                    case ..<300 :
                        guard let result = response.value else {return}
                        completionHandler(result)
                        print("get 요청 성공")
                    case 401 :
                        print("토큰 만료")
                        TokenManager.shared.refreshToken(refreshToken: refreshToken, completion: { _ in }) {
                            self.getNotificationData { reResponse in
                                completionHandler(reResponse)
                            }
                        }
                    default : print("네트워크 fail")
                    }
                    // 호출 실패 시 처리 위함
                case .failure(let error):
                    print(error)
                    print("get 요청 실패")
                }
            })
        }
    }
}

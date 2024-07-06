//
//  LoginViewController.swift
//  beilsang
//
//  Created by Seyoung on 1/20/24.
//

import UIKit
import SnapKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices

class LoginViewController: UIViewController {
    
    //MARK: - Properties
    
    var kakaoAccessToken : String? = ""
    var kakaoName : String? = ""
    var kakaoEmail : String? = ""
    
    lazy var logoColorImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Logo_app_color")
        view.sizeToFit()
        
        return view
    }()
    
    lazy var kakaoButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.3, alpha: 1)
        view.setTitle("카카오톡으로 로그인하기", for: .normal)
        view.setTitleColor(.beTextDef, for: .normal)
        view.titleLabel?.font = UIFont(name: "NotoSansKR-Medium", size: 16)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 1, green: 0.93, blue: 0, alpha: 1).cgColor
        view.layer.cornerRadius = 10
        if let kakaoIcon = UIImage(named: "Kakao_logo") {
            view.setImage(kakaoIcon, for: .normal)
            view.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 10)
           }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(kakaoSignInButtonPress), for: .touchDown)
        
        return view
    }()
    
    lazy var appleButton: ASAuthorizationAppleIDButton = {
        let view = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
            view.addTarget(self, action: #selector(appleButtonPress), for: .touchDown)
        
        return view
    }()
    

    lazy var bubbleLabel: UILabel = {
        let view = UILabel()
        view.text = "🌱 우리의 일상이 될 친환경 프로젝트 시작하기"
        view.font = UIFont(name: "NotoSansKR-Medium", size: 12)
        view.numberOfLines = 0
        view.textColor = .beTextDef
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        return view
    }()
    
    lazy var bubbleView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "bubble")
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.16
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowPath = nil
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(logoColorImage)
        view.addSubview(kakaoButton)
        view.addSubview(appleButton)
        view.addSubview(bubbleView)
        
        bubbleView.addSubview(bubbleLabel)
    }
    
    private func setupLayout() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        logoColorImage.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(screenHeight * 0.3)
            make.height.equalTo(120)
            make.width.equalTo(100)
        }
        
        appleButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(screenHeight * 0.1))
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(56)
        }
        
        kakaoButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(56)
            make.bottom.equalTo(appleButton.snp.top).offset(-12)
        }
        
        bubbleView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(kakaoButton.snp.top).offset(-12)
            make.height.equalTo(44)
        }
        
        bubbleLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
    }
    
    //MARK: - Actions
    
    @objc private func kakaoSignInButtonPress() {
        // 카카오톡 설치 여부 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오 앱 로그인
            loginWithApp()
        } else {
            // 카카오 웹 로그인
            loginWithWeb()
        }
    }
    
     
    @objc private func appleButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}

//MARK: - 카카오 로그인

extension LoginViewController {
    func loginWithApp() {
        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            if let error = error {
                print(error)
            } else {
                print("loginWithKakaoTalk() success.")
                
                // 카카오와 API 통신
                UserApi.shared.me {(user, error) in
                    if let error = error {
                        print(error)
                    } else {
                        print("loginWithKakaoApp() success.")
                        
                        guard let token = oauthToken?.accessToken,
                              let name = user?.kakaoAccount?.profile?.nickname,
                              let email = user?.kakaoAccount?.email
                        else{
                            print("token/email/name is nil")
                            return
                        }
                        
                        self.kakaoAccessToken = token
                        self.kakaoName = name
                        self.kakaoEmail = email
                        //서버에 보내주기
                        self.kakaologinToServer(with: token, FCMToken: UserDefaults.standard.string(forKey: Const.UserDefaultsKey.FCMToken))
                    }
                }
            }
        }
    }
    
    // 카카오톡 웹으로 로그인
    func loginWithWeb() {
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                print(error)
            } else {
                print("loginWithKakaoTalk() success.")
                
                UserApi.shared.me {(user, error) in
                    if let error = error {
                        print(error)
                    } else {
                        print("loginWithKakaoWeb() success.")
                        
                        guard let token = oauthToken?.accessToken
                        else{
                            print("token/email/name is nil")
                            return
                        }
                        
                        self.kakaoAccessToken = token
                        self.kakaologinToServer(with: token, FCMToken: Const.UserDefaultsKey.FCMToken)
                    }
                }
            }
        }
    }
}

//MARK: - 애플 로그인
extension LoginViewController : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // 원래 뷰 띄우기
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
          return self.view.window!
      }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    //로그인 성공
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let FCMToken = UserDefaults.standard.string(forKey: Const.UserDefaultsKey.FCMToken)
            print("apple Login FCM: \(String(describing: FCMToken))")
            
            if let authorizationCodeData = appleIDCredential.authorizationCode,
               let authorizationCode = String(data: authorizationCodeData, encoding: .utf8),
               let identityTokenData = appleIDCredential.identityToken,
               let identityToken = String(data: identityTokenData, encoding: .utf8) {
                //authorizationCode 저장
                KeyChain.create(key: Const.KeyChainKey.authorizationCode, token: authorizationCode)
                
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("useridentifier: \(userIdentifier)")
                print("fullName: \(fullName?.description ?? "")")
                print("email: \(email?.description ?? "")")
                
//                LoginService.shared.getAppleRefreshToken(code: authorizationCode) { data in
//                    // 응답받은 데이터를 유저디폴트에 저장함
//                    if let appleRefreshToken : String  = data.refreshToken {
//                        UserDefaults.standard.set(appleRefreshToken, forKey: "AppleRefreshToken")
//                        
//                        print("ApplerefreshToken : \(appleRefreshToken)")
//                    }
//                }
                
                self.appleloginToServer(with: identityToken, FCMToken: FCMToken ?? "")
            }
        default:
            break
        }
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 로그인 실패(유저의 취소도 포함)
        print("login failed - \(error.localizedDescription)")
    }
}

//MARK: - others
extension LoginViewController {
    // 카카오
    private func kakaologinToServer(with kakaoAccessToken: String?, FCMToken: String?) {
        guard let kakaoAccessToken = kakaoAccessToken, !kakaoAccessToken.isEmpty else {
            print("Invalid Kakao Access Token")
            return
        }
        
        LoginService.shared.kakaoLogin(accesstoken: kakaoAccessToken, FCMToken: FCMToken ?? "") { result in
            switch result {
            case .success(let data):
                guard let data = data as? LoginResponse else {
                    print("Invalid response data")
                    return
                }
                
                print("Kakao login to server success with data: \(data)")
                
                // 서버에서 보내준 accessToken, refreshToken, existMember 저장
                KeyChain.create(key: Const.KeyChainKey.serverToken, token: data.data.accessToken)
                KeyChain.create(key: Const.KeyChainKey.refreshToken, token: data.data.refreshToken)
                UserDefaults.standard.set(data.data.existMember, forKey: Const.UserDefaultsKey.existMember)
                UserDefaults.standard.set("kakao", forKey: Const.UserDefaultsKey.socialType)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.nicknameExist { result in
                        if result {
                            self.presentTo(name: "main")
                        } else {
                            self.presentTo(name: "keyword")
                        }
                    }
                }
                
            case .tokenExpired:
                print("카카오 토큰 만료")
            case .networkFail:
                print("카카오 로그인: 네트워크 실패")
            case .requestErr(let error):
                print("카카오 로그인: 요청 실패 \(error)")
            case .pathErr:
                print("카카오 로그인: 경로 오류")
            case .serverErr:
                print("카카오 로그인: 서버 오류")
            }
        }
    }

    
    private func appleloginToServer(with appleIdToken: String, FCMToken : String) {
        LoginService.shared.appleLogin(idToken: appleIdToken, FCMToken: FCMToken) { [self] result in
            switch result {
            case .success(let data):
                // 서버에서 받은 데이터 처리
                guard let data = data as? LoginResponse else { return }
                
                print("Apple login to server success with data: \(data)")
                
                KeyChain.create(key: Const.KeyChainKey.serverToken, token: data.data.accessToken)
                KeyChain.create(key: Const.KeyChainKey.refreshToken, token: data.data.refreshToken)
                //                UserDefaults.standard.set(data.data.accessToken, forKey: "serverToken")
                //                UserDefaults.standard.set(data.data.refreshToken, forKey: "refreshToken")
                UserDefaults.standard.set(data.data.existMember, forKey: Const.UserDefaultsKey.existMember)
                UserDefaults.standard.set("apple", forKey: Const.UserDefaultsKey.socialType)
                
                //클라이언트 시크릿 받아서 유저디폴트에 저장
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // 1초 딜레이
                    self.nicknameExist { result in
                        if result {
                            // 로그인 상태이면 TabBarViewController로 이동
                            self.presentTo(name: "main")
                        } else {
                            // 닉네임이 존재하지 않으면 KeywordViewController로 이동
                            self.presentTo(name: "keyword")
                        }
                    }
                }
                
            case .tokenExpired:
                print("애플 토큰 만료")
            case .networkFail:
                print("애플 로그인: 네트워크 페일")
            case .requestErr(let error):
                print("애플 로그인: 요청 페일 \(error)")
            case .pathErr:
                print("애플 로그인: 경로 오류")
            case .serverErr:
                print("애플 로그인: 서버 오류")
            }
            
        }
    }
    
    // 닉네임 존재 확인 함수
    func nicknameExist(completion: @escaping (Bool) -> Void) {
        SignUpService.shared.nicknameExist{ response in
            let exist = response.data
            completion(exist)
        }
    }
    
    // 화면 전환 함수
    func presentTo(name: String) {
        if name == "keyword" {
            // KeywordViewController로 네비게이션 컨트롤러를 사용하여 푸시
            if let navigationController = self.navigationController {
                let nextViewController = KeywordViewController() // 다음으로 이동할 뷰 컨트롤러 인스턴스 생성
                navigationController.pushViewController(nextViewController, animated: true)
            } else {
                // 네비게이션 컨트롤러가 없는 경우, 대비책으로 SceneDelegate를 사용해 루트 뷰 컨트롤러 변경
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let window = sceneDelegate.window {
                    let nextViewController = KeywordViewController()
                    UIView.transition(with: window, duration: 1.5, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = UINavigationController(rootViewController: nextViewController)
                    }, completion: nil)
                }
            }
        } else if name == "main" {
            // TabBarViewController를 루트 뷰 컨트롤러로 설정
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let window = sceneDelegate.window {
                let mainVC = TabBarViewController()
                UIView.transition(with: window, duration: 1.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = mainVC
                }, completion: nil)
            }
        } else if name == "Login" {
            // TabBarViewController를 루트 뷰 컨트롤러로 설정
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let window = sceneDelegate.window {
                let mainVC = LoginViewController()
                UIView.transition(with: window, duration: 1.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = mainVC
                }, completion: nil)
            }
        }
    }
}
    
    

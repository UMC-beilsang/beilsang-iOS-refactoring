import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import AuthenticationServices
import KakaoSDKUser
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    //로그인 로직
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        // 앱이 처음 실행되었는지 확인
        let firstLaunch = UserDefaults.standard.bool(forKey: Const.UserDefaultsKey.firshLaunch)
        if firstLaunch == false {
            // 첫 실행이면, UserDefaults의 FirstLaunch를 true로 설정하고 모든 키체인 항목 삭제
            UserDefaults.standard.set(true, forKey: Const.UserDefaultsKey.firshLaunch)
            KeyChain.delete(key: Const.KeyChainKey.serverToken)
            KeyChain.delete(key: Const.KeyChainKey.refreshToken)
        }
        
        if KeyChain.read(key: Const.KeyChainKey.serverToken) != nil{
            // 로그인 상태 확인 로직
            let mainVC = TabBarViewController()
            self.window?.rootViewController = mainVC
        } else {
            // 로그인 화면으로 이동
            print("No access Token, firsth Launch.")
            let loginVC = LoginViewController()
            self.window?.rootViewController = loginVC
        }
        window?.makeKeyAndVisible()
    }
    
    func changeRootViewController(_ newRootViewController: UIViewController) {
        guard let window = self.window else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = newRootViewController
            window.makeKeyAndVisible()
        }, completion: nil)
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}




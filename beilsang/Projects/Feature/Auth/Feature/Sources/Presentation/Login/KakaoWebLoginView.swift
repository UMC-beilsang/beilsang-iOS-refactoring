//
//  KakaoWebLoginView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 11/27/25.
//

import SwiftUI
import WebKit

public struct KakaoWebLoginView: View {
    @Environment(\.dismiss) private var dismiss
    let baseURL: String
    let onSuccess: (String, String, Bool) -> Void  // (accessToken, refreshToken, isExistMember)
    let onFailure: (String) -> Void
    
    public init(
        baseURL: String,
        onSuccess: @escaping (String, String, Bool) -> Void,
        onFailure: @escaping (String) -> Void
    ) {
        self.baseURL = baseURL
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    public var body: some View {
        NavigationStack {
            KakaoWebView(
                url: URL(string: "\(baseURL)/oauth2/authorization/kakao")!,
                onSuccess: { accessToken, refreshToken, isExistMember in
                    onSuccess(accessToken, refreshToken, isExistMember)
                    dismiss()
                },
                onFailure: { error in
                    onFailure(error)
                    dismiss()
                }
            )
            .navigationTitle("카카오 로그인")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - WebView
struct KakaoWebView: UIViewRepresentable {
    let url: URL
    let onSuccess: (String, String, Bool) -> Void  // (accessToken, refreshToken, isExistMember)
    let onFailure: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSuccess: onSuccess, onFailure: onFailure)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let onSuccess: (String, String, Bool) -> Void
        let onFailure: (String) -> Void
        private var hasHandledTokens = false
        
        init(onSuccess: @escaping (String, String, Bool) -> Void, onFailure: @escaping (String) -> Void) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            #if DEBUG
            print("🌐 WebView navigating to: \(url.absoluteString)")
            #endif
            
            // 리다이렉트 URL에서 토큰 추출 시도
            if let result = extractTokens(from: url) {
                #if DEBUG
                print("✅ Tokens extracted from URL")
                #endif
                handleSuccess(accessToken: result.accessToken, refreshToken: result.refreshToken, isExistMember: result.isExistMember)
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            // HTTP 응답 확인
            if let httpResponse = navigationResponse.response as? HTTPURLResponse {
                #if DEBUG
                print("🌐 HTTP Response: \(httpResponse.statusCode) - \(httpResponse.url?.absoluteString ?? "")")
                #endif
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let url = webView.url else { return }
            
            #if DEBUG
            print("🌐 WebView finished loading: \(url.absoluteString)")
            #endif
            
            // OAuth redirect URL인 경우 JSON 응답 확인
            if url.path.contains("/oauth/redirect") || url.path.contains("/oauth2/") {
                checkForTokensInPage(webView: webView)
            }
        }
        
        private func checkForTokensInPage(webView: WKWebView) {
            // 페이지 전체 HTML 확인
            webView.evaluateJavaScript("document.documentElement.outerHTML") { [weak self] result, error in
                if let html = result as? String {
                    #if DEBUG
                    print("📄 Page HTML (first 500 chars): \(String(html.prefix(500)))")
                    #endif
                }
            }
            
            // 페이지 body에서 JSON 추출
            webView.evaluateJavaScript("document.body.innerText") { [weak self] result, error in
                guard let self = self, !self.hasHandledTokens else { return }
                guard let bodyText = result as? String else { return }
                
                #if DEBUG
                print("📄 Page body: \(bodyText)")
                #endif
                
                // JSON 응답 파싱
                if let data = bodyText.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    #if DEBUG
                    print("📄 Parsed JSON: \(json)")
                    #endif
                    
                    if let accessToken = json["accessToken"] as? String,
                       let refreshToken = json["refreshToken"] as? String {
                        // isExistMember: true면 기존회원, false면 신규회원
                        let isExistMember = json["isExistMember"] as? Bool ?? true
                        self.handleSuccess(accessToken: accessToken, refreshToken: refreshToken, isExistMember: isExistMember)
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            #if DEBUG
            print("❌ WebView navigation failed: \(error.localizedDescription)")
            #endif
            // code 102는 무시 (리다이렉트 중)
            let nsError = error as NSError
            if nsError.domain == "WebKitErrorDomain" && nsError.code == 102 {
                return
            }
            onFailure(error.localizedDescription)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            
            #if DEBUG
            print("⚠️ WebView provisional navigation - domain: \(nsError.domain), code: \(nsError.code)")
            #endif
            
            // WebKitErrorDomain code 102: Frame load interrupted (정상적인 리다이렉트)
            // WebKitErrorDomain code 101: URL can't be shown (일부 리다이렉트)
            if nsError.domain == "WebKitErrorDomain" && (nsError.code == 102 || nsError.code == 101) {
                #if DEBUG
                print("ℹ️ Ignoring WebKit error \(nsError.code) - normal redirect behavior")
                #endif
                return
            }
            
            onFailure(error.localizedDescription)
        }
        
        private func handleSuccess(accessToken: String, refreshToken: String, isExistMember: Bool) {
            guard !hasHandledTokens else { return }
            hasHandledTokens = true
            
            #if DEBUG
            print("✅ Kakao login success!")
            print("   accessToken: \(String(accessToken.prefix(20)))...")
            print("   refreshToken: \(String(refreshToken.prefix(20)))...")
            print("   isExistMember: \(isExistMember)")
            #endif
            
            onSuccess(accessToken, refreshToken, isExistMember)
        }
        
        private func extractTokens(from url: URL) -> (accessToken: String, refreshToken: String, isExistMember: Bool)? {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return nil
            }
            
            // Query parameters에서 토큰 추출
            if let queryItems = components.queryItems {
                let accessToken = queryItems.first(where: { $0.name == "accessToken" })?.value
                let refreshToken = queryItems.first(where: { $0.name == "refreshToken" })?.value
                let isExistMemberStr = queryItems.first(where: { $0.name == "isExistMember" })?.value
                let isExistMember = isExistMemberStr == "true"
                
                if let access = accessToken, let refresh = refreshToken {
                    return (access, refresh, isExistMember)
                }
            }
            
            // Fragment에서 토큰 추출 (일부 OAuth 구현)
            if let fragment = url.fragment {
                let params = fragment.components(separatedBy: "&")
                    .compactMap { param -> (String, String)? in
                        let parts = param.components(separatedBy: "=")
                        guard parts.count == 2 else { return nil }
                        return (parts[0], parts[1])
                    }
                    .reduce(into: [String: String]()) { $0[$1.0] = $1.1 }
                
                if let access = params["accessToken"], let refresh = params["refreshToken"] {
                    let isExistMember = params["isExistMember"] == "true"
                    return (access, refresh, isExistMember)
                }
            }
            
            return nil
        }
    }
}


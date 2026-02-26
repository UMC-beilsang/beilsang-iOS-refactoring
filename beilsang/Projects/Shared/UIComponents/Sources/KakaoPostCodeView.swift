//
//  KakaoPostCodeView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 11/27/25.
//

import SwiftUI
import WebKit

/// 카카오 우편번호 서비스를 사용한 주소 검색 WebView
public struct KakaoPostCodeView: UIViewRepresentable {
    let request: URLRequest
    @Binding var isShowingKakaoWebSheet: Bool
    @Binding var address: String
    
    public init(
        request: URLRequest,
        isShowingKakaoWebSheet: Binding<Bool>,
        address: Binding<String>
    ) {
        self.request = request
        self._isShowingKakaoWebSheet = isShowingKakaoWebSheet
        self._address = address
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController.add(context.coordinator, name: "callBackHandler")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(request)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: KakaoPostCodeView
        
        init(parent: KakaoPostCodeView) {
            self.parent = parent
        }
        
        // MARK: - WKScriptMessageHandler
        public func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            if message.name == "callBackHandler" {
                if let data = message.body as? [String: Any] {
                    // 주소 데이터 추출
                    let roadAddress = data["roadAddress"] as? String ?? ""
                    let jibunAddress = data["jibunAddress"] as? String ?? ""
                    let zonecode = data["zonecode"] as? String ?? ""
                    
                    // 도로명 주소 우선, 없으면 지번 주소 사용
                    let selectedAddress = !roadAddress.isEmpty ? roadAddress : jibunAddress
                    
                    DispatchQueue.main.async {
                        if !zonecode.isEmpty {
                            self.parent.address = "[\(zonecode)] \(selectedAddress)"
                        } else {
                            self.parent.address = selectedAddress
                        }
                        self.parent.isShowingKakaoWebSheet = false
                    }
                } else if let addressString = message.body as? String {
                    // 단순 문자열로 전달되는 경우
                    DispatchQueue.main.async {
                        self.parent.address = addressString
                        self.parent.isShowingKakaoWebSheet = false
                    }
                }
            }
        }
        
        // MARK: - WKNavigationDelegate
        public func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            #if DEBUG
            print("📍 KakaoPostCodeView loaded: \(webView.url?.absoluteString ?? "")")
            #endif
        }
        
        public func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            #if DEBUG
            print("❌ KakaoPostCodeView failed: \(error.localizedDescription)")
            #endif
        }
        
        public func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            #if DEBUG
            print("❌ KakaoPostCodeView provisional navigation failed: \(error.localizedDescription)")
            #endif
        }
    }
}

// MARK: - Preview
#if DEBUG
struct KakaoPostCodeView_Previews: PreviewProvider {
    static var previews: some View {
        KakaoPostCodeView(
            request: URLRequest(url: URL(string: "https://30isdead.github.io/Kakao-Postcode/")!),
            isShowingKakaoWebSheet: .constant(true),
            address: .constant("")
        )
    }
}
#endif






//
//  APIClient.swift
//  NetworkCore
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation
import Alamofire

public enum APIClientError: Error, LocalizedError {
    case invalidURL
    case http(statusCode: Int, data: Data?)
    case decoding(String, Data?)
    case network(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .http(let statusCode, _):
            return "서버 오류 (HTTP \(statusCode))"
        case .decoding(let msg, _):
            return "응답 파싱 실패: \(msg)"
        case .network(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}

public protocol APIClientProtocol {
    // 1. body 없는 요청: GET, DELETE
    func request<Response: Decodable>(
        path: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        interceptor: RequestInterceptor?
    ) async throws -> Response
    
    // 2. body 있는 요청: POST, PUT
    func request<Request: Encodable, Response: Decodable>(
        path: String,
        method: HTTPMethod,
        body: Request,
        encoder: ParameterEncoder,
        headers: HTTPHeaders,
        interceptor: RequestInterceptor?
    ) async throws -> Response
    
    // 3. Multipart Upload
    func upload<Response: Decodable>(
        path: String,
        method: HTTPMethod,
        formData: @escaping @Sendable (MultipartFormData) -> Void,
        headers: HTTPHeaders,
        interceptor: RequestInterceptor?
    ) async throws -> Response

    // 4. body 있는 요청 + 응답 헤더 반환 (헤더로 토큰을 내려주는 로그인 등에 사용)
    func requestReturningHeaders<Request: Encodable, Response: Decodable>(
        path: String,
        method: HTTPMethod,
        body: Request,
        encoder: ParameterEncoder,
        headers: HTTPHeaders,
        interceptor: RequestInterceptor?
    ) async throws -> (value: Response, responseHeaders: HTTPHeaders)
}


public final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: Session
    
    public init(baseURL: String, session: Session = .default) {
        let normalized = APIClient.normalize(baseURL: baseURL)
        guard let url = URL(string: normalized) else {
            fatalError("❌ Invalid baseURL: \(baseURL)")
        }
        self.baseURL = url
        self.session = session
    }
    
    public func request<Response: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        headers: HTTPHeaders = APIClient.defaultHeaders,
        interceptor: RequestInterceptor? = nil
    ) async throws -> Response {
        guard let url = makeURL(from: path) else { throw APIClientError.invalidURL }
        
        return try await perform(
            session.request(url, method: method, headers: headers)
        )
    }
    
    public func request<Request: Encodable, Response: Decodable>(
        path: String,
        method: HTTPMethod = .post,
        body: Request,
        encoder: ParameterEncoder = JSONParameterEncoder.default,
        headers: HTTPHeaders = APIClient.jsonHeaders,
        interceptor: RequestInterceptor? = nil
    ) async throws -> Response {
        guard let url = makeURL(from: path) else { throw APIClientError.invalidURL }
        
        return try await perform(
            session.request(url, method: method, parameters: body, encoder: encoder, headers: headers)
        )
    }
    
    public func upload<Response: Decodable>(
        path: String,
        method: HTTPMethod = .post,
        formData: @escaping @Sendable (MultipartFormData) -> Void,
        headers: HTTPHeaders = APIClient.defaultHeaders,
        interceptor: RequestInterceptor? = nil
    ) async throws -> Response {
        guard let url = makeURL(from: path) else { throw APIClientError.invalidURL }
        
        return try await perform(
            session.upload(multipartFormData: formData, to: url, method: method, headers: headers)
        )
    }
    
    public func requestReturningHeaders<Request: Encodable, Response: Decodable>(
        path: String,
        method: HTTPMethod = .post,
        body: Request,
        encoder: ParameterEncoder = JSONParameterEncoder.default,
        headers: HTTPHeaders = APIClient.jsonHeaders,
        interceptor: RequestInterceptor? = nil
    ) async throws -> (value: Response, responseHeaders: HTTPHeaders) {
        guard let url = makeURL(from: path) else { throw APIClientError.invalidURL }

        let response = try await session.request(url, method: method, parameters: body, encoder: encoder, headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable(Response.self)
            .response

        #if DEBUG
        if let data = response.data, let string = String(data: data, encoding: .utf8) {
            let statusCode = response.response?.statusCode ?? 0
            if statusCode >= 400 {
                print("❌ API Error:")
                print("   URL: \(response.request?.url?.absoluteString ?? "unknown")")
                print("   Status: \(statusCode)")
                print("   Body: \(string)")
            }
        }
        #endif

        guard let value = response.value else {
            if let error = response.error { throw error }
            throw APIClientError.decoding("No value in response", response.data)
        }

        let responseHeaders = response.response?.headers ?? HTTPHeaders()
        return (value, responseHeaders)
    }

    private func perform<Response: Decodable>(_ request: DataRequest) async throws -> Response {
        let response = try await request
            .validate(statusCode: 200..<300)
            .serializingDecodable(Response.self)
            .response
        
        #if DEBUG
        if let data = response.data, let string = String(data: data, encoding: .utf8) {
            let statusCode = response.response?.statusCode ?? 0
            if statusCode >= 400 {
                print("❌ API Error:")
                print("   URL: \(response.request?.url?.absoluteString ?? "unknown")")
                print("   Status: \(statusCode)")
                print("   Body: \(string)")
            }
        }
        #endif
        
        guard let value = response.value else {
            let statusCode = response.response?.statusCode ?? -1
            if statusCode >= 400 {
                throw APIClientError.http(statusCode: statusCode, data: response.data)
            }
            if let error = response.error {
                #if DEBUG
                print("   Error: \(error)")
                if let data = response.data, let string = String(data: data, encoding: .utf8) {
                    print("❌ Decoding Failed - Response Body:")
                    print("   URL: \(response.request?.url?.absoluteString ?? "unknown")")
                    print("   Body: \(string)")
                }
                #endif
                throw APIClientError.network(error)
            }
            throw APIClientError.decoding("No value in response", response.data)
        }
        
        return value
    }
    
    private static func normalize(baseURL: String) -> String {
        var url = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !url.isEmpty else { return "" }
        
        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            url = "https://" + url
        }
        if url.hasSuffix("/") {
            url.removeLast()
        }
        return url
    }
    
    private func makeURL(from path: String) -> URL? {
        if let absolute = URL(string: path), absolute.scheme != nil {
            return absolute
        }
        
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let urlString = "\(baseURL.absoluteString)/\(cleanPath)"
        return URL(string: urlString)
    }
    
    public static let jsonHeaders: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    
    public static let defaultHeaders: HTTPHeaders = [
        "Accept": "application/json"
    ]
}

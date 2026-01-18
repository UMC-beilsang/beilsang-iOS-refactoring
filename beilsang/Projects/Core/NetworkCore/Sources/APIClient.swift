//
//  APIClient.swift
//  NetworkCore
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation
import Combine
import Alamofire

public enum APIClientError: Error {
    case invalidURL
    case http(statusCode: Int, data: Data?)
    case decoding(String, Data?)
    case network(Error)
}

public protocol APIClientProtocol {
    func request<Response: Decodable>(
        path: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        interceptor: RequestInterceptor?
    ) -> AnyPublisher<Response, APIClientError>
    
    func request<Request: Encodable, Response: Decodable>(
        path: String,
        method: HTTPMethod,
        body: Request,
        encoder: ParameterEncoder,
        headers: HTTPHeaders,
        interceptor: RequestInterceptor?
    ) -> AnyPublisher<Response, APIClientError>
    
    func uploadMultipart<Response: Decodable>(
        path: String,
        parameters: [String: String],
        imageData: Data,
        imageKey: String,
        imageName: String,
        mimeType: String,
        headers: HTTPHeaders,
        interceptor: RequestInterceptor?
    ) -> AnyPublisher<Response, APIClientError>
    
    /// 챌린지 생성용 - JSON 데이터 + 다중 이미지
    func uploadChallengeMultipart<Request: Encodable, Response: Decodable>(
        path: String,
        data: Request,
        infoImages: [Data],
        certImages: [Data],
        headers: HTTPHeaders,
        interceptor: RequestInterceptor?
    ) -> AnyPublisher<Response, APIClientError>
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
    
    // MARK: - Public
    public func request<Response: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        headers: HTTPHeaders = APIClient.defaultHeaders,
        interceptor: RequestInterceptor? = nil
    ) -> AnyPublisher<Response, APIClientError> {
        guard let url = makeURL(from: path) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return Future<Response, APIClientError> { promise in
            self.session.request(
                url,
                method: method,
                headers: headers,
                interceptor: interceptor
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Response.self) { response in
                self.handle(response: response, path: path, promise: promise)
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func request<Request: Encodable, Response: Decodable>(
        path: String,
        method: HTTPMethod = .post,
        body: Request,
        encoder: ParameterEncoder = JSONParameterEncoder.default,
        headers: HTTPHeaders = APIClient.jsonHeaders,
        interceptor: RequestInterceptor? = nil
    ) -> AnyPublisher<Response, APIClientError> {
        guard let url = makeURL(from: path) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return Future<Response, APIClientError> { promise in
            self.session.request(
                url,
                method: method,
                parameters: body,
                encoder: encoder,
                headers: headers,
                interceptor: interceptor
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Response.self) { response in
                self.handle(response: response, path: path, promise: promise)
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func uploadMultipart<Response: Decodable>(
        path: String,
        parameters: [String: String] = [:],
        imageData: Data,
        imageKey: String = "feedImage",
        imageName: String = "image.jpg",
        mimeType: String = "image/jpeg",
        headers: HTTPHeaders = APIClient.defaultHeaders,
        interceptor: RequestInterceptor? = nil
    ) -> AnyPublisher<Response, APIClientError> {
        guard let url = makeURL(from: path) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return Future<Response, APIClientError> { promise in
            self.session.upload(
                multipartFormData: { formData in
                    // Add parameters
                    for (key, value) in parameters {
                        if let data = value.data(using: .utf8) {
                            formData.append(data, withName: key)
                        }
                    }
                    
                    // Add image
                    formData.append(
                        imageData,
                        withName: imageKey,
                        fileName: imageName,
                        mimeType: mimeType
                    )
                },
                to: url,
                method: .post,
                headers: headers,
                interceptor: interceptor
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Response.self) { response in
                self.handle(response: response, path: path, promise: promise)
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 챌린지 생성용 - JSON 데이터 + 다중 이미지
    public func uploadChallengeMultipart<Request: Encodable, Response: Decodable>(
        path: String,
        data: Request,
        infoImages: [Data],
        certImages: [Data],
        headers: HTTPHeaders = APIClient.defaultHeaders,
        interceptor: RequestInterceptor? = nil
    ) -> AnyPublisher<Response, APIClientError> {
        guard let url = makeURL(from: path) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        // JSON 데이터를 문자열로 변환
        guard let jsonData = try? JSONEncoder().encode(data),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return Fail(error: .decoding("Failed to encode request data", nil)).eraseToAnyPublisher()
        }
        
        #if DEBUG
        print("🎯 Challenge multipart request:")
        print("   data: \(jsonString)")
        print("   infoImages: \(infoImages.count)개")
        print("   certImages: \(certImages.count)개")
        #endif
        
        return Future<Response, APIClientError> { promise in
            self.session.upload(
                multipartFormData: { formData in
                    // JSON 데이터 추가
                    if let data = jsonString.data(using: .utf8) {
                        formData.append(data, withName: "data", mimeType: "application/json")
                    }
                    
                    // 대표 이미지들 추가
                    for (index, imageData) in infoImages.enumerated() {
                        formData.append(
                            imageData,
                            withName: "infoImages",
                            fileName: "info_\(index).jpg",
                            mimeType: "image/jpeg"
                        )
                    }
                    
                    // 인증샘플 이미지들 추가
                    for (index, imageData) in certImages.enumerated() {
                        formData.append(
                            imageData,
                            withName: "certImages",
                            fileName: "cert_\(index).jpg",
                            mimeType: "image/jpeg"
                        )
                    }
                },
                to: url,
                method: .post,
                headers: headers,
                interceptor: interceptor
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Response.self) { response in
                self.handle(response: response, path: path, promise: promise)
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private helpers
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
        // 절대 URL인 경우 그대로 반환
        if let absolute = URL(string: path), absolute.scheme != nil {
            return absolute
        }
        
        // 상대 경로 처리 (query string 포함 가능)
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        
        // appendingPathComponent는 ?를 인코딩하므로 문자열로 직접 조합
        let urlString = "\(baseURL.absoluteString)/\(cleanPath)"
        return URL(string: urlString)
    }
    
    private func handle<Response: Decodable>(
        response: AFDataResponse<Response>,
        path: String,
        promise: @escaping (Result<Response, APIClientError>) -> Void
    ) {
        #if DEBUG
        let statusCode = response.response?.statusCode ?? 0
        let debugBody = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "<empty>"
        if let error = response.error {
            print("🌐 [\(path)] failure [\(statusCode)]: \(error)")
            print("🌐 body: \(debugBody)")
        } else {
            print("🌐 [\(path)] success [\(statusCode)]: \(debugBody)")
        }
        #endif
        
        switch response.result {
        case .success(let value):
            promise(.success(value))
        case .failure(let error):
            if let statusCode = response.response?.statusCode {
                promise(.failure(.http(statusCode: statusCode, data: response.data)))
            } else if error.isResponseSerializationError {
                promise(.failure(.decoding(error.localizedDescription, response.data)))
            } else {
                promise(.failure(.network(error)))
            }
        }
    }
    
    public static let jsonHeaders: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    
    public static let defaultHeaders: HTTPHeaders = [
        "Accept": "application/json"
    ]
}

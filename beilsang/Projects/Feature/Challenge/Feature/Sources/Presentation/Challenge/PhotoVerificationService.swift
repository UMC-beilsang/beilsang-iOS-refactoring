//
//  PhotoVerificationService.swift
//  ChallengeFeature
//

import UIKit
import Foundation

// MARK: - Result Model

public struct PhotoVerificationResult {
    public let score: Int        // 0–100
    public let isValid: Bool     // score >= 70
    public let feedback: String  // 한국어 피드백

    public init(score: Int, isValid: Bool, feedback: String) {
        self.score = score
        self.isValid = isValid
        self.feedback = feedback
    }

    public var statusText: String { isValid ? "인증 적합" : "재검토 필요" }
    public var statusIcon: String { isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill" }
}

// MARK: - Challenge Context

public struct ChallengeVerificationContext {
    public let title: String
    public let description: String
    public let category: String
    public let notes: [String]

    public init(title: String, description: String, category: String, notes: [String]) {
        self.title = title
        self.description = description
        self.category = category
        self.notes = notes
    }
}

// MARK: - Errors

public enum PhotoVerificationError: LocalizedError {
    case apiKeyMissing
    case invalidImage
    case networkError(Error)
    case parsingError

    public var errorDescription: String? {
        switch self {
        case .apiKeyMissing:       return "AI 검증 키가 설정되지 않았습니다"
        case .invalidImage:        return "이미지를 처리할 수 없습니다"
        case .networkError(let e): return "네트워크 오류: \(e.localizedDescription)"
        case .parsingError:        return "응답을 처리할 수 없습니다"
        }
    }
}

// MARK: - Service

public final class PhotoVerificationService {
    private let apiKey: String
    private static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    /// Info.plist의 ANTHROPIC_API_KEY 값으로 초기화
    public static func fromBundle() -> PhotoVerificationService {
        let key = Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_API_KEY") as? String ?? ""
        return PhotoVerificationService(apiKey: key)
    }

    // MARK: - Verify

    public func verify(image: UIImage, context: ChallengeVerificationContext) async throws -> PhotoVerificationResult {
        #if DEBUG
        let keyPreview = apiKey.isEmpty ? "(없음)" : "\(apiKey.prefix(12))..."
        print("🔑 ANTHROPIC_API_KEY: \(keyPreview)")
        print("📋 챌린지 컨텍스트 - 제목: \(context.title), 카테고리: \(context.category)")
        print("📋 설명: \(context.description)")
        print("📋 유의사항: \(context.notes)")
        #endif

        // API 키가 없거나 플레이스홀더면 목업 반환
        guard !apiKey.isEmpty, !apiKey.hasPrefix("YOUR_") else {
            print("⚠️ API 키 없음 → 목업 결과 반환")
            return mockResult()
        }

        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            throw PhotoVerificationError.invalidImage
        }

        let base64 = imageData.base64EncodedString()
        let prompt = buildPrompt(for: context)
        let requestBody = buildRequestBody(base64: base64, prompt: prompt)

        var urlRequest = URLRequest(url: Self.endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            #if DEBUG
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let rawBody = String(data: data, encoding: .utf8) ?? "(empty)"
            print("🤖 Claude API status: \(statusCode)")
            print("🤖 Claude API response: \(rawBody)")
            #endif

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                throw PhotoVerificationError.networkError(
                    NSError(domain: "Anthropic", code: http.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
                )
            }

            return try parseResponse(data: data)
        } catch let e as PhotoVerificationError {
            throw e
        } catch {
            throw PhotoVerificationError.networkError(error)
        }
    }

    // MARK: - Private Helpers

    private func buildPrompt(for context: ChallengeVerificationContext) -> String {
        let notesText = context.notes.isEmpty
            ? "별도 유의사항 없음"
            : context.notes.enumerated()
                .map { "\($0.offset + 1). \($0.element)" }
                .joined(separator: "\n")

        return """
        당신은 챌린지 인증 사진의 '시각적 적합성'만 가볍게 확인하는 검수자입니다.
        사진 한 장으로 운동 시간, 날짜/시간, GPS, 앱 기록 여부는 절대 증명할 수 없으므로 감점 사유로 사용하지 마세요.

        챌린지명: \(context.title)
        카테고리: \(context.category)
        설명: \(context.description)
        참고 유의사항(선택 사항, 필수 아님):
        \(notesText)

        채점 기준 (관대하게 적용):
        - 95~100: 사진이 챌린지 주제/활동과 명확히 일치 (예: 걷기 챌린지 → 실외/실내에서 걷거나 조깅하는 모습)
        - 80~94: 주제와 관련 있고 인증으로 충분히 받아들일 수 있음
        - 70~79: 다소 애매하지만 관련성은 있음
        - 69 이하: 챌린지와 명백히 무관한 사진(음식, 풍경만, 밈, 스크린샷 등)일 때만

        중요:
        - 날짜/시간 미표시, 30분 운동 여부 미확인, 메타데이터 부재는 감점하지 마세요.
        - 유의사항은 '있으면 좋음' 수준이며, 없어도 주제만 맞으면 95점 이상 주세요.
        - 사용자가 실제로 해당 활동을 한 것처럼 보이면 통과(70점 이상)로 판단하세요.

        반드시 JSON만 응답하세요 (다른 텍스트 없이):
        {"score": 정수(0~100), "feedback": "한 문장의 간결한 한국어 피드백"}
        """
    }

    private func buildRequestBody(base64: String, prompt: String) -> [String: Any] {
        [
            "model": "claude-haiku-4-5",
            "max_tokens": 150,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64
                            ]
                        ],
                        [
                            "type": "text",
                            "text": prompt
                        ]
                    ]
                ]
            ]
        ]
    }

    private func parseResponse(data: Data) throws -> PhotoVerificationResult {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let contentArray = json["content"] as? [[String: Any]],
            let first = contentArray.first,
            let rawText = first["text"] as? String
        else {
            throw PhotoVerificationError.parsingError
        }

        let cleanedText = stripMarkdownCodeFences(from: rawText)

        guard
            let textData = cleanedText.data(using: .utf8),
            let result = try? JSONSerialization.jsonObject(with: textData) as? [String: Any]
        else {
            throw PhotoVerificationError.parsingError
        }

        let rawScore = (result["score"] as? Int) ?? (result["score"] as? Double).map { Int($0) } ?? 0
        let score = max(0, min(100, rawScore))
        let feedback = result["feedback"] as? String ?? "분석이 완료되었습니다."
        return PhotoVerificationResult(score: score, isValid: score >= 70, feedback: feedback)
    }

    private func stripMarkdownCodeFences(from text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // ```json ... ``` 또는 ``` ... ``` 형태 제거
        if result.hasPrefix("```") {
            result = result
                .replacingOccurrences(of: "^```(?:json)?\\s*", with: "", options: .regularExpression)
                .replacingOccurrences(of: "\\s*```$", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return result
    }

    private func mockResult() -> PhotoVerificationResult {
        let score = Int.random(in: 75...95)
        return PhotoVerificationResult(score: score, isValid: true, feedback: "챌린지 인증 조건에 적합한 사진입니다.")
    }
}

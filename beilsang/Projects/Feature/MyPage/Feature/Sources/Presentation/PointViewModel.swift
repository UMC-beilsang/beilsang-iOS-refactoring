//
//  PointViewModel.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/30/25.
//

import Foundation
import Combine
import ModelsShared
import UserDomain
import UtilityShared

@MainActor
public final class PointViewModel: ObservableObject {
    // MARK: - Published
    @Published public var totalPoint: Int = 0
    @Published public var points: [PointItem] = []
    @Published public var isLoading: Bool = true
    @Published public var errorMessage: String?
    @Published public var isInitialLoading: Bool = true
    
    // MARK: - Dependencies
    private let fetchPointsUseCase: FetchPointsUseCaseProtocol
    
    // MARK: - Init
    public init(fetchPointsUseCase: FetchPointsUseCaseProtocol) {
        self.fetchPointsUseCase = fetchPointsUseCase
    }
    
    // MARK: - Fetch Points
    public func fetchPoints(showSkeleton: Bool = false) async {
        if showSkeleton {
            isInitialLoading = true
        }
        
        isLoading = true
        errorMessage = nil
        
        let shouldDelay = showSkeleton && MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        } : nil
        
        do {
            let data = try await fetchPointsUseCase.execute()
            
            if let delay = delayTask {
                await delay.value
            }
            
            totalPoint = data.total
            points = data.points
            #if DEBUG
            print("💰 Loaded \(points.count) point items, total: \(totalPoint)")
            #endif
        } catch {
            if let delay = delayTask {
                await delay.value
            }
            errorMessage = "포인트 내역을 불러오는 데 실패했습니다."
            print("❌ Error fetching points: \(error)")
        }
        
        isLoading = false
        
        if showSkeleton {
            isInitialLoading = false
        }
    }
    
    // MARK: - Filtered Points
    public func filteredPoints(by tabIndex: Int) -> [PointItem] {
        switch tabIndex {
        case 0: // 전체
            return points
        case 1: // 적립
            return points.filter { $0.status == .earn }
        case 2: // 사용
            return points.filter { $0.status == .use }
        case 3: // 소멸
            return points.filter { $0.status == .expire }
        default:
            return points
        }
    }
    
    // MARK: - Expiring Points
    public var expiringPoints: Int {
        // period가 0보다 크고 작은 값들을 합산 (소멸 예정)
        return points
            .filter { $0.status == .earn && $0.period > 0 && $0.period <= 30 }
            .reduce(0) { $0 + $1.value }
    }
    
    // MARK: - Format Helpers
    public func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    public func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yy.MM.dd"
        return displayFormatter.string(from: date)
    }
    
    public func formatExpiryDate(_ dateString: String, period: Int) -> String? {
        guard period > 0 else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return nil
        }
        
        let expiryDate = Calendar.current.date(byAdding: .day, value: period, to: date) ?? date
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yy.MM.dd"
        return displayFormatter.string(from: expiryDate)
    }
}




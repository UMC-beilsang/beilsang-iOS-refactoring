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

@MainActor
public final class PointViewModel: ObservableObject {
    @Published public var totalPoint: Int = 0
    @Published public var point: [PointItem] = []
    @Published public var isLoading: Bool = true
    @Published public var errorMessage: String?
    @Published public var isInitialLoading: Bool = true
    
    private let fetchPointsUseCase: FetchPointsUseCaseProtocol
    
    public init(fetchPointsUseCase: FetchPointsUseCaseProtocol) {
        self.fetchPointsUseCase = fetchPointsUseCase
    }
    
    public func fetchPoints(showSkeleton: Bool = false) async {
        if showSkeleton {
            isInitialLoading = true
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await fetchPointsUseCase.execute()
            
            totalPoint = data.total
            point = data.point
            #if DEBUG
            print("💰 Loaded \(point.count) point items, total: \(totalPoint)")
            #endif
        } catch {
            errorMessage = "포인트 내역을 불러오는 데 실패했습니다."
            print("❌ Error fetching points: \(error)")
        }
        
        isLoading = false
        
        if showSkeleton {
            isInitialLoading = false
        }
    }
    
    public func filteredPoints(by tabIndex: Int) -> [PointItem] {
        switch tabIndex {
        case 0:
            return point
        case 1:
            return point.filter { $0.status == .earn }
        case 2:
            return point.filter { $0.status == .use }
        case 3:
            return point.filter { $0.status == .expire }
        default:
            return point
        }
    }
    
    public var expiringPoints: Int {
        return point
            .filter {
                guard $0.status == .earn, let period = $0.period else { return false }
                return period > 0 && period <= 30
            }
            .reduce(0) { $0 + $1.value }
    }
    
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
    
    public func formatExpiryDate(_ dateString: String, period: Int?) -> String? {
        guard let period, period > 0 else { return nil }
        
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

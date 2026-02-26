import XCTest
@testable import ChallengeFeature
import ModelsShared
import ChallengeDomain

final class ChallengeDetailViewModelTests: XCTestCase {
    var sut: ChallengeDetailViewModel!
    var mockRepository: MockChallengeRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockChallengeRepository()
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - 초기화 테스트
    
    func test_초기화_성공() {
        // Given
        let challenge = Challenge.mock()
        
        // When
        sut = ChallengeDetailViewModel(challenge: challenge, repository: mockRepository)
        
        // Then
        XCTAssertEqual(sut.title, "테스트 챌린지")
        XCTAssertFalse(sut.showingPopup)
        XCTAssertEqual(sut.depositAmount, 1000)
    }
    
    func test_초기화_미참여상태() {
        // Given
        let challenge = Challenge.mock(
            status: "RECRUITING",
            isParticipating: false
        )
        
        // When
        sut = ChallengeDetailViewModel(challenge: challenge, repository: mockRepository)
        
        // Then
        if case .notEnrolled(.canApply) = sut.state {
            // 성공
        } else {
            XCTFail("Expected .notEnrolled(.canApply), got \(sut.state)")
        }
    }
    
    func test_초기화_참여중상태() {
        // Given
        let challenge = Challenge.mock(
            status: "IN_PROGRESS",
            isParticipating: true
        )
        
        // When
        sut = ChallengeDetailViewModel(challenge: challenge, repository: mockRepository)
        
        // Then
        if case .enrolled(.inProgress(_)) = sut.state {
            // 성공
        } else {
            XCTFail("Expected .enrolled(.inProgress), got \(sut.state)")
        }
    }
    
    // MARK: - 팝업 테스트
    
    func test_참여버튼_포인트충분_참여팝업표시() {
        // Given
        let challenge = Challenge.mock(depositAmount: 1000)
        sut = ChallengeDetailViewModel(challenge: challenge, repository: mockRepository)
        sut.userPoint = 2000 // 충분한 포인트
        
        // When
        sut.handleMainAction()
        
        // Then
        XCTAssertTrue(sut.showingPopup)
        if case .participate(let required, let current, _) = sut.currentPopupType {
            XCTAssertEqual(required, 1000)
            XCTAssertEqual(current, 2000)
        } else {
            XCTFail("Expected .participate popup")
        }
    }
    
    func test_참여버튼_포인트부족_부족팝업표시() {
        // Given
        let challenge = Challenge.mock(depositAmount: 2000)
        sut = ChallengeDetailViewModel(challenge: challenge, repository: mockRepository)
        sut.userPoint = 1000 // 부족한 포인트
        
        // When
        sut.handleMainAction()
        
        // Then
        XCTAssertTrue(sut.showingPopup)
        if case .insufficientPoint(let required, let current) = sut.currentPopupType {
            XCTAssertEqual(required, 2000)
            XCTAssertEqual(current, 1000)
        } else {
            XCTFail("Expected .insufficientPoint popup")
        }
    }
    
    func test_신고버튼_신고팝업표시() {
        // Given
        let challenge = Challenge.mock()
        sut = ChallengeDetailViewModel(challenge: challenge, repository: mockRepository)
        
        // When
        sut.showReportPopup()
        
        // Then
        XCTAssertTrue(sut.showingPopup)
        if case .report = sut.currentPopupType {
            // 성공
        } else {
            XCTFail("Expected .report popup")
        }
    }
    
    func test_팝업닫기() {
        // Given
        let challenge = Challenge.mock()
        sut = ChallengeDetailViewModel(challenge: challenge, repository: mockRepository)
        sut.showingPopup = true
        sut.currentPopupType = .report
        
        // When
        sut.dismissPopup()
        
        // Then
        XCTAssertFalse(sut.showingPopup)
        XCTAssertNil(sut.currentPopupType)
    }
}

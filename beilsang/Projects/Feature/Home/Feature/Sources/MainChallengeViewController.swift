//
//  MainChallengeViewController.swift
//  beilsang
//
//  Created by Seyoung on 6/6/24.
//

import UIKit
import SnapKit
import Kingfisher

// [홈] 메인화면
class MainChallengeViewController: UIViewController {
    
    // MARK: - properties
    var challengeRecommendData : [ChallengeRecommendsData] = []
    var challengeJoinData : [ChallengeJoinTwoData] = []
    
    // 참여중인 챌린지
    lazy var participatingChallengeLabel: UILabel = {
        let view = UILabel()
        
        view.text = "참여 중인 챌린지"
        view.textAlignment = .left
        view.textColor = .beTextDef
        view.font = UIFont(name: "NotoSansKR-Medium", size: 18)
        
        return view
    }()
    
    // 참여중인 챌린지가 없는 경우
    lazy var notParticipatingLabel: UILabel = {
        let view = UILabel()
        
        view.text = "아직 참여중인 챌린지가 없어요👀"
        view.textAlignment = .center
        view.textColor = .beTextInfo
        view.font = UIFont(name: "Noto Sans KR", size: 12)
        
        return view
    }()
    
    lazy var participateChallengeButton: UIButton = {
        let view = UIButton()
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.beBgDiv.cgColor
        view.setTitle("챌린지 참여하러 가기", for: .normal)
        view.setTitleColor(.beTextDef, for: .normal)
        view.titleLabel?.font = UIFont(name: "Noto Sans KR", size: 14)
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 20
        view.addTarget(self, action: #selector(challengeButtonClicked), for: .touchUpInside)
        
        return view
    }()
    
    // 참여 중인 챌린지가 있는 경우
    lazy var viewAllButton: UIButton = {
        let view = UIButton()
        
        view.backgroundColor = .beBgSub
        view.setTitle("전체 보기", for: .normal)
        view.setTitleColor(.beNavy500, for: .normal)
        view.titleLabel?.font = UIFont(name: "Noto Sans KR", size: 12)
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 10
        view.addTarget(self, action: #selector(viewAllButtonClicked), for: .touchUpInside)
        
        return view
    }()
    
    lazy var challengeParticipatingCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    //추천 챌린지
    lazy var recommendChallengeLabel: UILabel = {
        let view = UILabel()
        
        view.text = "당신을 위해 준비한 챌린지"
        view.textAlignment = .left
        view.textColor = .beTextDef
        view.font = UIFont(name: "NotoSansKR-Medium", size: 18)
        
        return view
    }()
    
    //추천 챌린지가 있는 경우
    lazy var challengeRecommendCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    //추천 챌린지가 없는 경우
    lazy var notRecommendChallengeLabel: UILabel = {
        let view = UILabel()
        
        view.text = "아직 추천할 수 있는 챌린지가 없어요 👀"
        view.textAlignment = .center
        view.textColor = .beTextInfo
        view.font = UIFont(name: "Noto Sans KR", size: 12)
        
        return view
    }()
    
    lazy var joinChallengeButton: UIButton = {
        let view = UIButton()
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.beBgDiv.cgColor
        view.setTitle("챌린지 만들러 가기", for: .normal)
        view.setTitleColor(.beTextDef, for: .normal)
        view.titleLabel?.font = UIFont(name: "Noto Sans KR", size: 14)
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 20
        view.addTarget(self, action: #selector(challengeButtonClicked), for: .touchUpInside)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBasicLayout()
        challengeJoin(){
            count in
            if count == 0 {
                self.setNoChallengeViewLayout()
            } else {
                self.setChallengeViewLayout()
            }
        }
        challengeRecommend { count in
            if count == 0 {
                self.setNoRecommendChallengeViewLayout()
            } else {
                self.setRecommendChallengeViewLayout()
            }
        }
        
        setCollectionView()
    }
    
    // MARK: - actions
    @objc func challengeButtonClicked() {
        print("챌린지 참여하러 가기")
        
        let labelText = "전체"
        let challengeListVC = ChallengeListViewController()
        challengeListVC.categoryLabelText = labelText
        challengeListVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(challengeListVC, animated: true)
    }
    
    @objc func viewAllButtonClicked() {
        print("전체 보기")
        
        let labelText = "참여중"
        let challengeListVC = ChallengeListViewController()
        challengeListVC.categoryLabelText = labelText
        challengeListVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(challengeListVC, animated: true)
    }
}

// MARK: - Layout setting
extension MainChallengeViewController {
    // 기본
    func setBasicLayout() {
        view.addSubview(participatingChallengeLabel)
        view.addSubview(recommendChallengeLabel)
        
        participatingChallengeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        recommendChallengeLabel.snp.makeConstraints{ make in
            make.top.equalTo(participatingChallengeLabel.snp.bottom).offset(180)
            make.leading.equalToSuperview().offset(16)
        }
    }
    
    //참여중인 챌린지가 없는 경우
    func setNoChallengeViewLayout(){
        view.addSubview(notParticipatingLabel)
        view.addSubview(participateChallengeButton)

        notParticipatingLabel.snp.makeConstraints { make in
            make.top.equalTo(participatingChallengeLabel.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
        }
        
        participateChallengeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(notParticipatingLabel.snp.bottom).offset(12)
            make.width.equalTo(240)
            make.height.equalTo(40)
        }
    }
    
    //참여중인 챌린지가 있는 경우
    func setChallengeViewLayout() {
        view.addSubview(viewAllButton)
        view.addSubview(challengeParticipatingCollectionView)
        
        viewAllButton.snp.makeConstraints { make in
            make.centerY.equalTo(participatingChallengeLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(70)
            make.height.equalTo(21)
        }
        
        challengeParticipatingCollectionView.snp.makeConstraints { make in
            make.top.equalTo(participatingChallengeLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(140)
        }
    }
    
    //추천 챌린지가 없는 경우
    func setNoRecommendChallengeViewLayout(){
        view.addSubview(notRecommendChallengeLabel)
        view.addSubview(joinChallengeButton)

        notRecommendChallengeLabel.snp.makeConstraints { make in
            make.top.equalTo(recommendChallengeLabel.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
        }
        
        joinChallengeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(notRecommendChallengeLabel.snp.bottom).offset(12)
            make.width.equalTo(240)
            make.height.equalTo(40)
        }
    }
    
    //추천 챌린지가 있는 경우
    func setRecommendChallengeViewLayout() {
        view.addSubview(challengeRecommendCollectionView)
        
        challengeRecommendCollectionView.snp.makeConstraints { make in
            make.top.equalTo(recommendChallengeLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(140)
        }
    }
}

// MARK: - 참여중 챌린지, 추천 챌린지 api 세팅
extension MainChallengeViewController {
    func challengeRecommend(completion: @escaping (Int) -> Void) {
        var completionNumber: Int = 0
        ChallengeService.shared.challengeRecommend() { response in
            // 성공적으로 데이터를 받아왔을 때
            if let challenges = response.data?.recommendChallengeDTOList {
                self.setRecommendData(challenges)
                print(challenges)
                completionNumber = challenges.count
            } else {
                completionNumber = 0
            }
        }
        completion(completionNumber)
    }

    @MainActor
    private func setRecommendData(_ response: [ChallengeRecommendsData]) {
        self.challengeRecommendData = response
        self.challengeRecommendCollectionView.reloadData()
    }
    
    func challengeJoin(completion: @escaping (Int) -> Void) {
        ChallengeService.shared.challengeJoinTwo() { response in
            guard let challenges = response.data?.challenges else {
                completion(0) // 데이터가 없을 경우 0을 반환
                return
            }
            self.setJoinData(challenges)
            print(response)
            completion(challenges.count) // 챌린지의 개수를 콜백을 통해 반환
        }
    }
    
    @MainActor
    private func setJoinData(_ response: [ChallengeJoinTwoData]) {
        self.challengeJoinData = response
        self.challengeParticipatingCollectionView.reloadData()
    }
}

// MARK: - collectionView setting(챌린지 리스트)
extension MainChallengeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // 콜렉션뷰 세팅
    func setCollectionView() {
        challengeParticipatingCollectionView.delegate = self
        challengeParticipatingCollectionView.dataSource = self
        challengeParticipatingCollectionView.register(MainAfterCollectionViewCell.self, forCellWithReuseIdentifier: MainAfterCollectionViewCell.identifier)
        
        challengeRecommendCollectionView.delegate = self
        challengeRecommendCollectionView.dataSource = self
        challengeRecommendCollectionView.register(MainAfterCollectionViewCell.self, forCellWithReuseIdentifier: MainAfterCollectionViewCell.identifier)
    }
    
    // 셀 개수 설정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case challengeParticipatingCollectionView :
            return challengeJoinData.count
        case challengeRecommendCollectionView :
            return challengeRecommendData.count
        default:
            return 2
        }
    }
    
    // 셀 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case challengeParticipatingCollectionView :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainAfterCollectionViewCell.identifier, for: indexPath) as?
                    MainAfterCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.mainAfterChallengeId = challengeJoinData[indexPath.row].challengeId
            
            let url = URL(string: challengeJoinData[indexPath.row].imageUrl!)
            cell.challengeImage.kf.setImage(with: url)
            cell.challengeNameLabel.text = challengeJoinData[indexPath.row].title
            let achieve = challengeJoinData[indexPath.row].achieveRate
            cell.buttonLabel.text = "달성률 \(achieve)%"
            
            return cell
        case challengeRecommendCollectionView :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainAfterCollectionViewCell.identifier, for: indexPath) as?
                    MainAfterCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.mainAfterChallengeId = challengeRecommendData[indexPath.row].challengeId
            
            let url = URL(string: challengeRecommendData[indexPath.row].imageUrl!)
            cell.challengeImage.kf.setImage(with: url)
            cell.challengeNameLabel.text = challengeRecommendData[indexPath.row].title
            let categoryName = CategoryConverter.shared.convertToKorean(challengeRecommendData[indexPath.row].category)
            cell.buttonLabel.text = "참여인원 \(challengeRecommendData[indexPath.row].attendeeCount)명"
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 44) / 2
        
        return CGSize(width: width , height: 140)
    }
    
    // 셀 선택시 액션
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainAfterCollectionViewCell
        let challengeId = cell.mainAfterChallengeId
        
        if collectionView == challengeParticipatingCollectionView {
            let nextVC = JoinChallengeViewController()
            nextVC.joinChallengeId = challengeId
            nextVC.hidesBottomBarWhenPushed = true
            hideBottomBarAndPushViewController(nextVC)
        } else {
            let nextVC = ChallengeDetailViewController()
            nextVC.detailChallengeId = challengeId
            nextVC.hidesBottomBarWhenPushed = true
            hideBottomBarAndPushViewController(nextVC)
        }
    }

    private func hideBottomBarAndPushViewController(_ viewController: UIViewController) {
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}


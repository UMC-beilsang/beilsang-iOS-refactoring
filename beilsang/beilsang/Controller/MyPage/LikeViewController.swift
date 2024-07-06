//
//  LikeViewController.swift
//  beilsang
//
//  Created by 강희진 on 2/1/24.
//

import UIKit
import Kingfisher

class LikeViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Properties
    
    // 전체 화면 scrollview
    let fullScrollView = UIScrollView()
    let fullContentView = UIView()
    
    var selectedCategory = "다회용컵" //0:다회용컵, ..., 8: 재활용
    
    var cellList : [ChallengeModel] = []
    var likeList = [[ChallengeModel]](repeating: Array(), count: 9)
    //메뉴 하단 회색 바
    lazy var menuUnderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgDiv
        return view
    }()
    
    // categoriesView - 셀
    let categoryDataList = CategoryKeyword.data[1...]
    lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 72, height: 72)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return view
    }()
    
    lazy var categoryUnderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .beBgSub
        return view
    }()
    lazy var challengeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansKR-Medium", size: 16)
        label.textColor = .black
        label.text = "다회용기 챌린지"
        return label
    }()
    
    lazy var challengeBoxCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.makeFlowLayout())
        return view
    }()

    // 찜한 챌린지가 없는 경우 
    lazy var notLikeLabel: UILabel = {
        let view = UILabel()
        
        view.text = "아직 찜한 챌린지가 없어요👀"
        view.textAlignment = .center
        view.textColor = .beTextInfo
        view.font = UIFont(name: "Noto Sans KR", size: 12)
        
        return view
    }()
    
    lazy var likeChallengeButton: UIButton = {
        let view = UIButton()
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.beBgDiv.cgColor
        view.setTitle("챌린지 찜하러 가기", for: .normal)
        view.setTitleColor(.beTextDef, for: .normal)
        view.titleLabel?.font = UIFont(name: "Noto Sans KR", size: 14)
        view.contentHorizontalAlignment = .center
        view.layer.cornerRadius = 20
        view.addTarget(self, action: #selector(challengeButtonClicked), for: .touchUpInside)
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        request()
        setupAttribute()
        setCollectionView()
        setNavigationBar()
        viewConstraint()
    }

}
extension LikeViewController {
    
    func request() {
        MyPageService.shared.getChallengeList(baseEndPoint: .challenges, addPath: "/likes/\(selectedCategory)") { response in
            self.setFirstFeedList(response.data.challenges ?? [])
            let requestList = response.data.challenges ?? []
            if requestList.isEmpty {
                self.notLikeLabel.isHidden = false
                self.likeChallengeButton.isHidden = false
                self.challengeBoxCollectionView.isHidden = true
                self.setNoChallengeViewLayout()
            }
            else {
                self.notLikeLabel.isHidden = true
                self.likeChallengeButton.isHidden = true
                self.challengeBoxCollectionView.isHidden = false
            }
        }
    }
    @MainActor
    private func setFirstFeedList(_ response: [ChallengeModel]){
        self.likeList[changeCategoryToInt(category: selectedCategory)-1] = response
        self.cellList = response
        challengeBoxCollectionView.reloadData()
    }
    
    func setupAttribute() {
        setFullScrollView()
        setLayout()
        setScrollViewLayout()
    }
    
    func setFullScrollView() {
        fullScrollView.delegate = self
        //스크롤 안움직이게 설정
        fullScrollView.isScrollEnabled = false
        //스크롤 안보이게 설정
        fullScrollView.showsVerticalScrollIndicator = false
    }
    
    func setLayout() {
        view.addSubview(fullScrollView)
        fullScrollView.addSubview(fullContentView)
        addView()
    }
    func setScrollViewLayout(){
        fullScrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        fullContentView.snp.makeConstraints { make in
            make.edges.equalTo(fullScrollView.contentLayoutGuide)
            make.width.equalTo(fullScrollView.frameLayoutGuide)
            make.height.equalTo(1056)
        }
    }
    // addSubview() 메서드 모음
    func addView() {
        // foreach문을 사용해서 클로저 형태로 작성
        [categoryCollectionView, categoryUnderLine, challengeLabel, challengeBoxCollectionView].forEach{ view in fullContentView.addSubview(view)}
        
    }
    
    //snp 설정
    func viewConstraint(){
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(72)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        categoryUnderLine.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(8)
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(24)
            make.leading.equalToSuperview()
        }
        challengeLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryUnderLine.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(16)
        }
        challengeBoxCollectionView.snp.makeConstraints { make in
            make.top.equalTo(challengeLabel.snp.bottom).offset(12)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    func setNoChallengeViewLayout(){
        view.addSubview(notLikeLabel)
        view.addSubview(likeChallengeButton)

        notLikeLabel.snp.makeConstraints { make in
            make.top.equalTo(challengeLabel.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
        }
        
        likeChallengeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(notLikeLabel.snp.bottom).offset(12)
            make.width.equalTo(240)
            make.height.equalTo(40)
        }
    }
}
// MARK: - 네비게이션 바 커스텀
extension LikeViewController{
    private func setNavigationBar() {
        self.navigationItem.titleView = attributeTitleView()
        
        // 백 버튼 설정
        setBackButton()
    }
    private func attributeTitleView() -> UIView {
        // title 설정
        let label = UILabel()
        let lightText: NSMutableAttributedString =
            NSMutableAttributedString(string: "찜",attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "NotoSansKR-SemiBold", size: 20)!])
        let naviTitle: NSMutableAttributedString
            = lightText
        label.attributedText = naviTitle
          
        return label
    }
    // 백버튼 커스텀
    func setBackButton() {
        let leftBarButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-navigation")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(tabBarButtonTapped))
        leftBarButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    // 백버튼 액션
    @objc func tabBarButtonTapped() {
        print("뒤로 가기")
        navigationController?.popViewController(animated: true)
    }
    
    @objc func challengeButtonClicked() {
        print("챌린지 참여하러 가기")
        
        let labelText = "전체"
        let challengeListVC = ChallengeListViewController()
        challengeListVC.categoryLabelText = labelText
        challengeListVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(challengeListVC, animated: true)
    }
}
// MARK: - collectionView setting(카테고리)
extension LikeViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    // collectionView, delegate, datasorce 설정
    func setCollectionView() {
        [categoryCollectionView, challengeBoxCollectionView].forEach { view in
            view.delegate = self
            view.dataSource = self
        }
        
        //Cell 등록
        categoryCollectionView.register(MyPageCategoryCollectionViewCell.self, forCellWithReuseIdentifier: MyPageCategoryCollectionViewCell.identifier)
        challengeBoxCollectionView.register(ChallengeListCollectionViewCell.self, forCellWithReuseIdentifier: ChallengeListCollectionViewCell.identifier)
        
        // 컬렉션 뷰 첫 화면 선택
        setFirstIndexIsSelected()
        
        // 스크롤 감추기
        categoryCollectionView.showsHorizontalScrollIndicator = false
    }
    // section 개수 설정
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    // cell 개수 설정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case categoryCollectionView:
            return categoryDataList.count
        case challengeBoxCollectionView:
            return cellList.count
        default:
            return 0
        }
    }
    
    // cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView{
        case categoryCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPageCategoryCollectionViewCell.identifier, for: indexPath) as?
                    MyPageCategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let target = categoryDataList[indexPath.row+1]
            let img = UIImage(named: "\(target.image).svg")
            cell.keywordImage.image = img
            cell.keywordLabel.text = target.title
            
            return cell
        case challengeBoxCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeListCollectionViewCell.identifier, for: indexPath) as?
                    ChallengeListCollectionViewCell else {
                return UICollectionViewCell() }
            let target = cellList[indexPath.row]
            cell.makerNickname.text = target.hostName
            cell.challengeNameLabel.text = target.title
            cell.buttonLabel.text = "참여인원 \(target.attendeeCount)명"
            cell.challengeListChallengeId = target.challengeId
            let url = URL(string: target.imageUrl)
            cell.challengeImage.kf.setImage(with: url)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    // cell 선택시 액션
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView{
        case categoryCollectionView:
            let cell = categoryCollectionView.cellForItem(at: indexPath) as! MyPageCategoryCollectionViewCell
            let txt = cell.keywordLabel.text!
            challengeLabel.text = "\(txt) 챌린지"
            selectedCategory = txt
            request()
        case challengeBoxCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as! ChallengeListCollectionViewCell
            
            let challengeDetailVC = ChallengeDetailViewController()
            challengeDetailVC.detailChallengeId = cell.challengeListChallengeId
            challengeDetailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(challengeDetailVC, animated: true)
        default:
            return
        }
    }
    // collectionCell 첫 화면 설정
    func setFirstIndexIsSelected() {
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        categoryCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom) // 0번째 Index로
    }
    
    // 섹션 별 크기 설정을 위한 함수
    // challengeBoxCollectionView layout 커스텀
    private func makeFlowLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, ev -> NSCollectionLayoutSection? in
            
            makeChallengeSectionLayout()
        }
        func makeChallengeSectionLayout() -> NSCollectionLayoutSection? {
            // item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            /// 아이템들이 들어갈 Group 설정
            /// groupSize 설정
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(148))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 8,
                trailing: 0)
            // section
            let section = NSCollectionLayoutSection(group: group)
//            section.orthogonalScrollingBehavior = .continuous // 섹션 내 가로 스크롤
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 16,
                bottom: 0,
                trailing: 16)
            
            return section
        }
    }
    func changeCategoryToInt(category: String) -> Int{
        switch category{
        case CategoryKeyword.data[0].title: return 0
        case CategoryKeyword.data[1].title: return 1
        case CategoryKeyword.data[2].title: return 2
        case CategoryKeyword.data[3].title: return 3
        case CategoryKeyword.data[4].title: return 4
        case CategoryKeyword.data[5].title: return 5
        case CategoryKeyword.data[6].title: return 6
        case CategoryKeyword.data[7].title: return 7
        case CategoryKeyword.data[8].title: return 8
        case CategoryKeyword.data[9].title: return 9
        default:
            return 0
        }
    }
}

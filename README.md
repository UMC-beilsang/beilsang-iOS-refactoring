
<h1 align="center">
  <br>
  <img width="2048" height="546" alt="banner" src="https://github.com/user-attachments/assets/4ebd1f72-8710-4da1-864b-c5eff7d6d289" />
  <br>
  Beilsang
  <br>
</h1>

<h4 align="center">
  환경 실천을 함께하는 에코 챌린지 플랫폼
</h4>

<div align="center">
  <img src="https://github.com/user-attachments/assets/69993785-fce1-4bcf-97ac-b531868f346a" width="500"/>
</div>

<h5 align="center">
  UIKit → SwiftUI 전면 리팩토링 | Clean Architecture 모듈화
</h5>

<p align="center">
  <a href="#-프로젝트-소개">프로젝트 소개</a> •
  <a href="#-why-refactoring">Why Refactoring</a> •
  <a href="#-solution">Solution</a> •
  <a href="#-results">Results</a> •
  <a href="#-reflection">Reflection</a>
</p>

<div align="center">

| <img src="https://github.com/30isdead.png" width="100px"/><br/>**박세영** | **강희진** | **윤종석** | **최서영** | **고하늘** |
| :---: | :---: | :---: | :---: | :---: |
| `iOS Developer` | `Backend` | `Backend` | `PM` | `Designer` |

</div>

<br>

---

<br>

## 📱 프로젝트 소개

일상에서 실천하는 작은 환경보호(텀블러 사용, 플로깅, 분리수거)를 혼자가 아닌 **함께** 이어갈 수 있도록 돕는 커뮤니티 기반 챌린지 앱입니다.

<div align="center">
  <img src="https://github.com/user-attachments/assets/1a13b69b-f49c-486b-a741-c896e343bedb" width="250"/>
  <img src="https://github.com/user-attachments/assets/d36dbab8-21a2-46d4-83bb-b9f2df6784cf" width="250"/>
  <img src="https://github.com/user-attachments/assets/495eacb0-45bd-488c-a866-8aefb98600e8" width="250"/>
</div>
<div align="center">
  <img src="https://github.com/user-attachments/assets/926cd5bd-c435-4b75-8dba-5cbce99e36b1" width="250"/>
  <img src="https://github.com/user-attachments/assets/7d9e8710-773c-4167-a7d7-9479e40ad241" width="250"/>
</div>

<br>

---

<br>

## 🔍 Why Refactoring?

### 레거시 코드의 3가지 문제

**1. Massive View Controller (29,899 lines)**

```swift
// MyPageViewController.swift (774 lines)
class MyPageViewController: UIViewController {
    // 63개의 lazy var UI 컴포넌트
    lazy var settingButton: UIButton = { ... }()
    
    func request() {
        MyPageService.shared.getMyPage(...) // 네트워크
    }
    
    func collectionView(...) { /* DataSource */ }
    // UI + 네트워크 + 비즈니스 로직 혼재
}
```

**2. Singleton 남용**
- `MyPageService.shared`, `UserDefaults.standard`
- 의존성 추적 불가, Mock 교체 불가

**3. 생산성 저하**
- 작은 UI 수정에도 전체 앱 빌드 (2분+)
- Feature 독립 개발 불가

<br>

---

<br>

## 🎯 Solution

### 1. MVVM + Clean Architecture

```
Feature → Domain → Core
           ↓
        Shared
```

**왜 TCA가 아니라 MVVM + Clean Architecture?**

TCA를 적용해본 경험이 있습니다.  
상태 관리와 일관성 측면에서는 장점이 있었지만,  
이번 프로젝트의 목적은 레거시 구조 정리와 의존성 방향 재정의였습니다.

프로젝트 규모 대비 아키텍처 복잡도가 과해질 수 있다고 판단했고,  
Tuist 기반 모듈화 환경에서 TCA를 함께 적용하는 것 또한 초기 단계에서는 부담이 있었습니다.

따라서 의존성 흐름을 명시적으로 설계할 수 있고  
필요한 수준만 적용 가능한 MVVM + Clean Architecture를 선택했습니다.

---

### 2. 🚀 Tuist Example App - Feature 독립 빌드

```swift
@main
struct AuthExampleApp: App {
    var body: some Scene {
        SignUpView(container: authContainer)
    }
}
```

Feature별 Example App을 구성할 수 있다는 점이 결정적이었습니다.  
초기부터 Tuist를 적용했고, 잘못된 의존 관계가 컴파일 단계에서 차단되는 것을 확인했습니다.

하지만 프로젝트 규모 대비 과도한 모듈화가 되지 않도록  
Feature 경계를 어떻게 설정할지 충분한 고민이 필요했습니다.

**결과:**
- 모듈 간 책임 경계가 분명해졌고
- Feature 독립 실행 환경을 확보했으며
- 의존성 방향을 강제할 수 있었습니다

**효과:** Feature 독립 빌드로 개발 사이클 단축 (전체 앱 2분 → Feature 10초)

---

### 3. 🔗 Protocol Navigation - SRP 기반 모듈 분리

**문제:** 모듈화 이후 Feature 간 직접 import가 불가능했습니다.

**설계 원칙:**  
Feature는 자신의 기능만 책임지고, 화면 간 연결은 Shared의 Protocol이 담당한다.

```
Discover ──┐
MyPage ────┼─→ [Protocol] ←── Challenge (구현)
Home ──────┘    (Shared)
```

```swift
// 1. Shared - Protocol 정의 (연결 책임)
protocol ChallengeCoordinatable {
    func showChallengeDetail(id: Int)
}

// 2. Challenge - 구현 (자신의 네비게이션만)
final class ChallengeCoordinator: ChallengeCoordinatable {
    func showChallengeDetail(id: Int) {
        path.append(.challengeDetail(id: id))
    }
}

// 3. Discover - 사용 (Challenge import 없음)
router.challengeCoordinator?.showChallengeDetail(id: 123)
```

**효과:**
- Feature 간 직접 의존 제거
- 연결 책임 분리 (SRP 유지)
- 순환 참조 컴파일 단계 차단

<br>

---

<br>

## ✅ Results

### 구조 개선
- **Massive ViewController 제거** 
- **모놀리식 → 4-Layer 아키텍처** 전환
- **Feature 간 직접 의존 제거**

### 개발 생산성
- **Feature 독립 빌드** (전체 앱 2분 → Feature 10초)

### 코드 구조 단순화
- **-9,083 lines** (21,970 삭제 / 12,887 추가)

---

### 실제 사례 — MyPage Feature

```
Before
MyPageViewController.swift   774 lines (UI + 네트워크 + 로직 혼재)

After
├─ MyPageView.swift          130 lines (UI)
├─ MyPageViewModel.swift      80 lines (Presentation)
├─ UserRepository.swift       60 lines (Data)
└─ Protocol.swift             20 lines (추상화)
```

<br>

---

<br>

## 💭 Reflection

이번 리팩토링은 앱의 구조를 직접 설계해보는 과정이었습니다.

Tuist를 도입해 모듈화를 시도했고,  
의존성 방향과 Layer 책임을 정의했습니다.  
프로젝트 규모 대비 적절한 구조 수준을 설정하는 것이 핵심 과제였습니다.

Feature 분리 기준과 설계 범위를 결정하는 과정에서  
아키텍처는 정답이 아니라 선택이라는 점을 체감했습니다.

이를 통해

- 모듈 경계 설정의 난이도  
- Protocol 기반 추상화의 효과  
- 구조는 복잡도에 맞춰 설계되어야 한다는 점  

을 확인했습니다.

다음 프로젝트에서는  
프로젝트 복잡도를 먼저 평가하고,  
그에 맞는 수준의 아키텍처를 설계하고자 합니다. 

<br>

---

<br>

## 📚 Additional Information

### Tech Stack

<div align="center">

| Layer | Technologies |
|:---:|:---|
| **Feature** | SwiftUI, Combine, MVVM |
| **Domain** | Repository, UseCase, CQRS |
| **Core** | Alamofire, Keychain |
| **Shared** | DesignSystem, Navigation |
| **Build** | Tuist, Example App |

</div>

### Design Patterns
- Clean Architecture (4-Layer)
- MVVM + Repository Pattern (CQRS)
- Coordinator Pattern (Protocol Navigation)
- Dependency Injection Container

### Module Structure

```
App (17 Modules)
│
├─ Core (2)              NetworkCore, StorageCore
├─ Domain (4)            Auth, Challenge, User, Notification
├─ Feature (5)           Auth, Challenge, MyPage, Discover, Notification
└─ Shared (6)            DesignSystem, Models, Navigation, ...
```

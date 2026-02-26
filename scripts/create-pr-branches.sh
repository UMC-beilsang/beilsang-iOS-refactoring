#!/bin/bash
# PR 분리 (파일 기반 - 간단 버전)

set -e

echo "🚀 5개 PR 브랜치 생성 시작..."
echo ""

# 저장할 브랜치
CURRENT_BRANCH="refactoring-fetch"

# ==========================================
# PR #1: Tuist + Core
# ==========================================
echo "🏗️  [1/5] Tuist + Core 브랜치 생성..."
git checkout -b feature/1-tuist-core origin/main

# Core 관련 파일만 가져오기
git checkout $CURRENT_BRANCH -- \
  beilsang/Config.swift \
  beilsang/Projects/Core/NetworkCore/ \
  beilsang/Projects/Core/StorageCore/ \
  2>/dev/null || true

# Tuist 설정 (있다면)
git checkout $CURRENT_BRANCH -- \
  beilsang/Workspace.swift \
  beilsang/Tuist/ \
  2>/dev/null || true

git checkout $CURRENT_BRANCH -- \
  .gitignore \
  beilsang/.gitignore \
  README.md

git add -A
git commit -m "🏗️ Tuist 기반 모듈 아키텍처 구축 + Core 레이어 구현

## 주요 변경사항
- Tuist 설정 및 프로젝트 구조 설계
- NetworkCore: Alamofire 기반 APIClient, AuthInterceptor
- StorageCore: Keychain 기반 토큰 저장소
- Clean Architecture 레이어 분리

Closes #1" || echo "⚠️  변경사항 없음"

echo "✅ feature/1-tuist-core 생성 완료"
echo ""

# ==========================================
# PR #2: Auth & User Domain
# ==========================================
echo "🔐 [2/5] Auth & User Domain 브랜치 생성..."
git checkout -b feature/2-domain-auth-user origin/main

# 이전 PR 내용 가져오기
git checkout feature/1-tuist-core -- . 2>/dev/null || true

# Domain 추가
git checkout $CURRENT_BRANCH -- \
  beilsang/Projects/Domain/AuthDomain/ \
  beilsang/Projects/Domain/UserDomain/ \
  2>/dev/null || true

git add -A
git commit -m "🔐 Auth & User Domain 레이어 구현

## 주요 변경사항
### AuthDomain
- AuthRepository: 로그인, 회원가입, 토큰 관리
- 소셜 로그인 UseCase (Kakao, Apple)

### UserDomain
- UserRepository: 프로필, 포인트 관리

## 아키텍처
- Repository Pattern
- UseCase 기반 비즈니스 로직 분리

Closes #2" || echo "⚠️  변경사항 없음"

echo "✅ feature/2-domain-auth-user 생성 완료"
echo ""

# ==========================================
# PR #3: Challenge & Notification Domain
# ==========================================
echo "🏆 [3/5] Challenge & Notification Domain 브랜치 생성..."
git checkout -b feature/3-domain-challenge origin/main

# 이전 PR들 내용 가져오기
git checkout feature/2-domain-auth-user -- . 2>/dev/null || true

# Challenge/Notification Domain 추가
git checkout $CURRENT_BRANCH -- \
  beilsang/Projects/Domain/ChallengeDomain/ \
  beilsang/Projects/Domain/NotificationDomain/ \
  2>/dev/null || true

git add -A
git commit -m "🏆 Challenge & Notification Domain 레이어 구현

## 주요 변경사항
### ChallengeDomain
- ChallengeRepository: CRUD, 검색, 필터링
- 8개 UseCase 구현

### NotificationDomain
- NotificationRepository: 알림 CRUD

## 핵심 로직
- 챌린지 필터링 (카테고리, 날짜, 참여 상태)
- 실시간 검색

Closes #3" || echo "⚠️  변경사항 없음"

echo "✅ feature/3-domain-challenge 생성 완료"
echo ""

# ==========================================
# PR #4: Shared + Auth Feature
# ==========================================
echo "🎨 [4/5] Shared + Auth Feature 브랜치 생성..."
git checkout -b feature/4-shared-auth-feature origin/main

# 이전 PR들 내용 가져오기
git checkout feature/3-domain-challenge -- . 2>/dev/null || true

# Shared 및 Auth Feature 추가
git checkout $CURRENT_BRANCH -- \
  beilsang/Projects/Shared/ \
  beilsang/Projects/Feature/Auth/ \
  2>/dev/null || true

git add -A
git commit -m "🎨 Shared Module + Auth Feature (SwiftUI) 구현

## 주요 변경사항
### Shared Module
- DesignSystem: Colors, Fonts, Assets
- UIComponents: 재사용 컴포넌트
- Navigation: AppRouter

### Auth Feature (SwiftUI)
- LoginView: 소셜 로그인
- SignUpView: 5단계 온보딩

## 기술 스택
- SwiftUI + Combine + MVVM

Closes #4" || echo "⚠️  변경사항 없음"

echo "✅ feature/4-shared-auth-feature 생성 완료"
echo ""

# ==========================================
# PR #5: Main Features + 레거시 제거
# ==========================================
echo "📱 [5/5] Main Features + 레거시 제거 브랜치 생성..."
git checkout -b feature/5-main-features origin/main

# 이전 PR들 + 나머지 모두
git checkout feature/4-shared-auth-feature -- . 2>/dev/null || true

git checkout $CURRENT_BRANCH -- \
  beilsang/Projects/Feature/Challenge/ \
  beilsang/Projects/Feature/Discover/ \
  beilsang/Projects/Feature/MyPage/ \
  beilsang/Projects/Feature/Notification/ \
  beilsang/Projects/Feature/LearnMore/ \
  beilsang/Projects/App/ \
  2>/dev/null || true

git checkout $CURRENT_BRANCH -- \
  .github/ \
  2>/dev/null || true

git add -A
git commit -m "📱 Main Features (SwiftUI) 구현 + UIKit 레거시 제거

## 주요 변경사항
### Challenge Feature
- ChallengeListView + FilterBottomSheet
- SearchView

### 기타 Features
- DiscoverView, MyPageView, NotificationView

### App 통합
- MainTabView, RootView

### 레거시 제거 (~2,943줄)
- UIKit ViewController 완전 제거

✅ UIKit → SwiftUI 마이그레이션 완료

Closes #5" || echo "⚠️  변경사항 없음"

echo "✅ feature/5-main-features 생성 완료"
echo ""

# 원래 브랜치로 복귀
git checkout $CURRENT_BRANCH

# ==========================================
# 완료
# ==========================================
echo "🎉 모든 브랜치 생성 완료!"
echo ""
echo "📋 생성된 브랜치:"
git branch | grep "feature/"
echo ""
echo "🚀 다음 단계:"
echo "  git push origin feature/1-tuist-core"
echo "  → GitHub에서 PR #1 생성 및 머지"
echo "  → 이후 순차적으로 PR #2, #3, #4, #5 생성"

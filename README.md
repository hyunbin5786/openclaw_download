# OpenClaw 설치 가이드

## 사전 준비
- **OpenAI 계정** ([가입하기](https://chatgpt.com/))
- **Telegram 데스크탑** 설치 및 로그인 ([다운로드](https://desktop.telegram.org/?setln=ko))

---

## 설치 방법

터미널을 열고 아래 3줄을 순서대로 입력하세요.

```bash
git clone https://github.com/[YOUR_REPO]
cd [YOUR_REPO]
bash setup.sh
```

Homebrew → Node 24 → OpenClaw 순서로 자동 설치됩니다.

---

## 설치 후: Telegram 봇 만들기

`openclaw onboard` 실행 중 Telegram 봇 토큰을 입력하는 단계가 나옵니다.

1. Telegram에서 `@BotFather` 검색 (800만 유저짜리)
2. `start` → `/newbot` 입력
3. 봇 이름, username 입력 (username은 `bot`으로 끝나야 함)
4. 발급된 API key 복사 → 터미널에 붙여넣기

---

## 설치 완료 확인

웹 UI에서 `/new` 입력 후 질문해보세요.


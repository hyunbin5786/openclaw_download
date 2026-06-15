#!/bin/bash

set -e

echo ""
echo "=================================================="
echo "  OpenClaw 자동 설치 스크립트"
echo "=================================================="
echo ""

# ── 1. Homebrew ──────────────────────────────────────
echo "▶ [1/4] Homebrew 설치 중..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
  fi
  echo "✅ Homebrew 설치 완료"
else
  echo "✅ Homebrew 이미 설치되어 있음 — 건너뜀"
fi

# ── 2. Node 24 ───────────────────────────────────────
echo ""
echo "▶ [2/4] Node 24 설치 중..."
if ! node -v 2>/dev/null | grep -q "^v24"; then
  brew install node@24
  brew link --overwrite --force node@24
  echo "✅ Node 24 설치 완료"
else
  echo "✅ Node 24 이미 설치되어 있음 — 건너뜀"
fi
echo ""
node -v && npm -v

# ── 3. OpenClaw 설치 ─────────────────────────────────
echo ""
echo "▶ [3/4] OpenClaw 설치 중..."
if ! command -v openclaw &>/dev/null; then
  sudo curl -fsSL https://openclaw.ai/install.sh | bash
  source ~/.zprofile 2>/dev/null || true
  echo "✅ OpenClaw 설치 완료"
else
  echo "✅ OpenClaw 이미 설치되어 있음 — 건너뜀"
fi

# ── 4. Codex 의존성 설치 ─────────────────────────────
echo ""
echo "▶ [4/4] Codex 의존성 설치 중..."
CODEX_DIR=$(find ~/.openclaw/npm/projects -maxdepth 1 -name "openclaw-codex-*" -type d 2>/dev/null | head -n 1)
if [[ -n "$CODEX_DIR" ]]; then
  echo "  경로 발견: $CODEX_DIR"
  cd "$CODEX_DIR" && npm install && cd -
  echo "✅ Codex 의존성 설치 완료"
else
  # 아직 onboard 전이라 디렉토리가 없을 수 있음 → onboard 후 후처리로 해결
  echo "⚠️  Codex 디렉토리 없음 — onboard 후 자동 처리됩니다"
fi

# ── 5. Onboarding 자동 실행 ──────────────────────────
echo ""
echo "=================================================="
echo "  OpenClaw Onboarding 시작"
echo "  (OpenAI 로그인 창이 브라우저에서 열립니다)"
echo "=================================================="
echo ""

# expect로 인터랙티브 선택 자동화
if ! command -v expect &>/dev/null; then
  brew install expect
fi

expect << 'EXPECT'
set timeout 300
spawn openclaw onboard --auth-choice openai-codex

expect "Continue?" { send "y\r"; exp_continue }
expect "Onboarding mode" { send "\r"; exp_continue }
expect "Select channel" {
  # Telegram 항목으로 이동 후 선택 (두 번째 항목이면 아래 화살표 한 번)
  send "\033\[B\r"; exp_continue
}
expect "How do you want to provide" { send "\r"; exp_continue }
expect "Telegram bot token" {
  puts "\n\n⛔️  여기서 잠깐! Telegram 봇 토큰을 입력해야 합니다."
  puts "    @BotFather → /newbot → 생성 후 토큰 복사 → 여기에 붙여넣기\n"
  interact
}
EXPECT

# ── 6. Onboard 후 Codex 의존성 재확인 ───────────────
echo ""
echo "▶ Codex 의존성 최종 확인 중..."
CODEX_DIR=$(find ~/.openclaw/npm/projects -maxdepth 1 -name "openclaw-codex-*" -type d 2>/dev/null | head -n 1)
if [[ -n "$CODEX_DIR" ]]; then
  cd "$CODEX_DIR" && npm install && cd -
  echo "✅ Codex 의존성 확인 완료"
fi

echo ""
echo "=================================================="
echo "  🎉 설치 완료!"
echo "  웹 UI에서 /new 입력 후 질문해보세요."
echo "=================================================="

#!/bin/bash

set -e

echo ""
echo "=================================================="
echo "  OpenClaw 자동 설치 스크립트"
echo "=================================================="
echo ""

# ── 1. Homebrew ──────────────────────────────────────
echo "▶ [1/3] Homebrew 설치 중..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon / Intel 경로 자동 감지
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
echo "▶ [2/3] Node 24 설치 중..."
if ! node -v 2>/dev/null | grep -q "^v24"; then
  brew install node@24
  brew link --overwrite --force node@24
  echo "✅ Node 24 설치 완료"
else
  echo "✅ Node 24 이미 설치되어 있음 — 건너뜀"
fi

echo ""
node -v
npm -v

# ── 3. OpenClaw ──────────────────────────────────────
echo ""
echo "▶ [3/3] OpenClaw 설치 중..."
if ! command -v openclaw &>/dev/null; then
  sudo curl -fsSL https://openclaw.ai/install.sh | bash
  echo "✅ OpenClaw 설치 완료"
else
  echo "✅ OpenClaw 이미 설치되어 있음 — 건너뜀"
fi

# ── Onboarding 안내 ───────────────────────────────────
echo ""
echo "=================================================="
echo "  설치 완료! 이제 아래 단계를 따라주세요 🎉"
echo "=================================================="
echo ""
echo "  다음 명령어를 실행하면 OpenClaw 설정이 시작됩니다:"
echo ""
echo "    openclaw onboard --auth-choice openai-codex"
echo ""
echo "  설정 중 선택 안내:"
echo "    - Continue?                    → Yes"
echo "    - Onboarding mode              → QuickStart"
echo "    - Select channel               → Telegram (Bot API)"
echo "    - How to provide token?        → Enter Telegram bot token"
echo "    - Search provider              → Skip for now"
echo "    - Configure skills now?        → Yes"
echo "    - Install missing skill deps?  → Skip for now (space → enter)"
echo "    - API key 항목들               → 모두 No"
echo "    - Enable hooks?                → Skip for now (space → enter)"
echo "    - How to hatch your bot?       → Open the Web UI"
echo ""
echo "  ‼️  Yes/No 선택창이 나타나면 → control + C 누르기!"
echo ""

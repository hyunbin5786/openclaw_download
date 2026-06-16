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
sudo npm install -g openclaw@2026.6.6
source ~/.zprofile 2>/dev/null || true
echo "✅ OpenClaw 2026.6.6 설치 완료"

# ── 4. Codex 의존성 설치 ─────────────────────────────
echo ""
echo "▶ [4/4] Codex 의존성 설치 중..."
CODEX_DIR=$(find ~/.openclaw/npm/projects -maxdepth 1 -name "openclaw-codex-*" -type d 2>/dev/null | head -n 1)
if [[ -n "$CODEX_DIR" ]]; then
  echo "  경로 발견: $CODEX_DIR"
  cd "$CODEX_DIR" && npm install && cd -
  echo "✅ Codex 의존성 설치 완료"
else
  echo "⚠️  Codex 디렉토리 없음 — onboard 후 자동 처리됩니다"
fi

echo ""
echo "=================================================="
echo "  🎉 설치 완료!"
echo "  현재 터미널을 닫고 새로운 터미널에서 아래 명령어로 설정을 시작하세요:"
echo ""
echo "    sudo chown -R $(whoami) ~/.openclaw"
echo "    openclaw onboard"
echo ""
echo "=================================================="

#!/bin/bash
set -e
echo ""
echo "=================================================="
echo "  OpenClaw 자동 설치 스크립트"
echo "=================================================="
echo ""
# ─────────────────────────────────────────────────────
# 💡 컴퓨터/계정 이름에 대한 안내
#
# 이 스크립트는 특정 사용자 이름(admin 등)에 고정되어 있지 않습니다.
# 아래 명령어들이 실행하는 컴퓨터의 계정 정보를 자동으로 읽어옵니다:
#   - $(whoami)      → 현재 로그인한 사용자 이름 (예: admin, hyunbin, student01)
#   - $(id -u)       → 현재 사용자의 UID (macOS 첫 계정은 보통 501)
#   - $(id -g)       → 현재 사용자의 그룹 GID (macOS는 보통 20 = staff)
#   - ~ 또는 $HOME   → 현재 사용자의 홈 폴더 (예: /Users/hyunbin)
#
# 따라서 admin이 아닌 다른 이름의 계정에서도 그대로 실행하면 됩니다.
# 절대 "admin"이나 "501" 같은 값을 직접 타이핑하지 마세요.
# ─────────────────────────────────────────────────────

# ── 1. Homebrew ──────────────────────────────────────
echo "▶ [1/6] Homebrew 설치 중..."
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
echo "▶ [2/6] Node 24 설치 중..."
if ! node -v 2>/dev/null | grep -q "^v24"; then
  brew install node@24
  brew link --overwrite --force node@24
  echo "✅ Node 24 설치 완료"
else
  echo "✅ Node 24 이미 설치되어 있음 — 건너뜀"
fi
echo ""
node -v && npm -v

# ── 3. node 경로 심볼릭 링크 ─────────────────────────
# OpenClaw 게이트웨이(LaunchAgent)는 버전 없는 경로
# ($BREW_PREFIX/opt/node/bin/node)로 node를 실행하는데,
# node@24는 $BREW_PREFIX/opt/node@24 에 설치되므로 경로가 어긋나
# 게이트웨이가 시작 즉시 종료되는 문제가 발생합니다.
# (증상: gateway restart 실패, "state spawn scheduled", 1006 오류)
# 아래 링크가 이 문제를 예방합니다.
echo ""
echo "▶ [3/6] node 경로 링크 설정 중..."
BREW_PREFIX=$(brew --prefix)   # Apple Silicon: /opt/homebrew, Intel: /usr/local
if [[ -d "$BREW_PREFIX/opt/node@24" && ! -e "$BREW_PREFIX/opt/node" ]]; then
  ln -sfn "$BREW_PREFIX/opt/node@24" "$BREW_PREFIX/opt/node"
  echo "✅ 링크 생성: $BREW_PREFIX/opt/node → node@24"
elif [[ -e "$BREW_PREFIX/opt/node" ]]; then
  echo "✅ node 경로 이미 존재 — 건너뜀"
else
  echo "⚠️  node@24 경로를 찾지 못함 — 수동 확인 필요"
fi

# ── 4. OpenClaw 설치 ─────────────────────────────────
echo ""
echo "▶ [4/6] OpenClaw 설치 중..."
sudo npm install -g openclaw@2026.6.10
source ~/.zprofile 2>/dev/null || true
echo "✅ OpenClaw 2026.6.10 설치 완료"

# ── 5. 권한 정리 ─────────────────────────────────────
# sudo npm install을 쓰면 ~/.npm 캐시에 root 소유 파일이 생겨
# 이후 플러그인 설치(codex 등)가 EACCES 오류로 실패합니다.
# 현재 사용자의 UID:GID로 소유권을 돌려놓습니다.
# (id -u / id -g 를 쓰므로 어떤 계정 이름이든 동일하게 동작)
echo ""
echo "▶ [5/6] npm/openclaw 폴더 권한 정리 중..."
sudo chown -R "$(id -u):$(id -g)" ~/.npm 2>/dev/null || true
sudo chown -R "$(whoami)" ~/.openclaw 2>/dev/null || true
echo "✅ 권한 정리 완료 (사용자: $(whoami), UID:GID = $(id -u):$(id -g))"

# ── 6. Codex 의존성 설치 ─────────────────────────────
echo ""
echo "▶ [6/6] Codex 의존성 설치 중..."
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
echo "    openclaw onboard"
echo ""
echo "  (메뉴 방식의 이전 온보딩을 원하면: openclaw onboard --classic)"
echo ""
echo "  ※ 게이트웨이가 시작되지 않을 때 점검 순서:"
echo "    openclaw doctor"
echo "    openclaw gateway restart"
echo "    openclaw gateway status --deep"
echo "=================================================="

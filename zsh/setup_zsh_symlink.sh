#!/bin/bash

# Zsh 설정 자동화 스크립트
# 기존 ~/.zshrc에 dotFiles의 .zshrc를 import하는 구문을 추가

set -e  # 에러 발생시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수들
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 스크립트 디렉토리 경로 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
ZSH_CONFIG_FILE="$SCRIPT_DIR/.zshrc"
TARGET_ZSH_FILE="$HOME/.zshrc"
IMPORT_MARKER="# DotFiles Import - DO NOT REMOVE THIS LINE"

log_info "Zsh 설정 자동화 스크립트를 시작합니다..."
log_info "스크립트 디렉토리: $SCRIPT_DIR"
log_info "DotFiles 디렉토리: $DOTFILES_DIR"
log_info "소스 파일: $ZSH_CONFIG_FILE"
log_info "대상 파일: $TARGET_ZSH_FILE"

# 소스 파일 존재 확인
if [ ! -f "$ZSH_CONFIG_FILE" ]; then
    log_error "소스 파일을 찾을 수 없습니다: $ZSH_CONFIG_FILE"
    exit 1
fi

# 기존 ~/.zshrc 파일 처리
if [ -f "$TARGET_ZSH_FILE" ]; then
    # 기존 파일이 심링크인지 확인
    if [ -L "$TARGET_ZSH_FILE" ]; then
        log_warning "기존 ~/.zshrc가 심링크입니다. 일반 파일로 변환합니다."
        CURRENT_LINK=$(readlink "$TARGET_ZSH_FILE")
        log_info "현재 심링크 대상: $CURRENT_LINK"

        # 심링크가 가리키는 파일의 내용을 읽어서 일반 파일로 변환
        if [ -f "$CURRENT_LINK" ]; then
            cp "$CURRENT_LINK" "$TARGET_ZSH_FILE"
            log_success "심링크를 일반 파일로 변환했습니다."
        else
            log_error "심링크가 가리키는 파일을 찾을 수 없습니다: $CURRENT_LINK"
            exit 1
        fi
    fi

    # 이미 import 구문이 있는지 확인
    if grep -q "$IMPORT_MARKER" "$TARGET_ZSH_FILE"; then
        log_warning "이미 DotFiles import 구문이 존재합니다."

        # 기존 import 구문을 새로운 경로로 업데이트
        log_info "기존 import 구문을 업데이트합니다..."
        sed -i.bak "s|source.*dotFiles.*\.zshrc|source \"$ZSH_CONFIG_FILE\"|g" "$TARGET_ZSH_FILE"
        rm -f "$TARGET_ZSH_FILE.bak"
        log_success "Import 구문이 업데이트되었습니다!"
        exit 0
    fi
else
    # ~/.zshrc 파일이 없는 경우 기본 파일 생성
    log_info "~/.zshrc 파일이 없습니다. 기본 파일을 생성합니다."
    cat > "$TARGET_ZSH_FILE" << 'EOF'
# 기본 zsh 설정
export PATH="$HOME/bin:$PATH"

EOF
    log_success "기본 ~/.zshrc 파일을 생성했습니다."
fi

# DotFiles import 구문 추가
log_info "DotFiles import 구문을 추가합니다..."
cat >> "$TARGET_ZSH_FILE" << EOF

$IMPORT_MARKER
# DotFiles 설정 로드
if [ -f "$ZSH_CONFIG_FILE" ]; then
    source "$ZSH_CONFIG_FILE"
else
    echo "Warning: DotFiles zshrc not found at $ZSH_CONFIG_FILE"
fi
EOF

if [ $? -eq 0 ]; then
    log_success "DotFiles import 구문이 추가되었습니다!"
    log_info "~/.zshrc에 다음 구문이 추가되었습니다:"
    log_info "  source \"$ZSH_CONFIG_FILE\""
else
    log_error "DotFiles import 구문 추가에 실패했습니다."
    exit 1
fi

echo ""
log_success "Zsh 설정이 완료되었습니다!"
log_info "기존 ~/.zshrc 설정을 유지하면서 DotFiles 설정을 import하도록 구성되었습니다."
log_info "새 터미널을 열거나 'source ~/.zshrc'를 실행하여 설정을 적용하세요."
log_info ""
log_info "참고: DotFiles import 구문을 제거하려면 ~/.zshrc에서 다음 라인들을 삭제하세요:"
log_info "  - $IMPORT_MARKER"
log_info "  - source \"$ZSH_CONFIG_FILE\" 관련 라인들"

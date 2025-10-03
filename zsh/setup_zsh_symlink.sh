#!/bin/bash

# Zsh 설정 자동화 스크립트
# 기존 ~/.zshrc를 백업하고 dotFiles의 .zshrc를 심링크로 연결

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
        log_warning "기존 ~/.zshrc가 이미 심링크입니다."
        CURRENT_LINK=$(readlink "$TARGET_ZSH_FILE")
        log_info "현재 심링크 대상: $CURRENT_LINK"

        # 이미 올바른 심링크인지 확인
        if [ "$CURRENT_LINK" = "$ZSH_CONFIG_FILE" ]; then
            log_success "이미 올바른 심링크가 설정되어 있습니다!"
            exit 0
        else
            log_warning "다른 파일로 연결된 심링크입니다. 제거합니다."
            rm "$TARGET_ZSH_FILE"
        fi
    else
        # 일반 파일인 경우 백업
        BACKUP_FILE="$TARGET_ZSH_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "기존 ~/.zshrc 파일을 백업합니다: $BACKUP_FILE"
        cp "$TARGET_ZSH_FILE" "$BACKUP_FILE"
        log_success "백업 완료: $BACKUP_FILE"

        # 기존 파일 제거
        rm "$TARGET_ZSH_FILE"
    fi
fi

# 심링크 생성
log_info "심링크를 생성합니다..."
ln -s "$ZSH_CONFIG_FILE" "$TARGET_ZSH_FILE"

if [ $? -eq 0 ]; then
    log_success "심링크 생성 완료!"
    log_info "~/.zshrc -> $ZSH_CONFIG_FILE"
else
    log_error "심링크 생성에 실패했습니다."
    exit 1
fi

# 심링크 확인
if [ -L "$TARGET_ZSH_FILE" ] && [ "$(readlink "$TARGET_ZSH_FILE")" = "$ZSH_CONFIG_FILE" ]; then
    log_success "심링크가 올바르게 설정되었습니다!"
else
    log_error "심링크 설정을 확인할 수 없습니다."
    exit 1
fi

echo ""
log_success "Zsh 설정이 완료되었습니다!"
log_info "새 터미널을 열거나 'source ~/.zshrc'를 실행하여 설정을 적용하세요."

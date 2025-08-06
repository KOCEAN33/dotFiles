#!/bin/zsh

# Cursor 설정 파일 심볼릭 링크 설정 스크립트
# macOS zsh 기준

echo "🔗 Cursor 설정 파일 심볼릭 링크를 설정합니다..."

# 경로 설정
DOTFILES_DIR="$(cd "$(dirname "${0}")" && pwd)"
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"

# 링크할 파일들
declare -A FILES=(
    ["keybindings.json"]="$DOTFILES_DIR/keybindings.json"
    ["settings.json"]="$DOTFILES_DIR/settings.json"
)

# 대상 디렉토리 존재 확인 및 생성
if [[ ! -d "$CURSOR_USER_DIR" ]]; then
    echo "📁 Cursor User 디렉토리를 생성합니다: $CURSOR_USER_DIR"
    mkdir -p "$CURSOR_USER_DIR"
    if [[ $? -ne 0 ]]; then
        echo "❌ 디렉토리 생성에 실패했습니다."
        exit 1
    fi
fi

# 각 파일에 대해 심볼릭 링크 생성
for file in "${(@k)FILES}"; do
    source_file="${FILES[$file]}"
    target_file="$CURSOR_USER_DIR/$file"

    echo "\n🔄 처리 중: $file"

    # 소스 파일 존재 확인
    if [[ ! -f "$source_file" ]]; then
        echo "❌ 소스 파일이 존재하지 않습니다: $source_file"
        continue
    fi

    # 기존 파일/링크 처리
    if [[ -e "$target_file" || -L "$target_file" ]]; then
        if [[ -L "$target_file" ]]; then
            existing_link=$(readlink "$target_file")
            if [[ "$existing_link" == "$source_file" ]]; then
                echo "✅ 이미 올바른 심볼릭 링크가 설정되어 있습니다: $target_file -> $source_file"
                continue
            else
                echo "🔄 기존 심볼릭 링크를 제거합니다: $target_file -> $existing_link"
            fi
        else
            echo "🔄 기존 파일을 백업하고 제거합니다: $target_file"
            # 백업 생성
            backup_file="${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$target_file" "$backup_file"
            echo "📦 백업 생성됨: $backup_file"
        fi
        rm -f "$target_file"
    fi

    # 심볼릭 링크 생성
    ln -s "$source_file" "$target_file"
    if [[ $? -eq 0 ]]; then
        echo "✅ 심볼릭 링크 생성 완료: $target_file -> $source_file"
    else
        echo "❌ 심볼릭 링크 생성에 실패했습니다: $target_file"
    fi
done

echo "\n🎉 Cursor 설정 파일 심볼릭 링크 설정이 완료되었습니다!"
echo "\n📋 설정된 링크 확인:"
for file in "${(@k)FILES}"; do
    target_file="$CURSOR_USER_DIR/$file"
    if [[ -L "$target_file" ]]; then
        echo "  ✅ $file: $(readlink "$target_file")"
    else
        echo "  ❌ $file: 링크되지 않음"
    fi
done

echo "\n💡 Tip: Cursor를 재시작하면 새 설정이 적용됩니다."
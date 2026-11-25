#!/usr/bin/env bash
# 拼接多段约 10 秒的镜头 / Stitch short clips into one file.
#
# 先用 ffprobe 探测每一段的宽高、帧率、视频/音频编码。
# 全部一致时优先 ffmpeg -c copy（无损快拼）；
# 不一致则先规范再拼接。
# 需要重编码时的文档化默认（不是某种片厂造型）：
#   16:9 → 1280x720，9:16 → 720x1280，24fps，音频 AAC 48kHz。
#
# 用法 / Usage:
#   bash stitch_clips.sh -a 16:9 -o film-full.mp4 seg1.mp4 seg2.mp4 seg3.mp4
#   bash stitch_clips.sh -a 9:16 -o film-full.mp4 seg1.mp4 seg2.mp4
#   bash stitch_clips.sh -a auto  -o film-full.mp4 seg1.mp4 seg2.mp4
#
# 输出文件名请使用 ASCII。
set -euo pipefail

usage() {
  cat <<'EOF'
用法: stitch_clips.sh [-a 16:9|9:16|auto] [-o 输出.mp4] [-f fps] 段1.mp4 段2.mp4 ...

  -a   画幅：16:9、9:16，或 auto（以第一段的宽高比判断；默认 auto）
  -o   输出文件（默认 stitched-full.mp4）
  -f   重编码时的帧率（默认 24）
  -h   显示帮助

先探测，能复制就复制；编码或尺寸不一致时再按画幅规范后拼接。
EOF
}

ASPECT="auto"
OUT="stitched-full.mp4"
FPS="24"

while getopts ":a:o:f:h" opt; do
  case "$opt" in
    a) ASPECT="$OPTARG" ;;
    o) OUT="$OPTARG" ;;
    f) FPS="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "未知参数: -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "参数 -$OPTARG 需要值" >&2; usage; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

CLIPS=("$@")

is_ascii() {
  local s="$1"
  [[ "$s" == "$(printf '%s' "$s" | tr -cd '\0-\177')" ]]
}

if ! is_ascii "$(basename "$OUT")"; then
  echo "输出文件名必须是 ASCII / output basename must be ASCII: $OUT" >&2
  exit 2
fi

for clip in "${CLIPS[@]}"; do
  if [[ ! -f "$clip" ]]; then
    echo "找不到片段 / clip not found: $clip" >&2
    exit 1
  fi
done

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "需要已安装 $1" >&2
    exit 1
  }
}
need_cmd ffprobe
need_cmd ffmpeg

# 读取第一条视频流和（若有）第一条音频流的关键参数
probe_field() {
  local file="$1" stream="$2" field="$3"
  ffprobe -v error -select_streams "$stream" \
    -show_entries "stream=$field" -of default=noprint_wrappers=1:nokey=1 \
    "$file" 2>/dev/null | head -n 1 || true
}

probe_clip() {
  local file="$1"
  local w h fps_raw vcodec acodec
  w="$(probe_field "$file" v:0 width)"
  h="$(probe_field "$file" v:0 height)"
  fps_raw="$(probe_field "$file" v:0 r_frame_rate)"
  vcodec="$(probe_field "$file" v:0 codec_name)"
  acodec="$(probe_field "$file" a:0 codec_name)"
  if [[ -z "$w" || -z "$h" || -z "$vcodec" ]]; then
    echo "无法探测视频流 / cannot probe video stream: $file" >&2
    exit 1
  fi
  printf '%s %s %s %s %s' "$w" "$h" "$fps_raw" "$vcodec" "${acodec:-none}"
}

declare -a WIDTHS HEIGHTS FPSRATES VCODECS ACODECS
HAVE_AUDIO=0
MISSING_AUDIO=0

echo "探测片段 / probing clips:"
for clip in "${CLIPS[@]}"; do
  read -r w h fps_raw vcodec acodec <<<"$(probe_clip "$clip")"
  WIDTHS+=("$w")
  HEIGHTS+=("$h")
  FPSRATES+=("$fps_raw")
  VCODECS+=("$vcodec")
  ACODECS+=("$acodec")
  echo "  $clip  ${w}x${h}  fps=${fps_raw}  v=${vcodec}  a=${acodec}"
  if [[ "$acodec" == "none" || -z "$acodec" ]]; then
    MISSING_AUDIO=1
  else
    HAVE_AUDIO=1
  fi
done

target_from_aspect() {
  case "$1" in
    16:9|16x9|landscape) echo "1280 720" ;;
    9:16|9x16|vertical) echo "720 1280" ;;
    *) return 1 ;;
  esac
}

ratio_of() {
  local w="$1" h="$2"
  # 用整数交叉相乘判断更接近 16:9 还是 9:16
  # 16/9 = 1.777..., 9/16 = 0.5625
  awk -v w="$w" -v h="$h" 'BEGIN{
    r = w/h
    d16 = (r>16/9)? r-16/9 : 16/9-r
    d9  = (r>9/16)? r-9/16 : 9/16-r
    if (d16 <= d9) print "16:9"
    else print "9:16"
  }'
}

RESOLVE_ASPECT="$ASPECT"
if [[ "$RESOLVE_ASPECT" == "auto" ]]; then
  RESOLVE_ASPECT="$(ratio_of "${WIDTHS[0]}" "${HEIGHTS[0]}")"
  echo "自动画幅 / auto aspect: $RESOLVE_ASPECT （依据第一段 ${WIDTHS[0]}x${HEIGHTS[0]}）"
fi

if ! read -r TARGET_W TARGET_H <<<"$(target_from_aspect "$RESOLVE_ASPECT")"; then
  echo "不支持的画幅: $ASPECT （请用 16:9、9:16 或 auto）" >&2
  exit 2
fi

same() {
  local first="$1"; shift
  local x
  for x in "$@"; do
    [[ "$x" == "$first" ]] || return 1
  done
  return 0
}

CAN_COPY=1
if ! same "${WIDTHS[@]}"; then CAN_COPY=0; fi
if ! same "${HEIGHTS[@]}"; then CAN_COPY=0; fi
if ! same "${FPSRATES[@]}"; then CAN_COPY=0; fi
if ! same "${VCODECS[@]}"; then CAN_COPY=0; fi
if ! same "${ACODECS[@]}"; then CAN_COPY=0; fi
if [[ "$HAVE_AUDIO" -eq 1 && "$MISSING_AUDIO" -eq 1 ]]; then CAN_COPY=0; fi

# 即使参数一致，若实际宽高与目标规范不符，也只在用户显式指定了 16:9/9:16 时才重编码。
# auto 且全部一致：直接 copy，不强行拉到 1280x720。
if [[ "$ASPECT" != "auto" ]]; then
  for i in "${!WIDTHS[@]}"; do
    if [[ "${WIDTHS[$i]}" != "$TARGET_W" || "${HEIGHTS[$i]}" != "$TARGET_H" ]]; then
      CAN_COPY=0
    fi
  done
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/stitch-clips.XXXXXX")"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

concat_copy() {
  local list="$WORKDIR/concat-list.txt"
  local clip rel
  : > "$list"
  for clip in "${CLIPS[@]}"; do
    # concat demuxer 需要单引号转义
    rel="${clip//\'/\'\\\'\'}"
    printf "file '%s'\n" "$rel" >> "$list"
  done
  echo "编码一致，无损复制拼接 / stream copy concat → $OUT"
  ffmpeg -y -loglevel error -f concat -safe 0 -i "$list" -c copy "$OUT"
}

normalize_one() {
  local src="$1" dest="$2"
  local vf="scale=${TARGET_W}:${TARGET_H}:force_original_aspect_ratio=decrease,pad=${TARGET_W}:${TARGET_H}:(ow-iw)/2:(oh-ih)/2,fps=${FPS}"
  if [[ "$(probe_field "$src" a:0 codec_name)" == "" ]]; then
    # 无音轨：补静音，避免与有音轨片段无法对齐
    ffmpeg -y -loglevel error -i "$src" -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=48000 \
      -vf "$vf" -shortest \
      -c:v libx264 -pix_fmt yuv420p \
      -c:a aac -ar 48000 -ac 2 \
      "$dest"
  else
    ffmpeg -y -loglevel error -i "$src" \
      -vf "$vf" \
      -c:v libx264 -pix_fmt yuv420p \
      -c:a aac -ar 48000 -ac 2 \
      "$dest"
  fi
}

concat_normalized() {
  local list="$WORKDIR/concat-list.txt"
  local i clip dest
  : > "$list"
  echo "尺寸或编码不一致，先规范为 ${TARGET_W}x${TARGET_H} @ ${FPS}fps 再拼接 / normalize then concat"
  i=0
  for clip in "${CLIPS[@]}"; do
    dest="$WORKDIR/seg-$(printf '%02d' "$i").mp4"
    echo "  规范 $clip → $(basename "$dest")"
    normalize_one "$clip" "$dest"
    printf "file '%s'\n" "$dest" >> "$list"
    i=$((i + 1))
  done
  ffmpeg -y -loglevel error -f concat -safe 0 -i "$list" -c copy "$OUT"
}

if [[ "$CAN_COPY" -eq 1 ]]; then
  concat_copy
else
  concat_normalized
fi

echo "成片 / output:"
ffprobe -v error -show_entries stream=codec_type,codec_name,width,height,r_frame_rate \
  -show_entries format=duration -of default "$OUT"
echo "$OUT"

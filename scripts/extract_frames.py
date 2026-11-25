#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""抽帧自查 / Extract stills for prompt QA.

从视频中抽取若干帧，用于核对提示词或关键帧是否被吃进。
需要本机已安装 ffprobe 与 ffmpeg。输出文件名请使用 ASCII。

用法 / Usage:
  python3 extract_frames.py <video> [n=4] [out_prefix]
  python3 extract_frames.py clip.mp4 4 seg1-qc
  python3 extract_frames.py clip.mp4 --junction seg1-ends
  python3 extract_frames.py clip.mp4 --times 1.0,4.5,8.8 seg1-beats

改编自 Mason Mosen 的 extract_frames.py（MIT）。
"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys


def die(msg: str, code: int = 1) -> None:
    print(msg, file=sys.stderr)
    sys.exit(code)


def require_ascii(path: str, label: str) -> None:
    try:
        path.encode("ascii")
    except UnicodeEncodeError:
        die(
            f"{label} 必须是 ASCII 文件名，以避免上游或工具拒绝："
            f"{label} must be an ASCII path: {path}"
        )


def ffprobe_duration(video: str) -> float:
    result = subprocess.run(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            video,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        err = (result.stderr or result.stdout or "").strip()
        die(f"ffprobe 失败 / ffprobe failed: {err}")
    try:
        duration = float(result.stdout.strip())
    except ValueError:
        die(f"无法读取时长 / cannot parse duration: {result.stdout!r}")
    if duration <= 0:
        die(f"时长无效 / invalid duration: {duration}")
    return duration


def extract_one(video: str, t: float, out: str) -> None:
    # 稍稍夹在片头片尾内，避免等于总时长时抽不到帧
    t = max(0.0, t)
    result = subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-loglevel",
            "error",
            "-ss",
            f"{t:.3f}",
            "-i",
            video,
            "-frames:v",
            "1",
            out,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0 or not os.path.exists(out):
        err = (result.stderr or result.stdout or "").strip()
        die(f"抽帧失败 / ffmpeg failed at t={t:.3f}s -> {out}: {err}")
    print(out)


def even_times(duration: float, n: int) -> list[float]:
    # 落在每段区间中点，避免总抽到 0:00 黑场或恰好踩在文件末尾
    return [duration * (i + 0.5) / n for i in range(n)]


def junction_times(duration: float) -> list[float]:
    edge = min(0.08, duration * 0.02)
    mid = duration * 0.5
    end = max(edge, duration - edge)
    return [edge, mid, end]


def parse_times(spec: str, duration: float) -> list[float]:
    values = []
    for part in spec.split(","):
        part = part.strip()
        if not part:
            continue
        try:
            t = float(part)
        except ValueError:
            die(f"无法解析时间 / cannot parse time: {part}")
        if t < 0:
            die(f"时间不能为负 / time must be >= 0: {t}")
        if t > duration:
            print(f"警告: {t}s 超出时长 {duration:.3f}s，将夹到片尾内侧", file=sys.stderr)
            t = max(0.0, duration - 0.05)
        values.append(t)
    if not values:
        die("--times 需要至少一个时间点")
    return values


def default_prefix(video: str) -> str:
    base = os.path.splitext(os.path.basename(video))[0]
    return base or "frame"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="从视频抽取静帧做验收 / Extract stills for QA",
        add_help=True,
    )
    parser.add_argument("video", help="输入视频 / input video")
    parser.add_argument(
        "n_or_prefix",
        nargs="?",
        default=None,
        help="抽帧数量（默认 4）或在使用 --junction/--times 时作为前缀",
    )
    parser.add_argument(
        "prefix",
        nargs="?",
        default=None,
        help="输出前缀 / output prefix（默认取视频文件名）",
    )
    parser.add_argument(
        "--junction",
        action="store_true",
        help="抽取首帧、中点、尾帧，便于衔接检查",
    )
    parser.add_argument(
        "--times",
        metavar="T1,T2,...",
        help="按秒指定时间点，逗号分隔",
    )
    args = parser.parse_args()

    video = args.video
    if not os.path.isfile(video):
        die(f"找不到视频 / video not found: {video}")

    if args.junction and args.times:
        die("不要同时使用 --junction 和 --times")

    # 兼容原用法: extract_frames.py <video> [n=4] [out_prefix]
    n = 4
    prefix = default_prefix(video)
    positional = args.n_or_prefix
    if args.junction or args.times:
        if positional:
            prefix = positional
        if args.prefix:
            prefix = args.prefix
    else:
        if positional is not None:
            try:
                n = int(positional)
            except ValueError:
                # 允许 extract_frames.py clip.mp4 my-prefix
                prefix = positional
            else:
                if n < 1:
                    die("n 必须 >= 1")
                if args.prefix:
                    prefix = args.prefix
        elif args.prefix:
            prefix = args.prefix

    require_ascii(os.path.basename(prefix), "输出前缀 / output prefix")

    duration = ffprobe_duration(video)
    if args.times:
        times = parse_times(args.times, duration)
        labels = list(range(1, len(times) + 1))
    elif args.junction:
        times = junction_times(duration)
        labels = ["start", "mid", "end"]
    else:
        times = even_times(duration, n)
        labels = list(range(1, n + 1))

    out_dir = os.path.dirname(prefix)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    for label, t in zip(labels, times):
        out = f"{prefix}-f{label}.png"
        require_ascii(os.path.basename(out), "输出文件 / output file")
        extract_one(video, t, out)


if __name__ == "__main__":
    main()

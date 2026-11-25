# Muse Short Video Studio

一个自包含的短视频技能包：把前期策划、电影感短片、动画短片 / IP 故事，以及可选的执行纪律收成同一个 skill。按模式选用提示词、连续性方法和执行后端，不要混用。

本仓库即可离线使用。把**整个文件夹**安装到 Agent 的技能目录后，只阅读本包内的相对路径文件，不必再去其他仓库取流程或模板。

## 安装

复制整个目录，不要只拷 `SKILL.md`。`references/`、`templates/`、`scripts/`、`examples/` 必须与 `SKILL.md` 在同一棵目录树下。

```bash
cp -r muse-short-video-studio <你的技能目录>/muse-short-video-studio
```

常见技能目录示例（按你实际使用的 Agent 选择其一）：

- `~/.cursor/skills/`
- `~/.codex/skills/`
- 项目内的 `.agents/skills/` 或等效路径

依赖：编写和策划不需要额外软件。抽帧与拼接需要本机已安装 `ffmpeg` 与 `ffprobe`。Python 3 用于 `scripts/extract_frames.py`。

## 怎么用

先读 [SKILL.md](SKILL.md) 完成路由和硬规则核对，再按模式打开对应参考文件：

| 用户要做的事 | 模式 | 先读 |
|---|---|---|
| 只出脚本、分镜、美术与声音方向，先不生成 | A 前期策划 | [references/mode-a-planning.md](references/mode-a-planning.md) |
| 电影感实拍短片、提示词实验、多段拼长片 | B 电影感短片 | [references/mode-b-cinematic.md](references/mode-b-cinematic.md) |
| 动画短片、IP 故事、角色连贯与场次衔接 | C 动画短片 | [references/mode-c-animation.md](references/mode-c-animation.md) |
| 照片说话、旧照修复、视频换人，或用户已确认的执行通道 | D 执行后端（默认关闭） | [references/mode-d-backend.md](references/mode-d-backend.md) |

商业广告通常先 A 再 B。需要人物连续的动画不要用模式 D 的有限并行拼接。模式 B 用快照顺序接续；模式 C 用同一关键帧文件做 Match Cut；两者不要混用。

## 目录

```
muse-short-video-studio/
├── SKILL.md                          # 总路由与硬规则（先读这个）
├── README.md
├── LICENSE
├── references/
│   ├── mode-a-planning.md            # 策划流程、角色按需加载、可选编译器
│   ├── mode-b-cinematic.md           # 电影感提示词、快照接续、拼接与验收
│   ├── mode-c-animation.md           # 角色表到成片、Match Cut、旁白与合成
│   ├── mode-d-backend.md             # 可选执行纪律（默认关闭，无内置客户端）
│   └── qa-checklist.md               # 抽帧、衔接、音频与交付检查
├── templates/
│   ├── cinematic-prompt.md           # 带时间轴的实战模板 + POV / 口播 / 多段变体
│   ├── animation-mega-prompt.md      # FIRST FRAME / MOTION / CAMERA / LAST FRAME / SOUND / MUSIC / VO
│   ├── character-sheet.md            # 角色设定表
│   ├── story-bible.md                # 故事圣经
│   ├── creative-package.md           # 策划包大纲
│   └── delivery-notes.md             # 交付说明
├── scripts/
│   ├── extract_frames.py             # 抽帧自查
│   └── stitch_clips.sh               # 先探测再拼接（能 copy 就 copy）
└── examples/
    ├── mode-b-cinematic-example.md   # 虚构的 30 秒三折短片
    └── mode-c-animation-example.md   # 虚构的四场动画，演示同一文件做 Match Cut
```

## 脚本

在技能根目录或任意目录调用均可，把路径换成实际文件：

```bash
# 按时长均匀抽 4 帧（默认）
python3 scripts/extract_frames.py clip.mp4 4 clip-qc

# 抽首帧、中点、尾帧，便于看衔接
python3 scripts/extract_frames.py clip.mp4 --junction clip-ends

# 拼接：先探测，编码一致则无损复制，否则按画幅规范重编码再拼接
bash scripts/stitch_clips.sh -a 16:9 -o film-full.mp4 seg1.mp4 seg2.mp4 seg3.mp4
bash scripts/stitch_clips.sh -a 9:16 -o film-full.mp4 seg1.mp4 seg2.mp4
```

规范默认（仅在需要重编码时使用，不是某种片厂造型锁定）：16:9 → 1280×720、9:16 → 720×1280、24fps。输出文件名请使用 ASCII。

## 硬规则（摘要）

单段约 10 秒；先锁画幅；提示词经用户定稿后原文送出；不承诺锁脸；密钥不进仓库或聊天；付费与第三方接口须先征得同意；可能已扣费的任务禁止自动重提；文件名用 ASCII；模式 D 默认关闭。完整条款以 [SKILL.md](SKILL.md) 为准。

## 致谢

本包的流程与模板改编自以下 MIT 许可项目，并保留原作者声明（详见 [LICENSE](LICENSE)）：

- [muse-video-prompt-skill](https://github.com/masonmosen/muse-video-prompt-skill)，Copyright (c) Mason Mosen
- [Muse-animated-short-film](https://github.com/sonlovinbot-team/Muse-animated-short-film)，Copyright (c) Đặng Hữu Sơn (sonlovinbot)
- [muse-video-skill](https://github.com/LuoJiangYong/muse-video-skill)，Copyright (c) Jiang Yong Luo
- [useapi/muse-api](https://github.com/useapi/muse-api)（muse-video skill），Copyright (c) useapi.net

这些链接只作署名。使用本技能时不必打开、克隆或安装上述项目，本仓库内的文件已经足够离线运行。第三方 API 的使用条款与收费以该服务当时规则为准，MIT 许可不覆盖其服务本身。

## 许可

本仓库以 [MIT License](LICENSE) 发布。

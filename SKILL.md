---
name: muse-short-video-studio
description: >-
  当用户要用 Muse 或下游视频模型做电影感短片、动画短片或 IP 故事、品牌广告的策划与出片、照片说话/旧照修复/视频换人，或把多段约 10
  秒片段接成成片时使用。先按模式路由，不要混用不同提示词模板或连续性方法。
---
# Muse Short Video Studio

这是一个总 skill：共享出片约束和路由，下面挂四种可选模式。按模式选用提示词、连续性方法和执行后端，不要擅自接成一条从头跑到尾的超级管线。

本包自包含，只依据本文件夹内的流程、模板、清单和脚本工作，不要到包外寻找配套文件。

## 1. 路由

先确认用户要做什么，只选一种主模式；出片前可以先跑策划模式。

- 只策划：出脚本、分镜、美术与声音方向，先不生成 → **模式 A**
- 电影感实拍短片、提示词实验、多段拼长片 → **模式 B**
- 动画短片、IP 故事、需要角色连贯和场次衔接 → **模式 C**
- 照片说话、旧照修复上色、视频换人、无脸旁白短片或批量执行 → **模式 D**（默认关闭，必须先确认执行后端）

商业广告或品牌大片：先 A 再 B。需要人物连续的动画或剧情片，不要用模式 D 的「最多几场并行拼接」。需要强锁脸时，不要承诺 Muse 内置视频能锁住身份；改走用户指定、更适合参考图锁脸的下游模型，或停下说明限制。

## 2. 共同硬规则

- 单段按约 10 秒上限规划；更长的必须拆段再拼接。
- 开始前先锁定画幅（16:9 或 9:16 等）、成片语言和大致片长。之后所有提示词、参考图、关键帧和合成分辨率都遵守同一画幅。提示词里要写清楚比例；若接口没有独立的画幅参数，写明 `in exactly 16:9 aspect ratio` 这类直接约束，不要只写 `cinematic 16:9`。
- 提示词先交给用户定稿，再按定稿原文送去生成，不擅自扩写。
- 不承诺锁脸或人物全程同一人。续接快照、参考图、角色表只能提高风格或上下文延续的概率。
- 没抽帧、没看过、没听过的内容，不说「没问题」。交付时写清吃进了什么、偏了什么；音频、口型、动态连贯交给用户终验。
- 密钥、token、账号凭据只走环境变量或密钥库，不打印、不回显、不写入仓库或聊天。
- 付费、第三方 API、周额度或订阅，必须先说明并得到用户同意再用。可能已经扣费的任务禁止自动重提，只用任务 id 恢复等待和下载。
- 上传或本地文件名使用 ASCII，避免中文等非 ASCII 文件名导致上游拒绝。
- 人脸、旧照、换人，先确认已有权利人授权，不用于误导或未经同意的身份冒用。
- 电影、广告、商标、角色造型只可作技法学习，不得把原片画面、商标或受保护造型当作生成素材或商用成片元素。
- 不要把某一种口音、某一家动画厂画风、某一个第三方模型或某条内部命令路径写成全局默认。

## 3. 按模式阅读（先读对应文件，再动手）

### 模式 A：前期策划

读 [references/mode-a-planning.md](references/mode-a-planning.md)。产出按 [templates/creative-package.md](templates/creative-package.md) 组装。本阶段可以在分镜后停止，不擅自发起付费或第三方生成请求。

### 模式 B：电影感短片

读 [references/mode-b-cinematic.md](references/mode-b-cinematic.md)。提示词用 [templates/cinematic-prompt.md](templates/cinematic-prompt.md)（带时间轴的实战模板及 POV / 口播 / 多段变体）。连续性用**快照顺序接续**（如 `resume_from_snapshot_id`），不要与模式 C 的 Match Cut 混用。拼接用 [scripts/stitch_clips.sh](scripts/stitch_clips.sh)，抽帧用 [scripts/extract_frames.py](scripts/extract_frames.py)。完整短例见 [examples/mode-b-cinematic-example.md](examples/mode-b-cinematic-example.md)。

### 模式 C：动画短片 / IP 故事

读 [references/mode-c-animation.md](references/mode-c-animation.md)。先填 [templates/character-sheet.md](templates/character-sheet.md) 和 [templates/story-bible.md](templates/story-bible.md)，再按 [templates/animation-mega-prompt.md](templates/animation-mega-prompt.md) 写每场 mega prompt。连续性用 **Match Cut**：上一场末帧 = 下一场首帧，并且必须是同一个关键帧文件。完整短例见 [examples/mode-c-animation-example.md](examples/mode-c-animation-example.md)。

### 模式 D：执行后端（默认关闭）

只有用户明确同意某个执行通道后才读并启用 [references/mode-d-backend.md](references/mode-d-backend.md)。本包不附带、也不依赖任何第三方付费客户端或安装步骤。用户未指定后端时，停在提示词与策划交付，请用户在已授权的界面里生成。

## 4. 验收与交付

生成或拼接之后，按 [references/qa-checklist.md](references/qa-checklist.md) 检查，并用 [templates/delivery-notes.md](templates/delivery-notes.md) 写交付说明。

- 写清成片路径、画幅、时长、场次结构。
- 抽帧或关键帧对比中发现的人物漂移、画幅不一致、动作不成立、衔接跳动，如实记录。
- 音频策略（原片音轨、旁白、提示词内对白）和需要用户亲自听的部分单独列出。
- 策划包与生成结果分开交付；若只完成了策划，就明确到此为止。
- 可把本次有效的提示词、画幅、拆段方式和失败原因沉淀下来，不要把失败写成成功。

## 5. 许可

本包以 MIT 许可发布。流程与模板改编时保留 Mason Mosen、Đặng Hữu Sơn（sonlovinbot）、Jiang Yong Luo、useapi.net 的版权声明，详见 [LICENSE](LICENSE)。第三方服务的使用条款与收费以其当时规则为准，MIT 许可不覆盖这些服务本身。

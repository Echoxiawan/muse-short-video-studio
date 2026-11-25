# 模式 C：动画短片 / IP 故事

用于从零做有角色连续性的动画短片，交到带声音的成片。连续性靠 **Match Cut**（上一场末帧 = 下一场首帧，且必须是同一个关键帧文件），不要改用模式 B 的快照顺序接续。

配套文件：

- 角色表：[templates/character-sheet.md](../templates/character-sheet.md)
- 故事圣经：[templates/story-bible.md](../templates/story-bible.md)
- mega prompt：[templates/animation-mega-prompt.md](../templates/animation-mega-prompt.md)
- 抽帧与拼接：[scripts/extract_frames.py](../scripts/extract_frames.py)、[scripts/stitch_clips.sh](../scripts/stitch_clips.sh)
- 验收：[qa-checklist.md](qa-checklist.md)
- 短例：[examples/mode-c-animation-example.md](../examples/mode-c-animation-example.md)

## 阶段 0：先问三件事

没有这三项答案，不要开始画角色或写分场。

1. **片长**：按每场约 10 秒折算场次（向上取整）。例如约 40 秒 → 4 场。当场与用户确认场次数。
2. **成片语言**：决定旁白语言、脚本讨论语言和 VO 稿语言。
3. **画幅**：16:9 或 9:16 等。这不是最后再调的输出选项，它约束此后所有参考图。从第一问锁死，角色表、场景设定、关键帧、首尾帧必须同一比例；比例不对就重画，不准混用。

把下面这段英文（按实际画幅改括号内容）贴进本项目所有生图和生视频提示词：

```
STRICT ASPECT RATIO LOCK: The final output video MUST be exactly [16:9 landscape | 9:16 vertical]. All reference images — character sheets, context sheets, keyframes, first-frame and last-frame images — MUST share this exact aspect ratio. Reference images are not only style and character guides; they directly condition the output framing and composition. Any reference image with a mismatched aspect ratio MUST be regenerated or cropped to the locked ratio before use. NEVER mix aspect ratios within a single project.
```

合成时统一分辨率与帧率。文档化默认：16:9 用 1280×720，9:16 用 720×1280，24fps。用 `ffprobe` 在每个阶段核对，比例不对立即重做，不要带到下一阶段。

## 七个阶段（按顺序，不要跳）

### 1. 角色设定表

为每个主要角色画（或写清后请用户确认再画）角色设定表：多角度 + 若干表情特写，同一套服装与配色，干净中性背景，不要文字和水印。设定表必须是已锁定画幅。

描述要具体到颜色和每一件衣服、发型、识别特征。「一个穿蓝衣服的少年」会画出许多种蓝衣服；「navy double-breasted jacket with gold buttons, brown trousers, brown boots, rust-red scarf」才能作为可复用的锁定文本。

画风由用户或策划包决定，不要默认某一家动画工作室风格。文件名用 ASCII，例如 `kai-sheet-16x9.webp`。

### 2. 故事圣经（先锁定再画关键帧）

按 [templates/story-bible.md](../templates/story-bible.md) 写出 logline、角色锁定原文、世界与风格锁定、连续性规则，以及每一场的节拍、首帧、尾帧、旁白、音乐。角色锁定段必须详细到可以直接粘贴进后续提示词。

用户核准故事圣经之前，不要画关键帧。核准后再改剧情，通常意味着相关场次的关键帧和视频都要重做——没有「只改一小句」这种便宜事。

### 3. 关键帧 K1..K(N+1)

N 场对应 N+1 张关键帧：K1 是第 1 场首帧，K2 是第 1 场尾帧也是第 2 场首帧，依此类推，K(N+1) 是第 N 场尾帧。

**Match Cut 硬规则：第 N 场的尾帧和第 N+1 场的首帧必须是同一个文件**，不是「看起来差不多的两张图」，更不能等到剪辑阶段再补。在素材表里写清路径，例如第 1 场尾帧与第 2 场首帧都指向 `keyframes/k2-dock-lantern.webp`。

生成关键帧时，参考图加载顺序：先角色表，再写该帧描述（风格锁定和角色锁定从故事圣经原文粘贴）。检查画幅、是否还是同一个人、光线是否符合该场节拍。

### 4. 每场一份可复制即用的 mega prompt

结构固定为：`FIRST FRAME` / `MOTION` / `CAMERA` / `LAST FRAME` / `SOUND` / `MUSIC` / `VO`。全局锁定（画幅、风格、角色原文）贴在每场开头。完整填写方式见 [templates/animation-mega-prompt.md](../templates/animation-mega-prompt.md)。

`MOTION` 里的物理动作必须符合现实。写每一个动词之前问：现实里能这样发生吗？不要写做不到的动作（例如隔着未打开的玻璃罩去点灯）。需要点灯就写清：打开罩门 → 点燃灯芯 → 关上门。

### 5. 逐场生成视频

参考图加载顺序：**角色表 → 首帧 → 尾帧**，然后才是提示词文本。不要颠倒，颠倒后角色更容易漂。

每场生成后立刻检查：

- `ffprobe`：画幅、时长是否大约 10 秒
- 片头、片中、片尾抽帧，角色是否还对得上设定表
- 把本场尾帧旁边对照下一场首帧（二者本应来自同一文件，生成结果也应接近）
- 用 `ffprobe` 看原片是否已有音轨，记下来供合成阶段使用

同一镜头不要盲目重试超过 2–3 次。仍偏，回去改 mega prompt（通常是 `MOTION` 含糊、角色锁定不够，或动作不成立），不要把问题当成「再抽一次卡」。

在首尾帧已经共享的前提下，彼此独立的场次可以并行。这与模式 B 的快照必须顺序接续不同，不要混用。

生成命令使用当前环境里用户已授权的工具，或请用户在已授权的界面里生成。不要写死某个环境的内部路径，也不要默认开通第三方服务。若只能走用户确认过的执行通道，先进入模式 D 的同意流程。

### 6. 旁白

旁白是调味，不是主菜。大约覆盖全片 50%–60% 时长。每场开头 1–2 句，进点大约在开场后 1 秒，结束前约 2 秒留白。高潮场可以让画面自己呼吸，少写或不写旁白。

先写带时间码和语气说明的 VO 稿，再决定用用户指定的语音工具，或请用户外录。每条旁白的时长必须短于所在场次。听不见就不宣称「配音已经合格」。

### 7. 合成

1. 先检查原片是否已有音轨。有则保留，并在旁白下压低；不要假设原片静音。
2. **先统一分辨率和帧率，再拼接**，禁止先拼接后转码。
3. 用拼接脚本按场次顺序连接。由于 Match Cut，接缝应接近无形；若接缝处同一帧停留过久，可在拼接前略微修剪。
4. 按时间码混合旁白（第 N 场起始约为 `(N-1)×单场秒数`，旁白再延后约 1 秒）。
5. 用 `ffprobe` 核对成片宽高、帧率、是否同时有视频和音频、总时长是否接近预定场次之和。再按 [qa-checklist.md](qa-checklist.md) 抽帧和对照。

## 文件命名

从第一天就使用有含义的 ASCII 文件名，例如 `scene1-fading-light.mp4`，不要长期停留在工具自动生成的无意义长文件名上。

## 阶段 0 之后仍要记住的教训

- 先锁剧本，后画画。
- 角色描述越具体，后面越不容易漂。
- 角色表永远排在参考图列表的第一位。
- Match Cut 必须从关键帧阶段就设计好，剪辑补救不了连续性。
- 画幅从第一问锁定，设定表画错比例，后面的视频构图会跟着错。

---
改编说明：场次折算、画幅锁定、角色表与故事圣经、首尾帧同一文件的 Match Cut、mega prompt 结构、旁白比例与先规范后拼接，改编自 Đặng Hữu Sơn（sonlovinbot）的动画短片流程（MIT）。教训只保留方法，示例另写于本包 examples，不依赖任何外部剧本来运行。

# 模式 C 示例：码头铜铃（虚构四场动画）

这是一份可按本包流程跑通的虚构例子，用来演示：角色表、故事圣经、以及 **Match Cut 必须共用同一个关键帧文件**。不是已有影片的改编，画风由项目自定，不使用任何动画工作室作为默认风格。

## 阶段 0 已锁定

- 片长：约 40 秒 → 4 场
- 语言：普通话旁白，短句
- 画幅：16:9
- 画风：手绘 2D，沿海黄昏的低饱和色，边缘柔和，不要发光卡通描边

把画幅锁定英文段落贴进此后所有生图/生视频提示词，比例写 `16:9 landscape`。

## 角色锁定（可粘贴）

**Kai**，约 11 岁亚洲少年，码头钟室学徒：偏瘦偏小，黑发略长扫到眉上，耳后有一缕不被风吹乱的碎发；深蓝厚呢外套，第二颗纽扣是铜色、与其他铁色扣不配；锈红色围巾绕两圈，尾端有一处深色补丁；棕色短靴，靴尖有盐渍。性格安静，做事先动手后开口。

设定表文件（锁定 16:9，ASCII 名）：`character_sheets/kai-sheet-16x9.webp`

参考图加载顺序永远是：该设定表 → 本场首帧 → 本场尾帧。

## 关键帧地图（同一文件复用）

| 关键帧 | 文件 | 同时作为 |
|---|---|---|
| K1 | `keyframes/k1-pier-dusk.webp` | 第 1 场 FIRST FRAME |
| K2 | `keyframes/k2-clapper-still.webp` | 第 1 场 LAST FRAME **与** 第 2 场 FIRST FRAME |
| K3 | `keyframes/k3-oil-hinge.webp` | 第 2 场 LAST FRAME **与** 第 3 场 FIRST FRAME |
| K4 | `keyframes/k4-bell-swing.webp` | 第 3 场 LAST FRAME **与** 第 4 场 FIRST FRAME |
| K5 | `keyframes/k5-walk-away.webp` | 第 4 场 LAST FRAME |

注意：K2、K3、K4 各只存在**一个**文件。第 1 场的尾帧不是「另存一张很像的图」，而是直接把 `k2-clapper-still.webp` 交给第 2 场当首帧。

## 四场节拍

**第 1 场 — 不响的铃**
- Beat：发现
- First frame（K1）：黄昏码头，Kai 站在铜铃下，铃舌静止，远处海水铁灰
- Last frame（K2）：特写——Kai 的手托着静止的铃舌，油垢和盐壳清晰可见
- VO：「今年第一场北风来了，铃却还没醒。」

**第 2 场 — 上油**
- Beat：动手
- First frame（K2，同一文件）：同上，手托静止铃舌
- Last frame（K3）：他用小油瓶点在铰链上，第一滴油正好落在铜缝里，铃仍未摆动
- VO：「先油，再等风。」
- MOTION 现实性：先掀开铰链旁的防雨小盖，再点油，再盖回去；不要把油「穿过」闭合的盖子。

**第 3 场 — 第一响**
- Beat：醒来
- First frame（K3，同一文件）：油滴刚落入铜缝
- Last frame（K4）：铜铃被风推到半弧，铃舌刚离开边缘，发出第一响前的拉伸感
- VO：本场不写旁白，把时间交给风声和第一响。

**第 4 场 — 离开**
- Beat：交还
- First frame（K4，同一文件）：铜铃在半弧上
- Last frame（K5）：中全景，Kai 把围巾裹紧走下木梯，铜铃在前景继续摆，码头灯一盏盏亮起
- VO：「今晚归它值班。」

## 第 2 场 mega prompt 示例

其余三场按同一结构填写。注意 `FIRST FRAME` 和上一场 `LAST FRAME` 使用同一个文件名。

```
Hand-painted 2D animation, muted coastal dusk palette, soft edges, no studio-logo look,
in exactly 16:9 landscape 1280x720 aspect ratio,
no text, no watermark.
STRICT ASPECT RATIO LOCK: the output MUST be exactly 16:9 — the same
ratio locked in project intake. All attached references already share this
ratio; never introduce a mismatched one.
Character: Kai, about 11, slim East Asian boy, dark hair brushing his brows,
a navy peacoat with one mismatched copper button among iron buttons,
a rust-red scarf wrapped twice with a dark patch at the tail,
brown boots stained with salt.
Keep every character exactly on-model with the attached sheets in all frames.

FIRST FRAME: match keyframes/k2-clapper-still.webp. Close-up of Kai's hand
holding the still copper clapper, grease and salt crust visible, dusk light.

MOTION: Kai keeps the clapper steady with his left hand. His right hand first
flips open the small rain cap beside the hinge, then tilts a tiny oil bottle
so one drop falls into the copper seam, then closes the cap. The bell does
not swing yet. No oil passes through a closed cap. No impossible motion.

CAMERA: start tight on the hand and clapper, slow push toward the hinge as
the oil drop falls, hold. No whip pan.

LAST FRAME: match keyframes/k3-oil-hinge.webp. The oil drop has just settled
in the copper seam; the bell is still unmoving.

SOUND: distant low tide, a soft leather creak, one viscous drop, the tiny
click of the rain cap closing.

MUSIC: a single low string holds, no melody yet.

VO (narrator): "先油，再等风。"
```

参考图顺序：`kai-sheet-16x9.webp` → `k2-clapper-still.webp` → `k3-oil-hinge.webp`。

## 生成、旁白与合成要点

- 在 K1–K5 都已画好且画幅正确的前提下，四场可以并行生成；不要改用快照顺序接续。
- 同一场不要盲目重试超过 2–3 次；仍偏就改 `MOTION` 或角色锁定。
- 每场先 `ffprobe` 看画幅、时长和是否已有音轨。
- 旁白大约覆盖全片一半多一点：第 3 场故意留白，不要用旁白填满。
- 先把四段规范到 1280×720、24fps，再拼接：

```bash
bash scripts/stitch_clips.sh -a 16:9 -o harbour-bell-full.mp4 \
  scene1-silent-bell.mp4 scene2-oil-hinge.mp4 \
  scene3-first-swing.mp4 scene4-walk-away.mp4

python3 scripts/extract_frames.py scene1-silent-bell.mp4 --junction scene1-ends
python3 scripts/extract_frames.py scene2-oil-hinge.mp4 --junction scene2-ends
```

把第 1 场尾帧与第 2 场首帧并排对照：两端都应该接近 `k2-clapper-still.webp`。音频、第一响的时间点和旁白语气交给用户终验。

---
本示例为原创虚构情节，仅用于演示本包模式 C 的 Match Cut 文件复用。

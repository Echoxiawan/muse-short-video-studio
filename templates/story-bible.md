# 故事圣经模板（模式 C）

这是动画短片的「宪法」。用户核准本文件之前，不要画关键帧。场次数在阶段 0 按「片长 ÷ 约 10 秒」向上取整后写入，不要在这里重新讨价还价，只需确认。

```markdown
# [片名] — Story Bible

- 画幅：[16:9 | 9:16]（已锁定）
- 成片语言：
- 场次数：N（约 N×10 秒）
- 画风：

## Logline

[一句话：谁，想要什么，遇到什么障碍，付出什么代价或得到什么改变]

## Characters (CANONICAL LOCK — 逐字粘贴进所有相关提示词)

- **[Name]**（年龄，角色）：[外形逐件描述 + 性格 + 本片弧光]
  设定表文件：`character_sheets/[name]-sheet-[16x9|9x16].webp`

## World & Style Lock

- 世界与地点：
- 时代与气氛：
- 视觉风格（项目自定，不写默认片厂）：
- 技术规格：画幅已锁定；合成默认 16:9 用 1280×720，9:16 用 720×1280，24fps
- 声音与音乐方向：
- 旁白原则：调味不是主菜；大约覆盖 50%–60% 时长；每场开头 1–2 句；高潮场可沉默

## Continuity Rule

**Last frame of Scene N = first frame of Scene N+1, and they MUST be the same keyframe file (match cut).**

## Keyframe map

| 关键帧 | 文件（ASCII） | 同时作为 |
|---|---|---|
| K1 | `keyframes/k1-....webp` | Scene 1 FIRST FRAME |
| K2 | `keyframes/k2-....webp` | Scene 1 LAST FRAME 与 Scene 2 FIRST FRAME（同一文件） |
| K3 | `keyframes/k3-....webp` | Scene 2 LAST FRAME 与 Scene 3 FIRST FRAME（同一文件） |
| K(N+1) | `keyframes/k[N+1]-....webp` | Scene N LAST FRAME |

## Scene 1 — "[场名]"

- Beat（情绪）：
- First frame：K1 — [描述] — 文件 `keyframes/k1-....webp`
- Last frame：K2 — [描述] — 文件 `keyframes/k2-....webp`
- VO："[1–2 句]"
- Music：
- 备注（动作现实性、必须出现的道具）：

## Scene 2 — "[场名]"

- Beat：
- First frame：K2 — [必须复用上一场尾帧的同一文件]
- Last frame：K3 — 文件 `keyframes/k3-....webp`
- VO：
- Music：
```

按场次复制「Scene N」一节直到 N。任何跨场共享的关键帧只给一个文件名。

## 核准栏

- [ ] 用户已确认 logline、场次数、画幅、语言和画风
- [ ] 角色锁定已具体到可粘贴
- [ ] 每场都有首帧、尾帧描述和对应文件名
- [ ] 相邻场次的共享帧指向同一文件
- [ ] 核准日期与版本：

---
改编说明：故事圣经结构与「先锁定再画关键帧」，改编自 Đặng Hữu Sơn（sonlovinbot）的剧本阶段（MIT）。

# 角色设定表模板（模式 C，模式 A 若有稳定角色也可共用）

每个主要角色一份。先请用户核准文字锁定，再生成或绘制设定图。设定图必须与项目画幅一致，文件名使用 ASCII。

## 文字锁定（可直接粘贴进提示词）

```markdown
# Character lock — [NameASCII]

- 姓名：
- 年龄 / 身份：
- 体型与身高比例：
- 脸型与五官（具体到眉、眼、鼻、口、肤色、显著标记）：
- 发型与发色（颜色、长度、分线、是否束起）：
- 服装（逐件写出名称、颜色、材质、配件）：
- 常用道具：
- 识别特征（必须每次出现的标记，如补丁、疤、特定围巾）：
- 性格关键词（供表演，不代替外形描述）：
- 画风（项目锁定的风格，不要填默认片厂名）：
- 画幅：[16:9 | 9:16]
```

设定图提示词可用英文写，例如：

```
Character reference sheet, [16:9 landscape | 9:16 vertical] orientation,
[project style lock], clean consistent proportions.
STRICT ASPECT RATIO LOCK: the sheet MUST be exactly [16:9 | 9:16].
Character: [paste the character lock in English or bilingual detail]
Show: front view, side view, back view, 3/4 view, plus 3 expression close-ups
(happy, sad, determined). Same outfit and colors in every view.
Plain soft neutral background, no text, no watermark.
```

## 核对

- [ ] 用户已核准文字锁定，中途不再改关键外形
- [ ] 设定图是锁定画幅，多角度服装和颜色一致，背景干净无字
- [ ] 文件路径已登记，例如 `character_sheets/kai-sheet-16x9.webp`
- [ ] 之后所有生图/生视频都把本设定表放在参考图第一位

---
改编说明：多角度设定表与「描述必须具体到单件服装」的锁定方法，改编自 Đặng Hữu Sơn（sonlovinbot）的角色表流程（MIT）。

# 論文執筆 AI スキル (Research Paper Writing Skills)

> 🌐 **言語 / Languages**: [English](./README.md) | [中文](./README_zh.md) | [Bahasa Indonesia](./README_id.md) | [العربية](./README_ar.md) | **日本語**

研究者のための、AIを活用した学術論文執筆アシスタントです。

難しいツールの操作やコマンドを覚える必要はありません。**普段通りAIエディタを開いて、論文について質問するだけ**。裏側で自動的に最適な執筆アシスタントが働き、トップカンファレンスや学術誌に通用する論理構成・推敲をサポートします。

---

## 🎓 研究者にとってのメリット

本ツールは単なる文章の言い換えや一般的な文章生成ツールではありません。学術論文特有の「採択されるためのルール」に基づいてAIが支援します。

- 🛡️ **査読（Peer Review）で落とされない論理構成**  
  「主張（Claim）」に対して「根拠（Evidence）」がしっかり対応しているかを厳しくチェックします。査読者から突っ込まれやすい論理の飛躍や根拠不足を事前に見つけ出します。
- 📑 **セクションごとの最適な「型」に沿った執筆**  
  アブストラクト（抄録）、序論（Introduction）、手法（Method）、実験・評価（Experiments）、結論（Conclusion）それぞれに最適な論理展開のテンプレートを提供します。
- 🌊 **自然で説得力のある文章の流れ**  
  「なぜ今この説明が必要なのか」という読者の思考の流れを整え、ストレスなく読める構成にブラッシュアップします。
- 🤖 **裏側で完全に自動サポート**  
  特別なプラグインの起動操作などは一切不要です。いつものAIエディタで対話するだけで、AIが自動的に学術論文の基準を適用します。
- 🧠 **長期的な執筆でも文脈を保持**  
  何日にもわたる論文執筆でも、論文の核となる主張や用語設定をAIが忘れずに引き継ぎます。

---

## ⚡ たった3ステップの初期設定（初回のみ）

最初の一度だけ設定すれば、次回以降は何も意識せずに使えます。お使いのOSに合わせてコマンドをコピー＆ペーストしてください。

### Windows (PowerShell) の場合

PowerShellを開き、以下のコマンドを順番に実行してください。

#### ステップ 1: ダウンロード
```powershell
git clone https://github.com/gibrandevlab/Research-Paper-Writing-Skills.git
cd Research-Paper-Writing-Skills
```

#### ステップ 2: お使いのAIツールへ登録
お使いの環境に合わせて、必要なものを実行してください（複数可）。

- **Gemini をお使いの場合**:
  ```powershell
  xcopy /E /I research-paper-writing "%USERPROFILE%\.gemini\skills\research-paper-writing"
  ```
- **Claude Code（グローバル）をお使いの場合**:
  ```powershell
  xcopy /E /I research-paper-writing "%USERPROFILE%\.claude\skills\research-paper-writing"
  ```
- **Cursor / Cline / Copilot をお使いの場合**:
  ダウンロードした `Research-Paper-Writing-Skills` フォルダをご自身の論文フォルダに配置するか、エディタでこのフォルダを開くだけで自動的に読み込まれます。

#### ステップ 3: 完了！
これでセットアップは終了です。エディタを開いてすぐに使い始められます。

---

### Mac / Linux (ターミナル / bash) の場合

ターミナルを開き、以下のコマンドを順番に実行してください。

#### ステップ 1: ダウンロード
```bash
git clone https://github.com/gibrandevlab/Research-Paper-Writing-Skills.git
cd Research-Paper-Writing-Skills
```

#### ステップ 2: お使いのAIツールへ登録
お使いの環境に合わせて、必要なものを実行してください（複数可）。

- **Gemini をお使いの場合**:
  ```bash
  cp -R research-paper-writing ~/.gemini/skills/
  ```
- **Claude Code（グローバル）をお使いの場合**:
  ```bash
  cp -R research-paper-writing ~/.claude/skills/
  ```
- **Cursor / Cline / Copilot をお使いの場合**:
  ダウンロードした `Research-Paper-Writing-Skills` フォルダをご自身の論文フォルダに配置するか、エディタでこのフォルダを開くだけで自動的に読み込まれます。

#### ステップ 3: 完了！
これでセットアップは終了です。エディタを開いてすぐに使い始められます。

---

## ✍️ 日々の使い方

**普段通りAIエディタを開いて、論文について質問するだけです。**  
システムが裏側で静かに動作し、学術論文の基準に沿った回答を作成します。

### 質問・指示の例（そのまま使えます）

- **序論（Introduction）の作成・推敲**
  > 「この研究の目的、課題、提案手法の概要をメモしました。これをもとに、トップカンファレンス向けの説得力あるIntroductionを書いてください。」
- **査読者視点でのチェック**
  > 「このMethodとExperimentsの草稿を厳しい査読者の視点でレビューしてください。根拠が弱い主張や、追加で必要な比較実験があれば指摘してください。」
- **アブストラクトの推敲**
  > 「書いたアブストラクトを学術的な標準構成（背景、課題、提案手法、主な結果、意義）に沿って磨き上げてください。」
- **文章の流れ（Flow）の改善**
  > 「第2段落から第3段落への話のつながりが不自然に感じます。読者がスムーズに理解できるように論理を整理してください。」
- **実験結果の解説**
  > 「この評価テーブルの結果をもとに、提案手法の強みとベースラインに対する優位性を明確に説明する文章を作成してください。」

---

## 🛠️ 対応しているAIツール

お気に入りのAIエディタやツールでそのままご利用いただけます：

- **Cursor**
- **Claude Code**
- **Cline**
- **GitHub Copilot**
- **Gemini**
- **OpenAI Codex**

---

## 🙏 クレジットと謝辞

- **方法論・知見の原典**: **彭思达 (Prof. Peng Sida)** 先生
  - 公開学習ノート: [Prof. Peng Sida's Study Notes](https://pengsida.notion.site/c1a22465a0fa4b15a12985223916048e)
  - 原典リポジトリ: [pengsida/learning_research](https://github.com/pengsida/learning_research)
  - 貴重な研究・執筆の知見を公開してくださった彭思达先生に心より感謝申し上げます。
- **オリジナル Skills パッケージ**: **Master-cai** 氏
  - リポジトリ: [Master-cai/Research-Paper-Writing-Skills](https://github.com/Master-cai/Research-Paper-Writing-Skills)
- **マルチエージェント対応・管理拡張**: **Afwan Gibran Muhammad Algiffari** ([gibrandevlab](https://github.com/gibrandevlab/Research-Paper-Writing-Skills))

---

## 📄 ライセンス

本プロジェクトは [MIT License](./LICENSE) のもとで公開されています。

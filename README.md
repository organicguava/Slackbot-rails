
# SlackBot Rails 專案

## 專案簡介

本專案是一個Ruby on Rails 應用程式，目標是自動化統計每日專案進度，並將彙報推送至 Slack。系統支援多專案管理，整合 Redmine、GitLab、Slack 與 Google Gemini LLM，並以 Docker 容器化部署。

### 架構圖
```
┌─────────────────────────────────────────────────────────────────┐
│                    每日自動執行                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐                 │
│   │ Redmine  │    │  GitLab  │    │  Slack   │                 │
│   │  Issues  │    │ Commits  │    │ History  │                 │
│   └────┬─────┘    └────┬─────┘    └────┬─────┘                 │
│        │               │               │                        │
│        └───────────────┼───────────────┘                        │
│                        ▼                                        │
│              ┌─────────────────┐                                │
│              │  Google Gemini  │                                │
│              │   LLM 總結      │                                │
│              └────────┬────────┘                                │
│                       ▼                                         │
│              ┌─────────────────┐                                │
│              │  Slack Webhook  │                                │
│              │   發送報告      │                                │
│              └─────────────────┘                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

```

---

## 技術堆疊

- Ruby 3.4.7
- Rails 8.1.1
- PostgreSQL 16
- Node.js 25.2.1
- GoodJob (背景任務排程)
- Faraday (HTTP Client)
- Slack-Ruby-Client (Slack API)
- RSpec, FactoryBot, Faker, Webmock, VCR, Shoulda-Matchers, SimpleCov (測試)
- TailwindCSS, Hotwire (Turbo + Stimulus)
- Docker / Docker Compose

---

## 初始化步驟

1. 設定 `config/database.yml`，確認 PostgreSQL 連線資訊。
2. 執行 `bin/rails db:create` 建立資料庫。
3. 編輯 `Gemfile`，安裝核心 gems：good_job, faraday, slack-ruby-client, rspec-rails 等。
4. 執行 `bundle install` 安裝套件。
5. 設定 credentials：
	- 執行 `EDITOR="code --wait" bin/rails credentials:edit` 或 `EDITOR="nano" bin/rails credentials:edit`
	- 填入 Slack、GitLab、Redmine、Gemini API 金鑰
6. 執行 `bin/rails generate rspec:install` 初始化 RSpec
7. 執行 `bin/rails generate good_job:install` 並 `bin/rails db:migrate` 安裝 GoodJob

---

## API Token 設定

### Slack Bot
- OAuth Scopes: `channels:history`, `channels:read`, `chat:write`
- Bot Token: OAuth & Permissions 頁面取得
- Signing Secret: Basic Information 頁面取得
- Webhook URL: Incoming Webhooks 頁面啟用後取得

### GitLab
- Personal Access Token
- Expiration: 建議一年以上
- Scopes: 只勾選 `read_api`

### Redmine
- API Key: 於 My Account 頁面取得

### Google Gemini
- API Key: 於 Google AI Studio 取得



---

## 技術分享

請參考 `docs/DevelopSharing.md`



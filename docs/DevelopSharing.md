
# GitLab Events API 技術簡介

## 什麼是 Events API？

GitLab Events API 提供一個 RESTful 介面，讓你可以查詢「誰、在什麼時候、對專案做了什麼事」。
這些事件涵蓋 Push、Merge、Comment、Issue、Branch 操作等，是自動化專案統計、活動追蹤、報表產生的基礎。

## 主要用途

- 取得專案的「活動紀錄」(Activity Feed)
- 統計每日 Push、Merge、Comment 等行為
- 追蹤團隊貢獻、產生自動化進度摘要
- 整合 LLM/AI 進行智慧總結

## 主要 API 路徑

- **List all events**  
    `GET /events`  
    取得目前使用者的所有事件（跨專案）

- **List project events**  
    `GET /projects/:id/events`  
    取得指定專案的所有事件（最常用於專案統計）

## 回傳資料結構

每個 event 會包含：
- `action_name`：事件動作（如 pushed to、accepted、commented on、deleted）
- `author`：觸發事件的使用者
- `created_at`：事件發生時間
- `target_type`：目標類型（如 Commit、MergeRequest、Issue）
- 其他與事件相關的欄位

## 常見 action_name 與對應行為

| action_name   | 說明                |
|---------------|---------------------|
| pushed to     | Push 代碼           |
| accepted      | Merge Request 合併  |
| commented on  | 留言                |
| deleted       | 刪除分支            |

## 權限與認證

- 需帶上 Personal Access Token（建議 scope: `read_api`）
- 只會回傳你有權限存取的專案事件

## 實務應用

- 每日自動統計專案進度
- 產生 Slack/Email 報表
- 作為 LLM（如 Gemini、GPT）自動摘要的資料來源
- 追蹤團隊貢獻、分析開發節奏

## 技術重點

- 支援分頁與時間篩選（可用於每日/每週統計）
- 回傳資料結構穩定，適合自動化處理
- 可與 Redmine、Slack 等其他平台資料整合

## 官方文件

- [GitLab Events API 官方說明](https://docs.gitlab.com/ee/api/events.html)

# GitLab 與 Slack API Token 取得與權限設定


## GitLab Personal Access Token
1. 什麼是 Personal Access Token？
一組用戶專屬的 API 金鑰，可用於自動化腳本、CI/CD、第三方服務存取 GitLab API。
權限細緻，可控有效期限，安全性高於帳號密碼。

2. 取得步驟
登入 GitLab，點右上角頭像 → Edit Profile → Access Tokens。
輸入 Token 名稱（建議專案/用途命名），設定 Expiration（建議一年以上）。
目前只勾選 read_api 權限（最小權限原則，僅供讀取 MR、Commit、Issue 等）。
產生後務必複製保存，因為只會顯示一次。

3. 實務建議
一人一 Token，勿共用。
權限只開啟需要的（如只讀資料就只勾 read_api）。
Token 遺失或外洩，立即註銷重建。

## Slack API Token（Bot Token）
1. 什麼是 Slack Bot Token？

    讓自家 App/機器人能以「Bot 身份」存取 Slack API，發送訊息、讀取頻道、互動自動化。
格式通常為 xoxb-...。

2. 取得步驟
    * 前往 Slack API: Your Apps，建立新 App。
    * 在 OAuth & Permissions 頁面，新增下列 Scopes：
        * chat:write（發送訊息）
        * channels:history（讀取公開頻道訊息）
        * channels:read（讀取頻道列表）
    * 點擊「Install to Workspace」安裝 App，授權後會產生 Bot User OAuth Token（即 Bot Token）。
    * 於 Basic Information 頁面取得 Signing Secret。
    * Incoming Webhooks 頁面啟用並取得 Webhook URL。

3. 實務建議
    * Bot Token 權限要精簡，避免開過多權限。
    * Webhook 適合單向推播，Bot Token 適合雙向互動。
    * Token 不寫死在程式，建議用 Rails credentials 或環境變數管理。

  

----   

# **新引入套件用途整理**

### Slack Bot Essentials

| Gem | 版本 | 用途 |
| --- | --- | --- |
| `slack-ruby-client` | 3.1.0 | **Slack API 官方 Ruby Client**
• 發送訊息到頻道 (chat.postMessage)
• 讀取頻道歷史訊息 (conversations.history)
• 支援 Block Kit 格式
• 支援 Socket Mode (即時互動) |
| `faraday` | 2.14.0 | **通用 HTTP Client**
•呼叫 Redmine API
• 呼叫 GitLab API
• 呼叫 Google Gemini API
• 支援 middleware (retry, logging) |

### Background Jobs

| Gem | 版本 | 用途 |
| --- | --- | --- |
| `good_job` | 4.13.1 | **PostgreSQL-based Job Queue**<br>• 每日排程 (cron: `30 18 * * 1-5`)<br>• 背景執行 API 呼叫<br>• 內建 Dashboard UI<br>• 不需要 Redis！直接用 PostgreSQL |
| `solid_queue` | 1.2.4 | **Rails 8 內建 Job Queue** (已存在)<br>• 與 GoodJob 功能類似<br>• 可擇一使用或並用 |

### Testing

| `webmock` | 3.26.1 | Mock HTTP 請求 (測試 API 呼叫) |
| --- | --- | --- |
| `vcr` | 6.4.0 | 錄製/重播 HTTP 請求 |
| `shoulda-matchers` | 7.0.1 | Model/Controller 測試 matchers |
| `simplecov` | 0.22.0 | 測試覆蓋率報告 |




/**
 * PMBOK プロジェクト管理 - Google Apps Script 自動化
 *
 * セットアップ手順:
 *   1. スプレッドシートを開く → 拡張機能 → Apps Script
 *   2. このファイルの内容を全てコピー＆ペースト
 *   3. 保存 → setupTriggers() を実行（初回のみ）
 *   4. 権限を承認
 *
 * 自動化機能:
 *   - 期限3日前の自動メール通知（毎朝9時）
 *   - 遅延タスクの自動ハイライト通知
 *   - ステータス変更時の自動タイムスタンプ更新
 *   - Dashboard KPI の自動更新
 */

// ========================================
// 設定
// ========================================
const CONFIG = {
  // 通知メールの送信先（空欄の場合はスプレッドシートのオーナー）
  notifyEmail: '',
  // 期限通知の日数（何日前に通知するか）
  deadlineWarningDays: 3,
  // WBSシート名
  wbsSheet: 'WBS',
  // リスク管理シート名
  raidSheet: 'リスク管理',
  // 課題管理シート名
  issueSheet: '課題管理',
  // ダッシュボードシート名
  dashboardSheet: 'ダッシュボード',
};

// ========================================
// トリガー設定（初回のみ実行）
// ========================================
function setupTriggers() {
  // 既存トリガーを削除
  const triggers = ScriptApp.getProjectTriggers();
  triggers.forEach(trigger => ScriptApp.deleteTrigger(trigger));

  // 毎朝9時に期限チェック
  ScriptApp.newTrigger('checkDeadlines')
    .timeBased()
    .everyDays(1)
    .atHour(9)
    .create();

  // 編集時にタイムスタンプ更新
  ScriptApp.newTrigger('onEditHandler')
    .forSpreadsheet(SpreadsheetApp.getActive())
    .onEdit()
    .create();

  Logger.log('トリガー設定完了');
}

// ========================================
// 期限チェック＆通知（毎朝自動実行）
// ========================================
function checkDeadlines() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const warnings = [];

  // WBS の期限チェック
  warnings.push(...checkWbsDeadlines(ss));

  // リスク管理の期限チェック
  warnings.push(...checkRaidDeadlines(ss));

  // 課題管理の期限チェック（期日列なし、ステータスベースで管理）

  if (warnings.length > 0) {
    sendNotification(ss, warnings);
  }
}

/**
 * WBS の期限チェック
 */
function checkWbsDeadlines(ss) {
  const sheet = ss.getSheetByName(CONFIG.wbsSheet);
  if (!sheet) return [];

  const data = sheet.getDataRange().getValues();
  const warnings = [];
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // ヘッダー行をスキップ（2行目から）
  for (let i = 2; i < data.length; i++) {
    const row = data[i];
    const taskName = row[2]; // C列: タスク名
    const assignee = row[3]; // D列: 担当者
    const endDate = row[5];  // F列: 終了日
    const status = row[6];   // G列: ステータス

    if (!endDate || !taskName || status === '完了' || status === '中止') continue;

    const deadline = new Date(endDate);
    deadline.setHours(0, 0, 0, 0);
    const daysLeft = Math.ceil((deadline - today) / (1000 * 60 * 60 * 24));

    if (daysLeft < 0) {
      warnings.push({
        type: '遅延',
        icon: '🔴',
        sheet: 'WBS',
        item: taskName.trim(),
        assignee: assignee || '未割当',
        detail: `${Math.abs(daysLeft)}日超過`,
      });
    } else if (daysLeft <= CONFIG.deadlineWarningDays) {
      warnings.push({
        type: '期限間近',
        icon: '🟡',
        sheet: 'WBS',
        item: taskName.trim(),
        assignee: assignee || '未割当',
        detail: `残り${daysLeft}日`,
      });
    }
  }

  return warnings;
}

/**
 * リスク管理の期限チェック
 */
function checkRaidDeadlines(ss) {
  const sheet = ss.getSheetByName(CONFIG.raidSheet);
  if (!sheet) return [];

  const data = sheet.getDataRange().getValues();
  const warnings = [];
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  for (let i = 2; i < data.length; i++) {
    const row = data[i];
    const raidType = row[1]; // B列: 種別
    const title = row[2];    // C列: タイトル
    const assignee = row[5]; // F列: 担当者
    const status = row[6];   // G列: ステータス
    const dueDate = row[7];  // H列: 期日

    if (!dueDate || !title || status === 'Closed') continue;

    const deadline = new Date(dueDate);
    deadline.setHours(0, 0, 0, 0);
    const daysLeft = Math.ceil((deadline - today) / (1000 * 60 * 60 * 24));

    if (daysLeft < 0) {
      warnings.push({
        type: '遅延',
        icon: '🔴',
        sheet: `リスク管理 (${raidType})`,
        item: title,
        assignee: assignee || '未割当',
        detail: `${Math.abs(daysLeft)}日超過`,
      });
    } else if (daysLeft <= CONFIG.deadlineWarningDays) {
      warnings.push({
        type: '期限間近',
        icon: '🟡',
        sheet: `リスク管理 (${raidType})`,
        item: title,
        assignee: assignee || '未割当',
        detail: `残り${daysLeft}日`,
      });
    }
  }

  return warnings;
}


// ========================================
// メール通知
// ========================================
function sendNotification(ss, warnings) {
  const email = CONFIG.notifyEmail || Session.getActiveUser().getEmail();
  const ssName = ss.getName();
  const ssUrl = ss.getUrl();

  const overdueCount = warnings.filter(w => w.type === '遅延').length;
  const upcomingCount = warnings.filter(w => w.type === '期限間近').length;

  const subject = `[PM通知] ${ssName}: ${overdueCount > 0 ? `遅延${overdueCount}件` : ''}${overdueCount > 0 && upcomingCount > 0 ? ' / ' : ''}${upcomingCount > 0 ? `期限間近${upcomingCount}件` : ''}`;

  let body = `プロジェクト: ${ssName}\n`;
  body += `確認日時: ${Utilities.formatDate(new Date(), 'Asia/Tokyo', 'yyyy/MM/dd HH:mm')}\n`;
  body += `スプレッドシート: ${ssUrl}\n\n`;

  if (overdueCount > 0) {
    body += '=== 遅延 ===\n';
    warnings.filter(w => w.type === '遅延').forEach(w => {
      body += `${w.icon} [${w.sheet}] ${w.item} (担当: ${w.assignee}) - ${w.detail}\n`;
    });
    body += '\n';
  }

  if (upcomingCount > 0) {
    body += '=== 期限間近 ===\n';
    warnings.filter(w => w.type === '期限間近').forEach(w => {
      body += `${w.icon} [${w.sheet}] ${w.item} (担当: ${w.assignee}) - ${w.detail}\n`;
    });
  }

  MailApp.sendEmail({
    to: email,
    subject: subject,
    body: body,
  });

  Logger.log(`通知送信完了: ${warnings.length}件 → ${email}`);
}

// ========================================
// 編集時の自動処理
// ========================================
function onEditHandler(e) {
  if (!e || !e.range) return;

  const sheet = e.range.getSheet();
  const sheetName = sheet.getName();

  // リスク管理: ステータス変更時に更新日を自動設定
  if (sheetName === CONFIG.raidSheet) {
    onRaidLogEdit(e, sheet);
  }

  // WBS: ステータスを「完了」にしたら進捗100%に自動設定
  if (sheetName === CONFIG.wbsSheet) {
    onWbsEdit(e, sheet);
  }

  // 課題管理: ステータス変更のみ監視（期日列なし）
  // 新列構成: A=NO, B=工程, C=カテゴリ, D=課題内容, E=ステータス, F=起票日, G=起票者, H=担当, I=結論, J=Slack URL
}

/**
 * リスク管理 編集時: 更新日の自動設定
 */
function onRaidLogEdit(e, sheet) {
  const row = e.range.getRow();
  const col = e.range.getColumn();

  // ヘッダー行はスキップ
  if (row <= 2) return;

  // 更新日列（K列=11）を自動更新
  const updateDateCol = 11;
  sheet.getRange(row, updateDateCol).setValue(new Date());
}

/**
 * WBS 編集時: ステータス連動
 */
function onWbsEdit(e, sheet) {
  const row = e.range.getRow();
  const col = e.range.getColumn();

  // ヘッダー行はスキップ
  if (row <= 2) return;

  // G列（ステータス）が変更された場合
  if (col === 7) {
    const newStatus = e.value;
    const progressCol = 8; // H列: 進捗%

    if (newStatus === '完了') {
      sheet.getRange(row, progressCol).setValue(1); // 100%
    } else if (newStatus === '未着手') {
      sheet.getRange(row, progressCol).setValue(0); // 0%
    }
  }

  // E列（開始日）またはF列（終了日）が変更された場合、ガントバー数式を自動展開
  if (col === 5 || col === 6) {
    fillGanttFormulas(sheet, row);
  }
}


/**
 * 指定行にガントバー数式を自動展開（K列〜）
 * セルの値: Epic=3, Story=2, Task=1（条件付き書式で色分け）
 */
function fillGanttFormulas(sheet, row) {
  const ganttStartCol = 11; // K列
  const ganttCols = 61;     // 61日分

  const formulas = [];
  for (let i = 0; i < ganttCols; i++) {
    const colLetter = getColumnLetter(ganttStartCol + i);
    formulas.push(
      `=IF(AND(${colLetter}$2>=$E${row},${colLetter}$2<=$F${row}),IF($B${row}="Epic",3,IF($B${row}="Story",2,1)),"")`
    );
  }

  sheet.getRange(row, ganttStartCol, 1, ganttCols).setFormulas([formulas]);
}

/**
 * 列番号からA1表記の列文字を返す（1=A, 26=Z, 27=AA, ...）
 */
function getColumnLetter(colNum) {
  let letter = '';
  let num = colNum;
  while (num > 0) {
    num--;
    letter = String.fromCharCode(65 + (num % 26)) + letter;
    num = Math.floor(num / 26);
  }
  return letter;
}

// ========================================
// Dashboard 手動更新（必要に応じて実行）
// ========================================
function refreshDashboard() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const dashboard = ss.getSheetByName(CONFIG.dashboardSheet);
  if (!dashboard) return;

  // 数式は自動再計算されるため、最終更新時刻のみ更新
  // F1セルに現在時刻を設定
  dashboard.getRange('F1').setValue(new Date());

  Logger.log('Dashboard更新完了');
}

// ========================================
// ユーティリティ: 手動で期限チェックを実行
// ========================================
function manualCheckDeadlines() {
  checkDeadlines();
  SpreadsheetApp.getUi().alert('期限チェックが完了しました。メールを確認してください。');
}

// ========================================
// カスタムメニュー追加
// ========================================
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('PM Tools')
    .addItem('期限チェック（手動実行）', 'manualCheckDeadlines')
    .addItem('Dashboard更新', 'refreshDashboard')
    .addSeparator()
    .addItem('トリガー再設定', 'setupTriggers')
    .addToUi();
}

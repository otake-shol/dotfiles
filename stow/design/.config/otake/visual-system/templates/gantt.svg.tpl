<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">ガントチャートのテンプレート</title>
  <desc id="desc">担当、期間、進捗、状態を一つの時間軸で確認する。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="120" height="36" rx="18" fill="{{color.wine}}"/>
  <text data-slot="eyebrow" x="124" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">GANTT</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">工程と担当を、一つの時間軸で見通す</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">CSVまたはJSONを入力し、実データで描画する。</text>
  <g transform="translate(64 222)">
    <text x="0" y="0" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.caption}}" font-weight="700">TASK</text>
    <text x="220" y="0" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.caption}}" font-weight="700">OWNER</text>
    <text x="360" y="0" fill="{{color.inkSub}}" font-family="{{font.numeric}}" font-size="{{type.caption}}">8/01</text>
    <text x="700" y="0" fill="{{color.inkSub}}" font-family="{{font.numeric}}" font-size="{{type.caption}}">8/15</text>
    <text x="1056" y="0" text-anchor="end" fill="{{color.inkSub}}" font-family="{{font.numeric}}" font-size="{{type.caption}}">8/31</text>
    <path d="M350 12V322M700 12V322M1072 12V322" stroke="{{color.rule}}" stroke-width="{{stroke.hairline}}"/>
    <g font-family="{{font.body}}" font-size="{{type.label}}">
      <text x="0" y="55" fill="{{color.ink}}" font-weight="700">要件整理</text><text x="220" y="55" fill="{{color.inkSub}}">PM</text>
      <rect x="350" y="34" width="220" height="28" rx="10" fill="{{color.mint}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text x="1058" y="55" text-anchor="end" fill="{{color.mint}}" font-size="{{type.caption}}" font-weight="700">完了 100%</text>
      <text x="0" y="113" fill="{{color.ink}}" font-weight="700">デザイン</text><text x="220" y="113" fill="{{color.inkSub}}">Design</text>
      <rect x="500" y="92" width="260" height="28" rx="10" fill="{{color.primaryWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <rect x="500" y="92" width="170" height="28" rx="10" fill="{{color.primary}}"/>
      <text x="1058" y="113" text-anchor="end" fill="{{color.primary}}" font-size="{{type.caption}}" font-weight="700">進行中 65%</text>
      <text x="0" y="171" fill="{{color.ink}}" font-weight="700">実装</text><text x="220" y="171" fill="{{color.inkSub}}">Dev</text>
      <rect x="650" y="150" width="310" height="28" rx="10" fill="{{color.violetWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text x="1058" y="171" text-anchor="end" fill="{{color.violet}}" font-size="{{type.caption}}" font-weight="700">予定 0%</text>
      <text x="0" y="229" fill="{{color.ink}}" font-weight="700">結合テスト</text><text x="220" y="229" fill="{{color.inkSub}}">QA</text>
      <rect x="820" y="208" width="160" height="28" rx="10" fill="{{color.coralWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <rect x="820" y="208" width="45" height="28" rx="10" fill="{{color.coral}}"/>
      <text x="1058" y="229" text-anchor="end" fill="{{color.coral}}" font-size="{{type.caption}}" font-weight="700">要対応 28%</text>
      <text x="0" y="287" fill="{{color.ink}}" font-weight="700">公開</text><text x="220" y="287" fill="{{color.inkSub}}">PM</text>
      <polygon points="1000,252 1014,266 1000,280 986,266" fill="{{color.mango}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text x="1058" y="287" text-anchor="end" fill="{{color.inkSub}}" font-size="{{type.caption}}" font-weight="700">MILESTONE</text>
    </g>
  </g>
  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

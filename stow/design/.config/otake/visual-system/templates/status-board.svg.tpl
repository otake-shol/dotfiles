<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">週次ステータスボードのテンプレート</title>
  <desc id="desc">全体状況、進捗、マイルストーン、阻害要因、次の行動を一枚で共有する。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="174" height="36" rx="18" fill="{{color.mint}}"/>
  <text data-slot="eyebrow" x="151" y="79" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">WEEKLY STATUS</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">今週の状況と、次に動くことを一枚で共有</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">事実、判断、依頼を分けて定例の認識差をなくす。</text>
  <g transform="translate(64 218)" font-family="{{font.body}}">
    <g>
      <rect x="6" y="6" width="310" height="132" rx="18" fill="{{color.ink}}"/>
      <rect width="310" height="132" rx="18" fill="{{color.mintWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text x="24" y="34" fill="{{color.inkSub}}" font-size="{{type.caption}}" font-weight="700">OVERALL</text>
      <text data-slot="overall" x="24" y="82" fill="{{color.mint}}" font-family="{{font.numeric}}" font-size="{{type.heading}}" font-weight="700">ON TRACK</text>
      <text data-slot="health" x="24" y="112" fill="{{color.ink}}" font-size="{{type.label}}">予定どおり</text>
    </g>
    <g transform="translate(334 0)">
      <rect x="6" y="6" width="264" height="132" rx="18" fill="{{color.ink}}"/>
      <rect width="264" height="132" rx="18" fill="{{color.primaryWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text x="24" y="34" fill="{{color.inkSub}}" font-size="{{type.caption}}" font-weight="700">PROGRESS</text>
      <text data-slot="progress" x="24" y="89" fill="{{color.primary}}" font-family="{{font.numeric}}" font-size="{{type.display}}" font-weight="700">68%</text>
      <rect x="112" y="66" width="124" height="20" rx="10" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <rect x="112" y="66" width="84" height="20" rx="10" fill="{{color.primary}}"/>
    </g>
    <g transform="translate(622 0)">
      <rect x="6" y="6" width="450" height="132" rx="18" fill="{{color.ink}}"/>
      <rect width="450" height="132" rx="18" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text x="24" y="34" fill="{{color.inkSub}}" font-size="{{type.caption}}" font-weight="700">MILESTONES</text>
      <polygon points="34,58 44,68 34,78 24,68" fill="{{color.mango}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text data-slot="milestone-1" x="58" y="75" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">デザイン確定</text>
      <text data-slot="date-1" x="420" y="75" text-anchor="end" fill="{{color.inkSub}}" font-family="{{font.numeric}}" font-size="{{type.caption}}">8/07</text>
      <polygon points="34,96 44,106 34,116 24,106" fill="{{color.violet}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text data-slot="milestone-2" x="58" y="113" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">β版リリース</text>
      <text data-slot="date-2" x="420" y="113" text-anchor="end" fill="{{color.inkSub}}" font-family="{{font.numeric}}" font-size="{{type.caption}}">8/21</text>
    </g>
    <g transform="translate(0 166)">
      <rect x="6" y="6" width="524" height="158" rx="18" fill="{{color.ink}}"/>
      <rect width="524" height="158" rx="18" fill="{{color.coralWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="24" y="22" width="96" height="30" rx="15" fill="{{color.coral}}"/>
      <text x="72" y="43" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.caption}}" font-weight="700">BLOCKER</text>
      <text data-slot="blocker" x="24" y="98" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">外部APIの仕様確定待ち</text>
      <text x="24" y="132" fill="{{color.inkSub}}" font-size="{{type.label}}">依頼: 8/12までに判断</text>
    </g>
    <g transform="translate(548 166)">
      <rect x="6" y="6" width="524" height="158" rx="18" fill="{{color.ink}}"/>
      <rect width="524" height="158" rx="18" fill="{{color.violetWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="24" y="22" width="118" height="30" rx="15" fill="{{color.violet}}"/>
      <text x="83" y="43" text-anchor="middle" fill="{{color.surface}}" font-size="{{type.caption}}" font-weight="700">NEXT WEEK</text>
      <text data-slot="next" x="24" y="98" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">結合テストと公開準備</text>
      <text x="24" y="132" fill="{{color.inkSub}}" font-size="{{type.label}}">Owner: PM / Dev</text>
    </g>
  </g>
  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">注意カードのテンプレート</title>
  <desc id="desc">危険、制約、誤用条件と回避策をまとめて示す。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="128" height="36" rx="18" fill="{{color.coral}}"/>
  <text data-slot="eyebrow" x="128" y="79" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">WARNING</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">適用できない条件を、先に見せる</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">不安を煽らず、問題と回避策を一対で書く。</text>

  <g transform="translate(104 238)">
    <rect x="8" y="8" width="992" height="280" rx="24" fill="{{color.ink}}"/>
    <rect width="992" height="280" rx="24" fill="{{color.coralWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.emphasis}}"/>
    <path d="M92 44 145 142H39Z" fill="{{color.mango}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <path d="M92 78v30M92 124h.1" fill="none" stroke="{{color.ink}}" stroke-width="7" stroke-linecap="round"/>
    <text data-slot="message" x="184" y="90" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">データなしでチャートを作らない</text>
    <text data-slot="body-1" x="184" y="136" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">装飾用の疑似データは、読者の判断を誤らせる。</text>
    <rect x="184" y="174" width="130" height="38" rx="19" fill="{{color.ink}}"/>
    <text x="249" y="200" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.body}}" font-size="{{type.label}}" font-weight="700">AVOID</text>
    <text data-slot="action" x="336" y="200" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.body}}" font-weight="700">出典を確認するまで公開を保留する</text>
  </g>

  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

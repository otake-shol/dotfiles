<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">変更前後の比較テンプレート</title>
  <desc id="desc">変更前の問題と変更後の改善を左右で対比する。</desc>
  <defs>
    <marker id="arrow" markerWidth="12" markerHeight="12" refX="10" refY="6" orient="auto"><path d="M1 1L11 6L1 11Z" fill="{{color.ink}}"/></marker>
  </defs>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="174" height="36" rx="18" fill="{{color.coral}}"/>
  <text data-slot="eyebrow" x="151" y="79" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">BEFORE / AFTER</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">変化を、同じ観点で並べて読む</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">問題の列挙ではなく、何がどう良くなったかを対応させる。</text>

  <g transform="translate(70 242)">
    <rect x="6" y="6" width="430" height="280" rx="18" fill="{{color.ink}}"/>
    <rect width="430" height="280" rx="18" fill="{{color.coralWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <rect x="28" y="26" width="112" height="36" rx="18" fill="{{color.coral}}"/>
    <text x="84" y="51" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">BEFORE</text>
    <text data-slot="label-1" x="30" y="112" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">情報が散らばる</text>
    <text data-slot="body-1" x="30" y="158" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}"><tspan x="30">判断の根拠と制作物が</tspan><tspan x="30" dy="32">別々に管理される</tspan></text>
    <text data-slot="note-1" x="30" y="242" fill="{{color.wine}}" font-family="{{font.body}}" font-size="{{type.label}}" font-weight="700">毎回ゼロから調整</text>
  </g>

  <line x1="518" y1="382" x2="678" y2="382" stroke="{{color.ink}}" stroke-width="{{stroke.emphasis}}" marker-end="url(#arrow)"/>
  <text data-slot="change-label" x="598" y="356" text-anchor="middle" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.label}}" font-weight="700">仕組み化</text>

  <g transform="translate(700 242)">
    <rect x="6" y="6" width="430" height="280" rx="18" fill="{{color.ink}}"/>
    <rect width="430" height="280" rx="18" fill="{{color.mintWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <rect x="28" y="26" width="100" height="36" rx="18" fill="{{color.mint}}"/>
    <text x="78" y="51" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">AFTER</text>
    <text data-slot="label-2" x="30" y="112" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">一つのbriefから生成</text>
    <text data-slot="body-2" x="30" y="158" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}"><tspan x="30">判断、図、alt、媒体別画像を</tspan><tspan x="30" dy="32">同じ入力から作る</tspan></text>
    <text data-slot="note-2" x="30" y="242" fill="{{color.primaryDark}}" font-family="{{font.body}}" font-size="{{type.label}}" font-weight="700">再利用できる品質へ</text>
  </g>

  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

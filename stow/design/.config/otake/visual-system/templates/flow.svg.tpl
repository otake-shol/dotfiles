<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">3段階フロー図のテンプレート</title>
  <desc id="desc">入力、判断、結果の3段階を左から右へ示す。</desc>
  <defs>
    <marker id="arrow" markerWidth="12" markerHeight="12" refX="10" refY="6" orient="auto">
      <path d="M1 1L11 6L1 11Z" fill="{{color.ink}}"/>
    </marker>
  </defs>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>

  <rect x="64" y="54" width="112" height="36" rx="18" fill="{{color.primary}}"/>
  <text data-slot="eyebrow" x="120" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">FLOW</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">複雑な流れを、3つの意味単位に分ける</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">矢印には「何が変わるか」が読み取れる順序を与える。</text>

  <line x1="354" y1="364" x2="460" y2="364" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}" marker-end="url(#arrow)"/>
  <line x1="738" y1="364" x2="844" y2="364" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}" marker-end="url(#arrow)"/>

  <g data-slot="node-1">
    <rect x="76" y="274" width="280" height="196" rx="18" fill="{{color.ink}}"/>
    <rect x="70" y="268" width="280" height="196" rx="18" fill="{{color.primaryWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <circle cx="116" cy="316" r="22" fill="{{color.primary}}"/>
    <text x="116" y="323" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.body}}" font-weight="700">1</text>
    <text data-slot="label-1" x="154" y="323" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">入力を揃える</text>
    <text data-slot="body-1" x="104" y="376" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">
      <tspan x="104" dy="0">事実と前提を分け、</tspan>
      <tspan x="104" dy="34">比較可能な形にする</tspan>
    </text>
  </g>

  <g data-slot="node-2">
    <rect x="460" y="274" width="280" height="196" rx="18" fill="{{color.ink}}"/>
    <rect x="454" y="268" width="280" height="196" rx="18" fill="{{color.mangoWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <circle cx="500" cy="316" r="22" fill="{{color.mango}}"/>
    <text x="500" y="323" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.body}}" font-weight="700">2</text>
    <text data-slot="label-2" x="538" y="323" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">判断する</text>
    <text data-slot="body-2" x="488" y="376" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">
      <tspan x="488" dy="0">軸を1つに絞り、</tspan>
      <tspan x="488" dy="34">違いの理由を示す</tspan>
    </text>
  </g>

  <g data-slot="node-3">
    <rect x="844" y="274" width="280" height="196" rx="18" fill="{{color.ink}}"/>
    <rect x="838" y="268" width="280" height="196" rx="18" fill="{{color.mintWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <circle cx="884" cy="316" r="22" fill="{{color.mint}}"/>
    <text x="884" y="323" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.body}}" font-weight="700">3</text>
    <text data-slot="label-3" x="922" y="323" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">行動へ変える</text>
    <text data-slot="body-3" x="872" y="376" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">
      <tspan x="872" dy="0">次に取る行動を、</tspan>
      <tspan x="872" dy="34">具体的に残す</tspan>
    </text>
  </g>

  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

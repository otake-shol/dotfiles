<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">比較表のテンプレート</title>
  <desc id="desc">3つの方式を4つの観点で比較し、推奨案を強調する。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="162" height="36" rx="18" fill="{{color.wine}}"/>
  <text data-slot="eyebrow" x="145" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">COMPARISON</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">違いを並べ、判断の基準をそろえる</text>

  <g transform="translate(64 202)">
    <rect x="6" y="6" width="1072" height="360" rx="18" fill="{{color.ink}}"/>
    <rect width="1072" height="360" rx="18" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <path d="M250 0V360M524 0V360M798 0V360M0 72H1072M0 144H1072M0 216H1072M0 288H1072" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
    <rect x="524" width="274" height="360" fill="{{color.primaryWash}}"/>
    <path d="M524 0V360M798 0V360" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>

    <text x="32" y="46" fill="{{color.inkSub}}" font-family="{{font.heading}}" font-size="{{type.label}}" font-weight="700">比較軸</text>
    <text data-slot="label-column-1" x="387" y="46" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">方式 A</text>
    <text data-slot="label-column-2" x="661" y="46" text-anchor="middle" fill="{{color.primaryDark}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">方式 B</text>
    <rect x="706" y="18" width="70" height="28" rx="14" fill="{{color.primary}}"/>
    <text x="741" y="38" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.body}}" font-size="{{type.caption}}" font-weight="700">推奨</text>
    <text data-slot="label-column-3" x="935" y="46" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">方式 C</text>

    <text data-slot="label-row-1" x="32" y="118" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.body}}" font-weight="700">導入コスト</text>
    <text data-slot="label-row-2" x="32" y="190" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.body}}" font-weight="700">変更しやすさ</text>
    <text data-slot="label-row-3" x="32" y="262" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.body}}" font-weight="700">再利用性</text>
    <text data-slot="label-row-4" x="32" y="334" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.body}}" font-weight="700">向いている場面</text>

    <g font-family="{{font.body}}" font-size="{{type.body}}" text-anchor="middle">
      <text data-slot="cell-1-1" x="387" y="118" fill="{{color.inkSub}}">低い</text><text data-slot="cell-1-2" x="661" y="118" fill="{{color.ink}}" font-weight="700">中</text><text data-slot="cell-1-3" x="935" y="118" fill="{{color.inkSub}}">高い</text>
      <text data-slot="cell-2-1" x="387" y="190" fill="{{color.inkSub}}">△</text><text data-slot="cell-2-2" x="661" y="190" fill="{{color.mint}}" font-family="{{font.numeric}}" font-weight="700">◎</text><text data-slot="cell-2-3" x="935" y="190" fill="{{color.inkSub}}">○</text>
      <text data-slot="cell-3-1" x="387" y="262" fill="{{color.inkSub}}">△</text><text data-slot="cell-3-2" x="661" y="262" fill="{{color.mint}}" font-family="{{font.numeric}}" font-weight="700">◎</text><text data-slot="cell-3-3" x="935" y="262" fill="{{color.inkSub}}">○</text>
      <text data-slot="cell-4-1" x="387" y="334" fill="{{color.inkSub}}">単発</text><text data-slot="cell-4-2" x="661" y="334" fill="{{color.ink}}" font-weight="700">継続運用</text><text data-slot="cell-4-3" x="935" y="334" fill="{{color.inkSub}}">大規模</text>
    </g>
  </g>

  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

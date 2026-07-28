<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">シーケンス図のテンプレート</title>
  <desc id="desc">3つの主体間で起きる4つのやり取りを上から下へ示す。</desc>
  <defs><marker id="arrow" markerWidth="11" markerHeight="11" refX="9" refY="5.5" orient="auto"><path d="M1 1L10 5.5L1 10Z" fill="{{color.ink}}"/></marker></defs>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="150" height="36" rx="18" fill="{{color.wine}}"/>
  <text data-slot="eyebrow" x="139" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">SEQUENCE</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">主体間のやり取りを、順番で追う</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">時間は上から下。矢印には動詞を書く。</text>

  <g font-family="{{font.body}}">
    <g>
      <rect x="120" y="220" width="220" height="58" rx="18" fill="{{color.primaryWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="actor-1" x="230" y="257" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">Author</text>
      <line x1="230" y1="278" x2="230" y2="548" stroke="{{color.inkMute}}" stroke-width="{{stroke.hairline}}" stroke-dasharray="6 8"/>
    </g>
    <g>
      <rect x="490" y="220" width="220" height="58" rx="18" fill="{{color.mangoWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="actor-2" x="600" y="257" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">OVS CLI</text>
      <line x1="600" y1="278" x2="600" y2="548" stroke="{{color.inkMute}}" stroke-width="{{stroke.hairline}}" stroke-dasharray="6 8"/>
    </g>
    <g>
      <rect x="860" y="220" width="220" height="58" rx="18" fill="{{color.mintWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="actor-3" x="970" y="257" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">Media</text>
      <line x1="970" y1="278" x2="970" y2="548" stroke="{{color.inkMute}}" stroke-width="{{stroke.hairline}}" stroke-dasharray="6 8"/>
    </g>

    <line x1="230" y1="326" x2="586" y2="326" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}" marker-end="url(#arrow)"/>
    <text data-slot="message-1" x="408" y="314" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">briefを渡す</text>
    <line x1="600" y1="390" x2="956" y2="390" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}" marker-end="url(#arrow)"/>
    <text data-slot="message-2" x="778" y="378" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">媒体別画像を生成</text>
    <line x1="970" y1="454" x2="614" y2="454" stroke="{{color.primary}}" stroke-width="{{stroke.rule}}" stroke-dasharray="7 7" marker-end="url(#arrow)"/>
    <text data-slot="message-3" x="792" y="442" text-anchor="middle" fill="{{color.primaryDark}}" font-size="{{type.label}}" font-weight="700">表示結果を返す</text>
    <line x1="600" y1="518" x2="244" y2="518" stroke="{{color.primary}}" stroke-width="{{stroke.rule}}" stroke-dasharray="7 7" marker-end="url(#arrow)"/>
    <text data-slot="message-4" x="422" y="506" text-anchor="middle" fill="{{color.primaryDark}}" font-size="{{type.label}}" font-weight="700">検証結果を返す</text>
  </g>

  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

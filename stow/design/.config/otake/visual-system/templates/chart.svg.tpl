<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">横棒グラフのテンプレート</title>
  <desc id="desc">4項目の値を横棒で比較し、最大値を主要色で強調する。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="112" height="36" rx="18" fill="{{color.mint}}"/>
  <text data-slot="eyebrow" x="120" y="79" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">CHART</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">差の大きさを、数字と長さで同時に読む</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">単位: %　対象期間: 2026年1–6月</text>

  <g transform="translate(64 228)">
    <line x1="196" y1="0" x2="196" y2="320" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <line x1="196" y1="320" x2="1036" y2="320" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <g stroke="{{color.rule}}" stroke-width="{{stroke.hairline}}" stroke-dasharray="4 7">
      <line x1="406" y1="0" x2="406" y2="320"/><line x1="616" y1="0" x2="616" y2="320"/>
      <line x1="826" y1="0" x2="826" y2="320"/><line x1="1036" y1="0" x2="1036" y2="320"/>
    </g>

    <g font-family="{{font.body}}" font-size="{{type.body}}" fill="{{color.ink}}" text-anchor="end">
      <text data-slot="label-1" x="170" y="52">記事 A</text>
      <text data-slot="label-2" x="170" y="124">記事 B</text>
      <text data-slot="label-3" x="170" y="196">記事 C</text>
      <text data-slot="label-4" x="170" y="268">記事 D</text>
    </g>

    <rect x="196" y="24" width="680" height="38" rx="12" fill="{{color.primary}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
    <rect x="196" y="96" width="512" height="38" rx="12" fill="{{color.coral}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
    <rect x="196" y="168" width="402" height="38" rx="12" fill="{{color.mango}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
    <rect x="196" y="240" width="276" height="38" rx="12" fill="{{color.violet}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>

    <g font-family="{{font.numeric}}" font-size="{{type.heading}}" font-weight="700" fill="{{color.ink}}">
      <text data-slot="value-1" x="894" y="53">81%</text>
      <text data-slot="value-2" x="726" y="125">61%</text>
      <text data-slot="value-3" x="616" y="197">48%</text>
      <text data-slot="value-4" x="490" y="269">33%</text>
    </g>
    <g font-family="{{font.numeric}}" font-size="{{type.caption}}" fill="{{color.inkMute}}" text-anchor="middle">
      <text x="196" y="348">0</text><text x="406" y="348">25</text><text x="616" y="348">50</text>
      <text x="826" y="348">75</text><text x="1036" y="348">100</text>
    </g>
  </g>

  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">出典: サンプルデータ（公開時は実データへ差し替え）</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

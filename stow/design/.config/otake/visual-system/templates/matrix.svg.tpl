<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">2軸マトリクスのテンプレート</title>
  <desc id="desc">重要度と実行容易性の2軸に4つの対象を配置する。</desc>
  <defs>
    <marker id="axis-arrow" markerWidth="11" markerHeight="11" refX="9" refY="5.5" orient="auto">
      <path d="M1 1L10 5.5L1 10Z" fill="{{color.ink}}"/>
    </marker>
  </defs>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="132" height="36" rx="18" fill="{{color.violet}}"/>
  <text data-slot="eyebrow" x="130" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">MATRIX</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">2つの軸で、優先する領域を見つける</text>

  <g transform="translate(250 210)">
    <rect x="6" y="6" width="720" height="360" rx="18" fill="{{color.ink}}"/>
    <rect width="720" height="360" rx="18" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <path d="M0 180H720M360 0V360" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
    <path d="M0 0H360V180H0Z" fill="{{color.primaryWash}}"/>
    <path d="M360 0H720V180H360Z" fill="{{color.mintWash}}"/>
    <path d="M0 180H360V360H0Z" fill="{{color.sunken}}"/>
    <path d="M360 180H720V360H360Z" fill="{{color.mangoWash}}"/>
    <path d="M0 180H720M360 0V360" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>

    <text data-slot="label-quadrant-1" x="28" y="38" fill="{{color.primaryDark}}" font-family="{{font.heading}}" font-size="{{type.label}}" font-weight="700">計画して育てる</text>
    <text data-slot="label-quadrant-2" x="388" y="38" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.label}}" font-weight="700">今すぐ着手</text>
    <text data-slot="label-quadrant-3" x="28" y="218" fill="{{color.inkSub}}" font-family="{{font.heading}}" font-size="{{type.label}}" font-weight="700">保留・観察</text>
    <text data-slot="label-quadrant-4" x="388" y="218" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.label}}" font-weight="700">小さく試す</text>

    <g data-slot="point-1">
      <circle cx="548" cy="86" r="19" fill="{{color.mint}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="574" y="68" width="112" height="36" rx="18" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text data-slot="point-label-1" x="630" y="92" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.label}}" font-weight="700">施策 A</text>
    </g>
    <g data-slot="point-2">
      <circle cx="438" cy="138" r="17" fill="{{color.primary}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="point-label-2" x="438" y="144" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">B</text>
    </g>
    <g data-slot="point-3">
      <circle cx="518" cy="278" r="17" fill="{{color.mango}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="point-label-3" x="518" y="284" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">C</text>
    </g>
    <g data-slot="point-4">
      <circle cx="204" cy="112" r="17" fill="{{color.violet}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="point-label-4" x="204" y="118" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">D</text>
    </g>
  </g>

  <line x1="226" y1="590" x2="1000" y2="590" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}" marker-end="url(#axis-arrow)"/>
  <text data-slot="label-x-low" x="218" y="618" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.label}}">実行が難しい</text>
  <text data-slot="label-x-high" x="800" y="618" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.label}}">実行しやすい</text>
  <line x1="218" y1="582" x2="218" y2="196" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}" marker-end="url(#axis-arrow)"/>
  <text data-slot="label-y-high" x="92" y="232" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.label}}">重要度が高い</text>
  <text data-slot="source" x="64" y="650" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(936 620)">{{>brand}}</g>
</svg>

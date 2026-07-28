<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">WBSのテンプレート</title>
  <desc id="desc">プロジェクトを3つの成果物と6つの作業へ分解する。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="92" height="36" rx="18" fill="{{color.violet}}"/>
  <text data-slot="eyebrow" x="110" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">WBS</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">成果物から、実行できる作業へ分解する</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">名詞の成果物を先に置き、その下へ担当可能な粒度の作業を並べる。</text>
  <g transform="translate(64 218)" font-family="{{font.body}}">
    <rect x="436" y="0" width="200" height="58" rx="18" fill="{{color.wine}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <text data-slot="root" x="536" y="37" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">プロジェクト</text>
    <path d="M536 58V92M176 92H896M176 92V116M536 92V116M896 92V116" fill="none" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <g transform="translate(24 116)">
      <rect x="5" y="5" width="304" height="78" rx="18" fill="{{color.ink}}"/>
      <rect width="304" height="78" rx="18" fill="{{color.primaryWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="label-1" x="152" y="49" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">企画</text>
      <path d="M152 78V112M62 112H242M62 112V132M242 112V132" fill="none" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <rect x="0" y="132" width="124" height="62" rx="14" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="leaf-1-1" x="62" y="170" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">要件整理</text>
      <rect x="180" y="132" width="124" height="62" rx="14" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="leaf-1-2" x="242" y="170" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">計画</text>
    </g>
    <g transform="translate(384 116)">
      <rect x="5" y="5" width="304" height="78" rx="18" fill="{{color.ink}}"/>
      <rect width="304" height="78" rx="18" fill="{{color.mangoWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="label-2" x="152" y="49" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">制作</text>
      <path d="M152 78V112M62 112H242M62 112V132M242 112V132" fill="none" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <rect x="0" y="132" width="124" height="62" rx="14" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="leaf-2-1" x="62" y="170" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">設計</text>
      <rect x="180" y="132" width="124" height="62" rx="14" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="leaf-2-2" x="242" y="170" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">実装</text>
    </g>
    <g transform="translate(744 116)">
      <rect x="5" y="5" width="304" height="78" rx="18" fill="{{color.ink}}"/>
      <rect width="304" height="78" rx="18" fill="{{color.mintWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="label-3" x="152" y="49" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">公開</text>
      <path d="M152 78V112M62 112H242M62 112V132M242 112V132" fill="none" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <rect x="0" y="132" width="124" height="62" rx="14" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="leaf-3-1" x="62" y="170" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">検証</text>
      <rect x="180" y="132" width="124" height="62" rx="14" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="leaf-3-2" x="242" y="170" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">リリース</text>
    </g>
  </g>
  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">タイムラインのテンプレート</title>
  <desc id="desc">4つの出来事を左から右へ時間順に並べる。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="142" height="36" rx="18" fill="{{color.primary}}"/>
  <text data-slot="eyebrow" x="135" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">TIMELINE</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">出来事と判断の変化を、時間でつなぐ</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">日付だけでなく、その時点で何が変わったかを書く。</text>

  <line x1="120" y1="354" x2="1080" y2="354" stroke="{{color.ink}}" stroke-width="{{stroke.emphasis}}"/>
  <g font-family="{{font.body}}">
    <g transform="translate(150 354)">
      <circle r="18" fill="{{color.primary}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="-90" y="-116" width="180" height="82" rx="18" fill="{{color.primaryWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="date-1" x="0" y="-86" text-anchor="middle" fill="{{color.primaryDark}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">STEP 01</text>
      <text data-slot="label-1" x="0" y="-56" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">課題を発見</text>
      <text data-slot="body-1" x="0" y="70" text-anchor="middle" fill="{{color.inkSub}}" font-size="{{type.label}}">ばらつきを観察</text>
    </g>
    <g transform="translate(450 354)">
      <circle r="18" fill="{{color.mango}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="-90" y="-116" width="180" height="82" rx="18" fill="{{color.mangoWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="date-2" x="0" y="-86" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">STEP 02</text>
      <text data-slot="label-2" x="0" y="-56" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">原則を定義</text>
      <text data-slot="body-2" x="0" y="70" text-anchor="middle" fill="{{color.inkSub}}" font-size="{{type.label}}">判断軸を固定</text>
    </g>
    <g transform="translate(750 354)">
      <circle r="18" fill="{{color.violet}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="-90" y="-116" width="180" height="82" rx="18" fill="{{color.violetWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="date-3" x="0" y="-86" text-anchor="middle" fill="{{color.violet}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">STEP 03</text>
      <text data-slot="label-3" x="0" y="-56" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">仕組みを実装</text>
      <text data-slot="body-3" x="0" y="70" text-anchor="middle" fill="{{color.inkSub}}" font-size="{{type.label}}">自動生成へ移行</text>
    </g>
    <g transform="translate(1050 354)">
      <circle r="18" fill="{{color.mint}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="-90" y="-116" width="180" height="82" rx="18" fill="{{color.mintWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <text data-slot="date-4" x="0" y="-86" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">STEP 04</text>
      <text data-slot="label-4" x="0" y="-56" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.label}}" font-weight="700">運用で改善</text>
      <text data-slot="body-4" x="0" y="70" text-anchor="middle" fill="{{color.inkSub}}" font-size="{{type.label}}">実記事で検証</text>
    </g>
  </g>

  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

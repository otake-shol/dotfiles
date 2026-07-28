<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">アーキテクチャ図のテンプレート</title>
  <desc id="desc">利用者、インターフェース、処理、データの4層を上から下へ示す。</desc>
  <defs><marker id="arrow" markerWidth="11" markerHeight="11" refX="9" refY="5.5" orient="auto"><path d="M1 1L10 5.5L1 10Z" fill="{{color.ink}}"/></marker></defs>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="180" height="36" rx="18" fill="{{color.violet}}"/>
  <text data-slot="eyebrow" x="154" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">ARCHITECTURE</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">境界と責務を、層で分けて見る</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">矢印は依存またはデータの向きを表す。</text>

  <g transform="translate(130 232)" font-family="{{font.body}}">
    <rect x="6" y="6" width="940" height="66" rx="18" fill="{{color.ink}}"/>
    <rect width="940" height="66" rx="18" fill="{{color.primaryWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <text data-slot="layer-1" x="30" y="42" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">Reader / Author</text>
    <text data-slot="body-1" x="360" y="42" fill="{{color.inkSub}}" font-size="{{type.label}}">記事を読み、briefへ意図を書く</text>

    <line x1="470" y1="76" x2="470" y2="102" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}" marker-end="url(#arrow)"/>
    <rect x="6" y="116" width="940" height="66" rx="18" fill="{{color.ink}}"/>
    <rect y="110" width="940" height="66" rx="18" fill="{{color.violetWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <text data-slot="layer-2" x="30" y="152" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">Claude / Codex</text>
    <text data-slot="body-2" x="360" y="152" fill="{{color.inkSub}}" font-size="{{type.label}}">構成を提案し、JSONだけを編集する</text>

    <line x1="470" y1="186" x2="470" y2="212" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}" marker-end="url(#arrow)"/>
    <rect x="6" y="226" width="940" height="66" rx="18" fill="{{color.ink}}"/>
    <rect y="220" width="940" height="66" rx="18" fill="{{color.mangoWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <text data-slot="layer-3" x="30" y="262" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">OVS CLI</text>
    <text data-slot="body-3" x="360" y="262" fill="{{color.inkSub}}" font-size="{{type.label}}">検証してSVG・PNG・altを生成する</text>

    <line x1="470" y1="296" x2="470" y2="322" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}" marker-end="url(#arrow)"/>
    <rect x="6" y="336" width="940" height="66" rx="18" fill="{{color.ink}}"/>
    <rect y="330" width="940" height="66" rx="18" fill="{{color.mintWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <text data-slot="layer-4" x="30" y="372" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">Published assets</text>
    <text data-slot="body-4" x="360" y="372" fill="{{color.inkSub}}" font-size="{{type.label}}">ブログ・スライド・SNSで再利用する</text>
  </g>

  <text data-slot="source" x="64" y="650" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(928 616)">{{>brand}}</g>
</svg>

<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">ロードマップのテンプレート</title>
  <desc id="desc">現在、次、その後の順で成果と目的を整理する。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="142" height="36" rx="18" fill="{{color.primary}}"/>
  <text data-slot="eyebrow" x="135" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">ROADMAP</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">日付ではなく、届ける価値で計画をつなぐ</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">Now / Next / Laterで優先順位と不確実性を共有する。</text>
  <g transform="translate(64 226)">
    <path d="M174 39H895" stroke="{{color.ink}}" stroke-width="{{stroke.emphasis}}"/>
    <polygon points="914,39 894,28 894,50" fill="{{color.ink}}"/>
    <g transform="translate(0 0)">
      <rect x="6" y="6" width="326" height="286" rx="18" fill="{{color.ink}}"/>
      <rect width="326" height="286" rx="18" fill="{{color.primaryWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="24" y="22" width="94" height="32" rx="16" fill="{{color.primary}}"/>
      <text data-slot="period-1" x="71" y="44" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.caption}}" font-weight="700">NOW</text>
      <text data-slot="label-1" x="24" y="104" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">課題を絞る</text>
      <text data-slot="body-1" x="24" y="146" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">仮説と成功条件を定義</text>
      <circle cx="42" cy="208" r="9" fill="{{color.primary}}"/><text x="62" y="215" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.label}}">検証可能な状態</text>
      <circle cx="42" cy="246" r="9" fill="{{color.primary}}"/><text x="62" y="253" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.label}}">最優先の成果</text>
    </g>
    <g transform="translate(374 0)">
      <rect x="6" y="6" width="326" height="286" rx="18" fill="{{color.ink}}"/>
      <rect width="326" height="286" rx="18" fill="{{color.mangoWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="24" y="22" width="94" height="32" rx="16" fill="{{color.mango}}"/>
      <text data-slot="period-2" x="71" y="44" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.caption}}" font-weight="700">NEXT</text>
      <text data-slot="label-2" x="24" y="104" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">価値を届ける</text>
      <text data-slot="body-2" x="24" y="146" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">実装・検証・改善</text>
      <circle cx="42" cy="208" r="9" fill="{{color.mango}}"/><text x="62" y="215" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.label}}">利用者へ公開</text>
      <circle cx="42" cy="246" r="9" fill="{{color.mango}}"/><text x="62" y="253" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.label}}">学習を反映</text>
    </g>
    <g transform="translate(748 0)">
      <rect x="6" y="6" width="326" height="286" rx="18" fill="{{color.ink}}"/>
      <rect width="326" height="286" rx="18" fill="{{color.violetWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <rect x="24" y="22" width="94" height="32" rx="16" fill="{{color.violet}}"/>
      <text data-slot="period-3" x="71" y="44" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.caption}}" font-weight="700">LATER</text>
      <text data-slot="label-3" x="24" y="104" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">仕組みにする</text>
      <text data-slot="body-3" x="24" y="146" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">展開と運用を標準化</text>
      <circle cx="42" cy="208" r="9" fill="{{color.violet}}"/><text x="62" y="215" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.label}}">適用範囲を拡大</text>
      <circle cx="42" cy="246" r="9" fill="{{color.violet}}"/><text x="62" y="253" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.label}}">継続運用へ移行</text>
    </g>
  </g>
  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">RAIDログのテンプレート</title>
  <desc id="desc">リスク、前提、課題、依存関係を4つのカードで整理する。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="102" height="36" rx="18" fill="{{color.coral}}"/>
  <text data-slot="eyebrow" x="115" y="79" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">RAID</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">不確実性を、放置せず担当と期限へ変える</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">Risk / Assumption / Issue / Dependencyを同じ粒度で共有する。</text>
  <g transform="translate(64 226)" font-family="{{font.body}}">
    <g>
      <rect x="6" y="6" width="250" height="282" rx="18" fill="{{color.ink}}"/>
      <rect width="250" height="282" rx="18" fill="{{color.coralWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <circle cx="34" cy="34" r="12" fill="{{color.coral}}"/><text data-slot="label-1" x="58" y="41" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">Risk</text>
      <text data-slot="body-1" x="24" y="104" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">納期の遅延可能性</text>
      <text x="24" y="150" fill="{{color.inkSub}}" font-size="{{type.label}}">影響と発生確率を確認</text>
      <rect x="24" y="218" width="202" height="38" rx="12" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text data-slot="owner-1" x="125" y="243" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.caption}}" font-weight="700">Owner: PM</text>
    </g>
    <g transform="translate(274 0)">
      <rect x="6" y="6" width="250" height="282" rx="18" fill="{{color.ink}}"/>
      <rect width="250" height="282" rx="18" fill="{{color.mangoWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <circle cx="34" cy="34" r="12" fill="{{color.mango}}"/><text data-slot="label-2" x="58" y="41" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">Assumption</text>
      <text data-slot="body-2" x="24" y="104" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">既存基盤を再利用</text>
      <text x="24" y="150" fill="{{color.inkSub}}" font-size="{{type.label}}">検証日を決めて仮説化</text>
      <rect x="24" y="218" width="202" height="38" rx="12" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text data-slot="owner-2" x="125" y="243" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.caption}}" font-weight="700">確認: 8/05</text>
    </g>
    <g transform="translate(548 0)">
      <rect x="6" y="6" width="250" height="282" rx="18" fill="{{color.ink}}"/>
      <rect width="250" height="282" rx="18" fill="{{color.wineWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <circle cx="34" cy="34" r="12" fill="{{color.wine}}"/><text data-slot="label-3" x="58" y="41" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">Issue</text>
      <text data-slot="body-3" x="24" y="104" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">仕様が一部未確定</text>
      <text x="24" y="150" fill="{{color.inkSub}}" font-size="{{type.label}}">解消条件と担当を明記</text>
      <rect x="24" y="218" width="202" height="38" rx="12" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text data-slot="owner-3" x="125" y="243" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.caption}}" font-weight="700">Owner: Product</text>
    </g>
    <g transform="translate(822 0)">
      <rect x="6" y="6" width="250" height="282" rx="18" fill="{{color.ink}}"/>
      <rect width="250" height="282" rx="18" fill="{{color.violetWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
      <circle cx="34" cy="34" r="12" fill="{{color.violet}}"/><text data-slot="label-4" x="58" y="41" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">Dependency</text>
      <text data-slot="body-4" x="24" y="104" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">外部APIの公開待ち</text>
      <text x="24" y="150" fill="{{color.inkSub}}" font-size="{{type.label}}">前後関係と代替案を確認</text>
      <rect x="24" y="218" width="202" height="38" rx="12" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
      <text data-slot="owner-4" x="125" y="243" text-anchor="middle" fill="{{color.ink}}" font-size="{{type.caption}}" font-weight="700">確認: 8/12</text>
    </g>
  </g>
  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

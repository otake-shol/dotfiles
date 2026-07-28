<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">RACI表のテンプレート</title>
  <desc id="desc">4つの成果物について実行、説明責任、協議、共有の役割を示す。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="102" height="36" rx="18" fill="{{color.mango}}"/>
  <text data-slot="eyebrow" x="115" y="79" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">RACI</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">誰が実行し、誰が最終責任を持つか</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">R＝実行、A＝説明責任、C＝協議、I＝共有。Aは各行ひとりにする。</text>
  <g transform="translate(64 214)" font-family="{{font.body}}">
    <rect x="6" y="6" width="1072" height="336" rx="18" fill="{{color.ink}}"/>
    <rect width="1072" height="336" rx="18" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <rect x="0" y="0" width="1072" height="68" rx="18" fill="{{color.sunken}}"/>
    <path d="M296 0V336M490 0V336M684 0V336M878 0V336M0 68H1072M0 135H1072M0 202H1072M0 269H1072" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
    <text x="26" y="43" fill="{{color.inkSub}}" font-family="{{font.heading}}" font-size="{{type.label}}" font-weight="700">DELIVERABLE</text>
    <text data-slot="role-1" x="393" y="43" text-anchor="middle" fill="{{color.ink}}" font-weight="700">PM</text>
    <text data-slot="role-2" x="587" y="43" text-anchor="middle" fill="{{color.ink}}" font-weight="700">Design</text>
    <text data-slot="role-3" x="781" y="43" text-anchor="middle" fill="{{color.ink}}" font-weight="700">Dev</text>
    <text data-slot="role-4" x="975" y="43" text-anchor="middle" fill="{{color.ink}}" font-weight="700">Owner</text>
    <text data-slot="deliverable-1" x="26" y="111" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">要件定義</text>
    <text data-slot="deliverable-2" x="26" y="178" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">デザイン</text>
    <text data-slot="deliverable-3" x="26" y="245" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">実装</text>
    <text data-slot="deliverable-4" x="26" y="312" fill="{{color.ink}}" font-size="{{type.body}}" font-weight="700">承認</text>
    <g font-family="{{font.numeric}}" font-size="{{type.body}}" font-weight="700" text-anchor="middle">
      <circle cx="393" cy="101" r="22" fill="{{color.primary}}"/><text x="393" y="108" fill="{{color.surface}}">R</text>
      <circle cx="587" cy="101" r="22" fill="{{color.violetWash}}"/><text x="587" y="108" fill="{{color.violet}}">C</text>
      <circle cx="781" cy="101" r="22" fill="{{color.violetWash}}"/><text x="781" y="108" fill="{{color.violet}}">C</text>
      <circle cx="975" cy="101" r="22" fill="{{color.mango}}"/><text x="975" y="108" fill="{{color.ink}}">A</text>
      <circle cx="393" cy="168" r="22" fill="{{color.violetWash}}"/><text x="393" y="175" fill="{{color.violet}}">C</text>
      <circle cx="587" cy="168" r="22" fill="{{color.primary}}"/><text x="587" y="175" fill="{{color.surface}}">R</text>
      <circle cx="781" cy="168" r="22" fill="{{color.sunken}}"/><text x="781" y="175" fill="{{color.inkSub}}">I</text>
      <circle cx="975" cy="168" r="22" fill="{{color.mango}}"/><text x="975" y="175" fill="{{color.ink}}">A</text>
      <circle cx="393" cy="235" r="22" fill="{{color.violetWash}}"/><text x="393" y="242" fill="{{color.violet}}">C</text>
      <circle cx="587" cy="235" r="22" fill="{{color.violetWash}}"/><text x="587" y="242" fill="{{color.violet}}">C</text>
      <circle cx="781" cy="235" r="22" fill="{{color.primary}}"/><text x="781" y="242" fill="{{color.surface}}">R</text>
      <circle cx="975" cy="235" r="22" fill="{{color.mango}}"/><text x="975" y="242" fill="{{color.ink}}">A</text>
      <circle cx="393" cy="302" r="22" fill="{{color.primary}}"/><text x="393" y="309" fill="{{color.surface}}">R</text>
      <circle cx="587" cy="302" r="22" fill="{{color.sunken}}"/><text x="587" y="309" fill="{{color.inkSub}}">I</text>
      <circle cx="781" cy="302" r="22" fill="{{color.sunken}}"/><text x="781" y="309" fill="{{color.inkSub}}">I</text>
      <circle cx="975" cy="302" r="22" fill="{{color.mango}}"/><text x="975" y="309" fill="{{color.ink}}">A</text>
    </g>
  </g>
  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

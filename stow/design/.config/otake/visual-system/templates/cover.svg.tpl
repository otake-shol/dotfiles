<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">記事カバーのテンプレート</title>
  <desc id="desc">クリーム色の背景に記事タイトル、3つのキーワード、個人ブランドマーカーを配置したカバー。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <path d="M0 0H28V675H0Z" fill="{{color.primary}}"/>
  <path d="M28 0H36V675H28Z" fill="{{color.wine}}"/>
  <circle cx="1060" cy="82" r="132" fill="{{color.primaryWash}}"/>
  <circle cx="1132" cy="148" r="62" fill="{{color.wineWash}}"/>

  <g data-slot="eyebrow">
    <rect x="72" y="64" width="194" height="38" rx="19" fill="{{color.ink}}"/>
    <text x="169" y="89" text-anchor="middle" fill="{{color.nightInk}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700" letter-spacing="1.4">VISUAL NOTE 001</text>
  </g>

  <g>
    <text data-slot="title" x="72" y="190" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.display}}" font-weight="700">
      <tspan x="72" dy="0">記事の中心メッセージを</tspan>
      <tspan x="72" dy="68">短く、構造的に伝える</tspan>
    </text>
  </g>
  <text data-slot="subtitle" x="75" y="340" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}" font-weight="500">補足は一文だけ。詳しい説明は本文へ戻す。</text>

  <g aria-hidden="true">
    <rect x="78" y="430" width="254" height="94" rx="18" fill="{{color.ink}}"/>
    <rect x="72" y="424" width="254" height="94" rx="18" fill="{{color.primaryWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <circle cx="110" cy="471" r="16" fill="{{color.primary}}"/>
    <text data-slot="label-1" x="142" y="478" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">構造</text>

    <rect x="370" y="430" width="254" height="94" rx="18" fill="{{color.ink}}"/>
    <rect x="364" y="424" width="254" height="94" rx="18" fill="{{color.coralWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <circle cx="402" cy="471" r="16" fill="{{color.coral}}"/>
    <text data-slot="label-2" x="434" y="478" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">判断</text>

    <rect x="662" y="430" width="254" height="94" rx="18" fill="{{color.ink}}"/>
    <rect x="656" y="424" width="254" height="94" rx="18" fill="{{color.mintWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <circle cx="694" cy="471" r="16" fill="{{color.mint}}"/>
    <text data-slot="label-3" x="726" y="478" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.body}}" font-weight="700">実践</text>
  </g>

  <text data-slot="source" x="72" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

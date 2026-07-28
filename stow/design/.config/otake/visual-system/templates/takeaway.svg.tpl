<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">要点カードのテンプレート</title>
  <desc id="desc">記事で最も残したい主張と次の行動を大きく示す。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="168" height="36" rx="18" fill="{{color.mint}}"/>
  <text data-slot="eyebrow" x="148" y="79" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">KEY TAKEAWAY</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">読者に残したい一文を、独立させる</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">記事の要約ではなく、判断や行動につながる結論を書く。</text>

  <g transform="translate(104 238)">
    <rect x="8" y="8" width="992" height="280" rx="24" fill="{{color.ink}}"/>
    <rect width="992" height="280" rx="24" fill="{{color.mintWash}}" stroke="{{color.ink}}" stroke-width="{{stroke.emphasis}}"/>
    <circle cx="88" cy="92" r="44" fill="{{color.mint}}" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <path d="m66 92 15 15 29-33" fill="none" stroke="{{color.ink}}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>
    <text data-slot="message" x="160" y="96" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">良い図は、描く前のbriefで決まる</text>
    <line x1="160" y1="132" x2="914" y2="132" stroke="{{color.ink}}" stroke-width="{{stroke.hairline}}"/>
    <rect x="160" y="166" width="126" height="40" rx="20" fill="{{color.primary}}"/>
    <text x="223" y="193" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.body}}" font-size="{{type.label}}" font-weight="700">NEXT ACTION</text>
    <text data-slot="action" x="310" y="194" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.body}}" font-weight="700">messageとsourceを先に書く</text>
  </g>

  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

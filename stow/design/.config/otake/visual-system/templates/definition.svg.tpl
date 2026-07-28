<svg xmlns="http://www.w3.org/2000/svg" width="{{canvas.width}}" height="{{canvas.height}}" viewBox="0 0 {{canvas.width}} {{canvas.height}}" role="img" aria-labelledby="title desc">
  <title id="title">定義カードのテンプレート</title>
  <desc id="desc">用語、その短い定義、含むもの、含まないものを示す。</desc>
  <rect width="1200" height="675" fill="{{color.canvas}}"/>
  <rect x="64" y="54" width="142" height="36" rx="18" fill="{{color.violet}}"/>
  <text data-slot="eyebrow" x="135" y="79" text-anchor="middle" fill="{{color.surface}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">DEFINITION</text>
  <text data-slot="title" x="64" y="144" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">最初に、言葉の意味をそろえる</text>
  <text data-slot="subtitle" x="66" y="183" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">一般的な意味と異なる場合は、この記事での範囲を明記する。</text>

  <g transform="translate(104 232)">
    <rect x="8" y="8" width="992" height="300" rx="24" fill="{{color.ink}}"/>
    <rect width="992" height="300" rx="24" fill="{{color.surface}}" stroke="{{color.ink}}" stroke-width="{{stroke.emphasis}}"/>
    <rect width="286" height="300" rx="21" fill="{{color.violetWash}}"/>
    <path d="M286 0V300" stroke="{{color.ink}}" stroke-width="{{stroke.rule}}"/>
    <text x="32" y="52" fill="{{color.violet}}" font-family="{{font.numeric}}" font-size="{{type.label}}" font-weight="700">TERM</text>
    <text data-slot="term" x="32" y="112" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.title}}" font-weight="700">OVS</text>
    <text data-slot="reading" x="34" y="152" fill="{{color.inkSub}}" font-family="{{font.numeric}}" font-size="{{type.label}}">Otake Visual System</text>
    <text data-slot="definition" x="330" y="78" fill="{{color.ink}}" font-family="{{font.heading}}" font-size="{{type.heading}}" font-weight="700">意図から一貫した図を生成する個人用の仕組み</text>
    <line x1="330" y1="112" x2="944" y2="112" stroke="{{color.rule}}" stroke-width="{{stroke.rule}}"/>
    <rect x="330" y="146" width="104" height="34" rx="17" fill="{{color.mint}}"/>
    <text x="382" y="169" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.caption}}" font-weight="700">含む</text>
    <text data-slot="includes" x="454" y="170" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">brief・SVG・alt・検証</text>
    <rect x="330" y="210" width="104" height="34" rx="17" fill="{{color.coral}}"/>
    <text x="382" y="233" text-anchor="middle" fill="{{color.ink}}" font-family="{{font.body}}" font-size="{{type.caption}}" font-weight="700">含まない</text>
    <text data-slot="excludes" x="454" y="234" fill="{{color.inkSub}}" font-family="{{font.body}}" font-size="{{type.body}}">記事本文の代わりになる装飾</text>
  </g>

  <text data-slot="source" x="64" y="620" fill="{{color.inkMute}}" font-family="{{font.body}}" font-size="{{type.caption}}">筆者作成</text>
  <g transform="translate(892 586)">{{>brand}}</g>
</svg>

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShelfIllustration extends StatelessWidget {
  const ShelfIllustration({super.key});

  // الألوان من الـ prototype (light). عدّل قيم الـ dark بعد ما تقيسها.
  static const _l = (
    vase: 'B9A898',
    vaseDark: '8E7E70',
    candle: 'D9D3C7',
    label: '6D6A63',
    flame: 'D9A25B',
    flameIn: 'F5D9A3',
    leaf: '7D8A72',
    stem: '6B6A55',
    pot: 'E7E3DC',
    shelf: 'B9A898',
  );
  static const _d = (
    vase: '8E7E70',
    vaseDark: '6B5E52',
    candle: '5A5750',
    label: 'BDBDB5',
    flame: 'D9A25B',
    flameIn: 'F5D9A3',
    leaf: '8FA083',
    stem: '8E8E86',
    pot: '6D6A63',
    shelf: '6B5E52',
  );

  String _c(String hex) => '#$hex';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final p = dark ? _d : _l;

    final vase =
        '''
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
<ellipse cx="100" cy="171" rx="52" ry="7" fill="#000" opacity=".09"/>
<path d="M84 52h32l-2 10c22 18 30 46 22 76-4 18-18 28-36 28s-32-10-36-28c-8-30 0-58 22-76l-2-10Z" fill="${_c(p.vase)}"/>
<path d="M84 52h32l-2 10H86l-2-10Z" fill="${_c(p.vaseDark)}" opacity=".5"/>
<path d="M100 50c-2-18-14-30-24-34M100 50c3-14 12-24 22-28M100 50c-8-10-18-14-28-12" stroke="${_c(p.vaseDark)}" stroke-width="2.2" fill="none" stroke-linecap="round"/>
<ellipse cx="80" cy="110" rx="5" ry="22" fill="#fff" opacity=".18"/>
</svg>''';

    final candle =
        '''
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
<ellipse cx="100" cy="171" rx="52" ry="7" fill="#000" opacity=".09"/>
<rect x="66" y="74" width="68" height="94" rx="16" fill="${_c(p.candle)}"/>
<rect x="66" y="74" width="68" height="94" rx="16" fill="#fff" opacity=".18"/>
<rect x="74" y="112" width="52" height="30" rx="4" fill="${_c(p.label)}" opacity=".85"/>
<path d="M100 74v-10" stroke="${_c(p.label)}" stroke-width="2"/>
<path d="M100 40c7 8 8 16 0 24-8-8-7-16 0-24Z" fill="${_c(p.flame)}"/>
<path d="M100 50c3 4 3 8 0 12-3-4-3-8 0-12Z" fill="${_c(p.flameIn)}"/>
</svg>''';

    final plant =
        '''
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
<ellipse cx="100" cy="171" rx="52" ry="7" fill="#000" opacity=".09"/>
<path d="M100 104c-2-24 0-46 4-66" stroke="${_c(p.stem)}" stroke-width="3" fill="none"/>
<g fill="${_c(p.leaf)}">
<ellipse cx="88" cy="56" rx="14" ry="5" transform="rotate(-30 88 56)"/>
<ellipse cx="116" cy="46" rx="14" ry="5" transform="rotate(25 116 46)"/>
<ellipse cx="86" cy="80" rx="15" ry="5" transform="rotate(-20 86 80)"/>
<ellipse cx="117" cy="72" rx="15" ry="5" transform="rotate(30 117 72)"/>
<ellipse cx="104" cy="32" rx="12" ry="4.5" transform="rotate(-70 104 32)"/>
<ellipse cx="114" cy="94" rx="13" ry="4.5" transform="rotate(15 114 94)"/>
</g>
<path d="M66 106h68l-8 62H74l-8-62Z" fill="${_c(p.pot)}"/>
<rect x="62" y="100" width="76" height="12" rx="4" fill="${_c(p.pot)}"/>
<rect x="62" y="100" width="76" height="12" rx="4" fill="#000" opacity=".06"/>
</svg>''';

    Widget svg(String s) =>
        SvgPicture.string(s, width: 76, height: 76, matchTextDirection: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [svg(vase), svg(candle), svg(plant)],
        ),
        Transform.translate(
          offset: const Offset(0, -6),
          child: Container(
            width: 250,
            height: 8,
            decoration: BoxDecoration(
              color: _hexColor(p.shelf),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Color _hexColor(String h) => Color(int.parse('FF$h', radix: 16));
}

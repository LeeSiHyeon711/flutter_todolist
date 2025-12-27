import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

// 조건부 import: 웹에서는 web 구현, 모바일에서는 stub 사용
import 'banner_ad_widget_stub.dart'
    if (dart.library.html) 'banner_ad_widget_web.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? banner;
  String? _webAdViewId;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // 웹에서는 HTML 기반 광고 표시
      _initWebAd();
    } else {
      // 모바일에서는 기존 방식 사용
      _initMobileAd();
    }
  }

  void _initWebAd() {
    // 웹 전용 함수 호출 (조건부 import로 처리됨)
    _webAdViewId = initWebAd();
  }

  void _initMobileAd() {
    // 사용할 광고 ID를 설정합니다.
    final adUnitId = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ca-app-pub-3940256099942544/2934735716'
        : 'ca-app-pub-3940256099942544/6300978111';

    // 광고를 생성합니다.
    banner = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,

      // 광고의 생명주기가 변경될 때마다 실행할 함수들을 설정합니다.
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
        onAdLoaded: (ad) {
          // 광고 로드 성공
        },
      ),

      // 광고 요청 정보를 담고있는 클래스
      request: AdRequest(),
    );

    // 광고를 로드합니다.
    banner!.load();
  }

  @override
  void dispose() {
    // 위젯이 dispose 되면 광고 또한 dispose 합니다.
    banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // 웹에서는 HtmlElementView 사용
      if (_webAdViewId == null) {
        return SizedBox.shrink();
      }
      
      return SizedBox(
        height: 75,
        width: double.infinity,
        child: HtmlElementView(
          viewType: _webAdViewId!,
        ),
      );
    } else {
      // 모바일에서는 기존 방식
      if (banner == null) {
        return SizedBox.shrink();
      }

      return SizedBox(
        // 광고의 높이를 지정해줍니다.
        height: 75,

        // 광고 위젯에 banner 변수를 입력해줍니다.
        child: AdWidget(ad: banner!),
      );
    }
  }
}
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide String;
import 'package:flutter/services.dart';

import 'native_admob_controller.dart';
import 'native_admob_options.dart';

const _viewType = "native_admob";
const _bannerViewType = "banner_admob";

enum NativeAdmobType { banner, full }

class NativeAdmob extends StatefulWidget {
  final String adUnitID;
  final NativeAdmobOptions options;
  final NativeAdmobType type;
  final int numberAds;

  final Widget loading;
  final Widget error;

  final NativeAdmobController controller;

  NativeAdmob({
    Key key,
    @required this.adUnitID,
    this.options,
    this.loading,
    this.error,
    this.controller,
    this.numberAds = 1,
    this.type = NativeAdmobType.full,
  })  : assert(adUnitID.isNotEmpty),
        super(key: key);

  @override
  _NativeAdmobState createState() => _NativeAdmobState();
}

class _NativeAdmobState extends State<NativeAdmob> {
  static final isAndroid = defaultTargetPlatform == TargetPlatform.android;
  static final isiOS = defaultTargetPlatform == TargetPlatform.iOS;

  NativeAdmobController _nativeAdController;

  NativeAdmobOptions get _options => widget.options ?? NativeAdmobOptions();
  NativeAdmobType get _type => widget.type ?? NativeAdmobType.full;

  Widget get _loading =>
      widget.loading ?? Center(child: CircularProgressIndicator());

  Widget get _error => widget.error ?? Container();

  var _loadState = AdLoadState.loading;
  StreamSubscription _subscription;

  @override
  void initState() {
    _nativeAdController = widget.controller ?? NativeAdmobController();
    _nativeAdController.setAdUnitID(widget.adUnitID,
        numberAds: widget.numberAds);

    _subscription = _nativeAdController.stateChanged.listen((state) {
      setState(() {
        _loadState = state;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();

    // We only dispose internal controller, external controller will be kept
    if (widget.controller == null) _nativeAdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isAndroid || isiOS) {
      return Container(
        child: _loadState == AdLoadState.loading
            ? _loading
            : _loadState == AdLoadState.loadError
                ? _error
                : _createPlatformView(),
      );
    }

    return Text('$defaultTargetPlatform is not supported PlatformView yet.');
  }

  Widget _createPlatformView() {
    final creationParams = {
      "options": _options.toJson(),
      "controllerID": _nativeAdController.id,
      "type": _type.toString().replaceAll("NativeAdmobType.", ""),
    };

    return isAndroid
        ? AndroidView(
            viewType: _viewType,
            creationParamsCodec: StandardMessageCodec(),
            creationParams: creationParams,
          )
        : UiKitView(
            viewType: _viewType,
            creationParamsCodec: StandardMessageCodec(),
            creationParams: creationParams,
          );
  }
}

class BannerAdmob extends StatefulWidget {
  final String adUnitID;
  final Widget loading;
  final Widget error;
  final BannerAdmobController controller;

  const BannerAdmob(
      {Key key,
      @required this.adUnitID,
      this.loading,
      this.error,
      this.controller})
      : super(key: key);
  @override
  _BannerAdmobState createState() => _BannerAdmobState();
}

class _BannerAdmobState extends State<BannerAdmob> {
  static final isAndroid = defaultTargetPlatform == TargetPlatform.android;
  static final isiOS = defaultTargetPlatform == TargetPlatform.iOS;

  BannerAdmobController _bannerAdController;

  Widget get _loading =>
      widget.loading ?? Center(child: CircularProgressIndicator());

  Widget get _error => widget.error ?? Container();

  var _loadState = AdLoadState.loading;
  StreamSubscription _subscription;

  @override
  void initState() {
    _bannerAdController = widget.controller ?? BannerAdmobController();
    _bannerAdController.setAdUnitID(widget.adUnitID);

    _subscription = _bannerAdController.stateChanged.listen((state) {
      setState(() {
        _loadState = state;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    // We only dispose internal controller, external controller will be kept
    if (widget.controller == null) _bannerAdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isAndroid || isiOS) {
      return Container(
        child: _loadState == AdLoadState.loading
            ? _loading
            : _loadState == AdLoadState.loadError
                ? _error
                : _createPlatformView(),
      );
    }

    return Text('$defaultTargetPlatform is not supported PlatformView yet.');
  }

  Widget _createPlatformView() {
    final creationParams = {
      "controllerID": _bannerAdController.id,
    };

    return isAndroid
        ? AndroidView(
            viewType: _bannerViewType,
            creationParamsCodec: StandardMessageCodec(),
            creationParams: creationParams,
          )
        : UiKitView(
            viewType: _bannerViewType,
            creationParamsCodec: StandardMessageCodec(),
            creationParams: creationParams,
          );
  }
}

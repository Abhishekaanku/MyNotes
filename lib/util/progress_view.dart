import 'dart:async';

import 'package:flutter/material.dart';

typedef UpdateLoader = bool Function(String content);
typedef CloseLoader = void Function();

class LoaderController {
  final UpdateLoader updateLoader;
  final CloseLoader closeLoader;

  LoaderController({required this.updateLoader, required this.closeLoader});
}

class LoaderView {
  LoaderController? _controller;

  static final LoaderView _instance = LoaderView._singleton();

  LoaderView._singleton();

  factory LoaderView() => _instance;

  void showLoadingView(
      {required BuildContext context, required String content}) {
    if (_controller?.updateLoader(content) ?? false) {
      return;
    }
    _controller = createProgressView(context: context, content: content);
  }

  void hideLoadingView() {
    _controller?.closeLoader();
    _controller = null;
  }

  LoaderController createProgressView(
      {required BuildContext context, required String content}) {
    StreamController contentController = StreamController<String>();
    contentController.add(content);
    final overlayState = Overlay.of(context);

    final size = context.size!;

    final overlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withAlpha(150),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: size.height * 0.8,
              minHeight: size.height * 0.2,
              minWidth: size.width * 0.5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.5),
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    StreamBuilder(
                      stream: contentController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data,
                            textAlign: TextAlign.center,
                          );
                        }
                        return Container();
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlayState.insert(overlay);
    return LoaderController(
      updateLoader: (content) {
        contentController.add(content);
        return true;
      },
      closeLoader: () {
        contentController.close();
        overlay.remove();
      },
    );
  }
}

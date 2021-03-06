import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_reader/common/constant/constants.dart' as constants;
import 'package:quran_reader/common/geature/allow_multiple_gesture_recognizer.dart';
import 'package:quran_reader/common/util/flutter_device_type.dart';
import 'package:quran_reader/feature/home/bloc/blocs.dart';
import 'package:quran_reader/feature/home/ui/widget/responsive_image_widget.dart';
import 'package:quran_reader/feature/quran_page/bloc/blocs.dart';

class QuranPageWidget extends StatefulWidget {
  @override
  _QuranPageWidgetState createState() => _QuranPageWidgetState();
}

class _QuranPageWidgetState extends State<QuranPageWidget> {
  PageController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  _onPageViewChange(int page) {
    BlocProvider.of<QuranPageBloc>(context).add(LoadPage(pageNumber: page));
  }

  @override
  Widget build(BuildContext context) {
    if (BlocProvider.of<QuranPageBloc>(context).initialState
        is QuranPageJumpedTo) {
      final initialPage = (BlocProvider.of<QuranPageBloc>(context).initialState
              as QuranPageJumpedTo)
          .quranPage
          .page;
      _controller = PageController(initialPage: initialPage);
    }

    return RawGestureDetector(
        gestures: {
          AllowMultipleGestureRecognizer: GestureRecognizerFactoryWithHandlers<
              AllowMultipleGestureRecognizer>(
            () => AllowMultipleGestureRecognizer(),
            (AllowMultipleGestureRecognizer instance) {
              instance.onTap = () => {
                    BlocProvider.of<HomePageBloc>(context)
                        .add(HomePageViewTapped())
                  };
            },
          )
        },
        behavior: HitTestBehavior.opaque,
        //Parent Container
        child: BlocListener<QuranPageBloc, QuranPageState>(
            listener: (context, state) {
              if (state is QuranPageJumpedTo) {
                _controller.animateToPage(state.quranPage.page,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear);
              }
            },
            child: PageView.builder(
                itemBuilder: (context, index) {
                  if (Device.get().isWeb || Device.get().isComputer) {
                    final firstIndex = index + 2;
                    final secondIndex = index + 1;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: ResponsiveImageWidget(
                                quranPage:
                                    BlocProvider.of<QuranPageBloc>(context)
                                        .fetchQuranPage(firstIndex))),
                        Expanded(
                            flex: 1,
                            child: ResponsiveImageWidget(
                                quranPage:
                                    BlocProvider.of<QuranPageBloc>(context)
                                        .fetchQuranPage(secondIndex)))
                      ],
                    );
                  } else {
                    return ResponsiveImageWidget(
                        quranPage: BlocProvider.of<QuranPageBloc>(context)
                            .fetchQuranPage(index + 1));
                  }
                },
                reverse: true,
                onPageChanged: _onPageViewChange,
                itemCount: constants.end_quran_page_number,
                controller: _controller)));
  }
}

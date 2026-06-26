import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenGallery> createState() =>
      _FullScreenGalleryState();
}

class _FullScreenGalleryState
    extends State<FullScreenGallery> {

  late final PageController _controller;

  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _controller = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: Stack(

        children: [

          PhotoViewGallery.builder(

            pageController: _controller,

            itemCount: widget.images.length,

            onPageChanged: (index) {

              setState(() {

                _currentIndex = index;

              });

            },

            builder: (context, index) {

              return PhotoViewGalleryPageOptions(

                heroAttributes:

                    PhotoViewHeroAttributes(

                  tag: widget.images[index],

                ),

                imageProvider:

                    NetworkImage(widget.images[index]),

                minScale:

                    PhotoViewComputedScale.contained,

                maxScale:

                    PhotoViewComputedScale.covered * 3,

              );

            },

            loadingBuilder: (context, event) {

              return const Center(

                child:

                    CircularProgressIndicator(),

              );

            },
          ),

          SafeArea(

            child: Align(

              alignment: Alignment.topLeft,

              child: IconButton(

                icon: const Icon(

                  Icons.arrow_back_ios,

                  color: Colors.white,

                ),

                onPressed: () {

                  Navigator.pop(context);

                },

              ),
            ),
          ),

          Positioned(

            top: 18,

            right: 20,

            child: SafeArea(

              child: Container(

                padding:

                    const EdgeInsets.symmetric(

                  horizontal: 14,

                  vertical: 8,

                ),

                decoration: BoxDecoration(

                  color: Colors.black54,

                  borderRadius:

                      BorderRadius.circular(30),

                ),

                child: Text(

                  '${_currentIndex + 1} / ${widget.images.length}',

                  style: const TextStyle(

                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                  ),

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
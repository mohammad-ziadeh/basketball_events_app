import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiba_3x3/services/carousel_service.dart';
import 'package:flutter/material.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({super.key});

  @override
  CarouselWidgetState createState() => CarouselWidgetState();
}

class CarouselWidgetState extends State<CarouselWidget> {
  late PageController _controller;
  int currentPage = 0;

  List<Carousel> carouselData = [];
  bool isLoading = true;
  String? errorMessage;

  final Duration autoPlayInterval = const Duration(seconds: 15);
  bool _autoPlayRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoPlayRunning = false;
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      if (carouselData.isEmpty) isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await CarouselService.fetchCarouselData();

      _controller.dispose();
      _controller = PageController();

      setState(() {
        carouselData = data;
        isLoading = false;
        currentPage = 0;
      });

      if (!_autoPlayRunning) {
        _autoPlayRunning = true;
        startAutoPlay();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        if (carouselData.isEmpty) {
          errorMessage = 'Failed to load carousel data. Please try again.';
        }
      });

      if (mounted && carouselData.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to refresh carousel data.')),
        );
      }
    }
  }

  void startAutoPlay() async {
    while (mounted && _autoPlayRunning) {
      await Future.delayed(autoPlayInterval);

      if (!mounted || carouselData.isEmpty) return;

      if (currentPage < carouselData.length - 1) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() => currentPage++);
      } else {
        _controller.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() => currentPage = 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height * 0.45;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: fetchData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050, maxHeight: 700),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: carouselData.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) {
                  final item = carouselData[index];

                  final imageUrl =
                      (item.imageUrl != null &&
                              item.imageUrl!.trim().isNotEmpty)
                          ? '${item.imageUrl}?refresh=${item.updatedAt}'
                          : 'https://picsum.photos/600/220';

                  return SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            width: double.infinity,
                            height: imageHeight,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            width: double.infinity,
                            height: imageHeight,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                    ),
                  );
                },
              ),

              // Title Box
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    width: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white.withOpacity(0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            carouselData[currentPage].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              letterSpacing: -1.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF8b0000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Tag Box
              Positioned(
                top: MediaQuery.of(context).size.height * 0.405,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8b0000),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      carouselData[currentPage].tag,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation Arrows
              Positioned(
                top: 0,
                left: 16,
                right: 16,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _navArrow(Icons.arrow_back_ios_new, () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }),
                    _navArrow(Icons.arrow_forward_ios, () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }),
                  ],
                ),
              ),

              // Page Indicator
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      carouselData.asMap().entries.map((entry) {
                        return Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 4.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                currentPage == entry.key
                                    ? Colors.white
                                    : Colors.white60,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navArrow(IconData icon, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.black.withOpacity(0.3),
      ),
      child: IconButton(
        icon: Icon(icon, size: 25, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

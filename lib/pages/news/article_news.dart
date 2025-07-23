import 'package:fiba_3x3/widgets/appBar.dart';
import 'package:fiba_3x3/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fiba_3x3/services/news_api_service.dart';

class BasketballNewsPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const BasketballNewsPage({super.key, required this.onToggleTheme});

  @override
  State<BasketballNewsPage> createState() => _BasketballNewsPageState();
}

class _BasketballNewsPageState extends State<BasketballNewsPage> {
  final NewsService _newsService = NewsService();
  List<dynamic> _articles = [];
  bool _isLoading = true;
  bool _isError = false;
  int _currentPage = 1;
  final int _pageSize = 15;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
    }

    try {
      final articles = await _newsService.fetchBasketballNews(
        page: _currentPage,
        pageSize: loadMore ? 5 : _pageSize,
      );

      setState(() {
        if (loadMore) {
          _articles.addAll(articles);
        } else {
          _articles = articles;
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadMore() {
    _currentPage++;
    _fetchNews(loadMore: true);
  }

  void _openArticle(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Article URL is empty')));
      return;
    }

    if (await canLaunch(url)) {
      final launched = await launch(url);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to launch the URL')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: ResponsiveAppBar(onToggleTheme: widget.onToggleTheme),
      body: RefreshIndicator(
        onRefresh: () async {
          _currentPage = 1;
          await _fetchNews();
        },
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _isError
                ? const Center(
                  child: Text('Failed to load news. Pull to refresh.'),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _articles.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _articles.length) {
                      return _isLoadingMore
                          ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : TextButton(
                            onPressed: _loadMore,
                            child: Text(
                              'Load More',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                    }

                    final article = _articles[index];
                    return GestureDetector(
                      onTap: () => _openArticle(article['url'] ?? ''),
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: isDark ? Colors.grey[900] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article['urlToImage'] != null &&
                                article['urlToImage'].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  article['urlToImage'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        height: 200,
                                        color: Colors.grey,
                                        child: const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['title'] ?? 'No Title',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    article['description'] ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    article['source']?['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isDark
                                              ? Colors.grey
                                              : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      endDrawer: const CustomDrawer(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'dart:convert';
import '../widgets/cosmic_background.dart';
import '../services/remote_config_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TarotChannel {
  final String channelId;
  final String name;
  final String description;
  final Color color;

  TarotChannel({
    required this.channelId,
    required this.name,
    required this.description,
    required this.color,
  });
}

class SCR_01_HubTarot extends StatefulWidget {
  const SCR_01_HubTarot({super.key});

  @override
  State<SCR_01_HubTarot> createState() => _SCR_01_HubTarotState();
}

class _SCR_01_HubTarotState extends State<SCR_01_HubTarot> {
  late RemoteConfigService _remoteConfig;
  final Map<String, List<dynamic>> _videoCache = {};
  List<dynamic> videoResult = [];
  bool isLoading = true;
  String? errorMessage;

  final Map<String, TarotChannel> channels = {
    'tarotinteractivodehoy': TarotChannel(
      channelId: 'UC3Wapq69I8mauKqa3vIzD_g',
      name: 'Tarot Interactivo de Hoy',
      description: 'Tiradas interactivas diarias',
      color: Colors.purple,
    ),
    'keylatarotoficial': TarotChannel(
      channelId: 'UCsy40ssNTjdG7_hE3A6TUlA',
      name: 'Keyla Tarot',
      description: 'Lecturas y predicciones',
      color: Colors.indigo,
    ),
    'TarotdeTallulah': TarotChannel(
      channelId: 'UCjSp8-zfidl_cbz8YijgcCw',
      name: 'Tarot de Tallulah',
      description: 'Lecturas y guía espiritual',
      color: Colors.deepPurple,
    ),
  };

  String selectedChannel = 'tarotinteractivodehoy';

  @override
  void initState() {
    super.initState();
    _remoteConfig = RemoteConfigService();
    _initializeYouTubeApi();
  }

  Future<void> _initializeYouTubeApi() async {
    try {
      await _remoteConfig.initialize();
      final apiKey = _remoteConfig.youtubeApiKey;
      debugPrint('API Key length: ${apiKey.length}');

      if (apiKey.isEmpty) {
        throw Exception('API key no configurada en Firebase Remote Config');
      }

      debugPrint('API Key obtenida correctamente');
      await callAPI();
    } catch (e) {
      setState(() {
        errorMessage = 'Error de inicialización: $e';
        isLoading = false;
      });
    }
  }

  Future<void> callAPI() async {
    setState(() => isLoading = true);

    try {
      if (_videoCache.containsKey(selectedChannel)) {
        setState(() {
          videoResult = _videoCache[selectedChannel]!;
          isLoading = false;
        });
        return;
      }

      final channelId = channels[selectedChannel]!.channelId;
      final apiKey = _remoteConfig.youtubeApiKey;

      final url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?'
              'part=snippet&channelId=$channelId&maxResults=10'
              '&order=date&type=video&key=$apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          videoResult = data['items'];
          _videoCache[selectedChannel] = data['items'];
          isLoading = false;
        });
      } else {
        throw Exception('Error API: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hub de Tarot'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildChannelSelector(),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: _buildVideoGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelSelector() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channelId = channels.keys.elementAt(index);
          final channel = channels[channelId]!;
          final isSelected = selectedChannel == channelId;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedChannel = channelId;
                errorMessage = null;
              });
              callAPI();
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    channel.color.withOpacity(isSelected ? 0.8 : 0.3),
                    channel.color.withOpacity(isSelected ? 0.6 : 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(isSelected ? 0.5 : 0.1),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    channel.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    channel.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoGrid() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (videoResult.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron videos',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 14,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: videoResult.length,
      itemBuilder: (context, index) {
        return _buildVideoCard(videoResult[index]);
      },
    );
  }

  Widget _buildVideoCard(dynamic video) {
    final snippet = video['snippet'];
    final thumbnailUrl = snippet['thumbnails']['high']['url'];
    final title = snippet['title'];
    final publishedAt = DateTime.parse(snippet['publishedAt']);
    final videoId = video['id']['videoId'];

    return GestureDetector(
      onTap: () {
        debugPrint('Video ID: $videoId');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: channels[selectedChannel]!.color.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: channels[selectedChannel]!.color.withOpacity(0.3),
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                  // Icono de reproducción
                  const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  // Título con fondo difuminado
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.toUpperCase(), // Texto en mayúsculas como en tu ejemplo
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(publishedAt),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
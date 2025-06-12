import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:dangkong_app/models/videoitem_model.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = '전체보기';
  String _searchQuery = '';
  bool _isEditMode = false; // 편집 모드 상태 추가
  Set<int> _selectedItems = Set<int>(); // 선택된 아이템들
  Map<String, String> _thumbnailCache = {}; // 썸네일 캐시

  // 샘플 데이터
  final List<VideoItem> _videos = [
    VideoItem(
      title: '낙상감지',
      date: '2024.04.14 07:30',
      thumbnail: 'assets/images/video_thumbnail.jpg',
      videoUrl: 'assets/images/testvideo.mp4',
      isBookmarked: true,
      category: '낙상',
    ),
    VideoItem(
      title: '사용자 녹화 영상',
      date: '2024.04.14 07:30',
      thumbnail: 'assets/images/video_thumbnail.jpg',
      videoUrl: 'assets/images/testvideo.mp4',
      isBookmarked: false,
      category: '개인녹화',
    ),
    VideoItem(
      title: '움직임 없음',
      date: '2024.04.14 07:30',
      thumbnail: 'assets/images/video_thumbnail.jpg',
      videoUrl: 'assets/images/testvideo.mp4',
      isBookmarked: false,
      category: '움직임 없음',
    ),
  ];

  List<VideoItem> get _filteredVideos {
    List<VideoItem> filteredByCategory;

    if (_selectedFilter == '전체보기') {
      filteredByCategory = _videos;
    } else if (_selectedFilter == '북마크') {
      filteredByCategory =
          _videos.where((video) => video.isBookmarked).toList();
    } else {
      filteredByCategory =
          _videos.where((video) => video.category == _selectedFilter).toList();
    }

    if (_searchQuery.isEmpty) {
      return filteredByCategory;
    } else {
      return filteredByCategory
          .where(
            (video) =>
                video.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedItems.clear();
      }
    });
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('정말로 삭제하시겠습니까?'),
          content: Text(
            '${_selectedItems.length}개의 영상을 삭제합니다.\n삭제된 영상은 복구할 수 없습니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 실제 삭제 기능 구현
                print('${_selectedItems.length}개 영상 삭제 예정');
                setState(() {
                  _selectedItems.clear();
                  _isEditMode = false;
                });
              },
              child: Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _playVideo(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  Future<void> _downloadVideo(String videoUrl, String title) async {
    try {
      // assets에서 파일 읽기
      final byteData = await rootBundle.load(videoUrl);
      final buffer = byteData.buffer;

      // 외부 저장소 경로 가져오기
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        // 외부 저장소를 사용할 수 없는 경우 내부 저장소 사용
        directory = await getApplicationDocumentsDirectory();
      }

      // 파일명 생성 (타임스탬프 포함)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${title}_$timestamp.mp4';
      final filePath = '${directory.path}/$fileName';

      // 파일 저장
      final file = File(filePath);
      await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('영상이 저장되었습니다: $fileName'),
          backgroundColor: Color(0xFF8BC34A),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '필터',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildFilterOptions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterOptions() {
    final List<String> filterOptions = ['전체보기', '북마크', '낙상', '개인녹화', '움직임 없음'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildFilterOption('전체보기', filterOptions[0])),
            SizedBox(width: 12),
            Expanded(child: _buildFilterOption('북마크', filterOptions[1])),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildFilterOption('낙상', filterOptions[2])),
            SizedBox(width: 12),
            Expanded(child: _buildFilterOption('개인녹화', filterOptions[3])),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildFilterOption('움직임 없음', filterOptions[4])),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterOption(String title, String value) {
    bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFFB1DB99) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? Color(0xFFB1DB99) : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                      : null,
            ),
            SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/images/logo2.png', height: 30),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFB1DB99), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '영상 제목으로 검색하기',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
          ),

          // 필터 섹션
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                if (!_isEditMode) ...[
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 8),
                        Text(
                          '필터',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$_selectedFilter 적용중',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 검색어 표시
                  if (_searchQuery.isNotEmpty) ...[
                    SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFB1DB99).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            '"$_searchQuery"',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Spacer(),
                  GestureDetector(
                    onTap: _toggleEditMode,
                    child: Text(
                      '편집',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ] else ...[
                  // 편집 모드일 때
                  Text(
                    '${_selectedItems.length}개 선택됨',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: _toggleEditMode,
                    child: Text(
                      '취소',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 8),

          // 영상 리스트
          Expanded(
            child:
                _filteredVideos.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.video_library_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? '검색 결과가 없습니다'
                                : '영상이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            SizedBox(height: 8),
                            Text(
                              '"$_searchQuery"에 대한 결과를 찾을 수 없습니다',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8).copyWith(
                        bottom:
                            _isEditMode && _selectedItems.isNotEmpty ? 80 : 0,
                      ),
                      itemCount: _filteredVideos.length,
                      itemBuilder: (context, index) {
                        return VideoListItem(
                          video: _filteredVideos[index],
                          isEditMode: _isEditMode,
                          isSelected: _selectedItems.contains(index),
                          thumbnailPath:
                              _thumbnailCache[_filteredVideos[index].videoUrl],
                          onTap: () {
                            if (_isEditMode) {
                              setState(() {
                                if (_selectedItems.contains(index)) {
                                  _selectedItems.remove(index);
                                } else {
                                  _selectedItems.add(index);
                                }
                              });
                            } else {
                              _playVideo(_filteredVideos[index].videoUrl);
                            }
                          },
                          onDownload:
                              () => _downloadVideo(
                                _filteredVideos[index].videoUrl,
                                _filteredVideos[index].title,
                              ),
                          onBookmark: () {
                            setState(() {
                              int originalIndex = _videos.indexWhere(
                                (video) =>
                                    video.title ==
                                        _filteredVideos[index].title &&
                                    video.date == _filteredVideos[index].date,
                              );
                              if (originalIndex != -1) {
                                _videos[originalIndex].isBookmarked =
                                    !_videos[originalIndex].isBookmarked;
                              }
                            });
                          },
                        );
                      },
                    ),
          ),

          // 편집 모드일 때 하단 텍스트
          if (_isEditMode && _selectedItems.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // 왼쪽 칸 (편집 취소하기)
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _toggleEditMode,
                        child: Text(
                          '편집 취소하기',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 오른쪽 칸 (영상 제거 하기)
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _showDeleteConfirmDialog,
                        child: Text(
                          '영상 제거 하기',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
    );
  }
}

// 비디오 재생 화면

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _isPlaying = true;
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isFullScreen) {
      _exitFullScreen();
    }
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        _enterFullScreen();
      } else {
        _exitFullScreen();
      }
    });
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(100),
      body:
          _isFullScreen
              ? _buildFullScreenPlayer()
              : SafeArea(child: _buildNormalPlayer()),
    );
  }

  Widget _buildNormalPlayer() {
    return Center(
      child:
          _controller.value.isInitialized
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleFullScreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: const Color(0xFF8BC34A),
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.grey[800]!,
                      ),
                    ),
                  ),
                ],
              )
              : const CircularProgressIndicator(color: Color(0xFF8BC34A)),
    );
  }

  Widget _buildFullScreenPlayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _controller.value.isInitialized
            ? Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
            : const Center(
              child: CircularProgressIndicator(color: Color(0xFF8BC34A)),
            ),
        Positioned(
          bottom: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(
              Icons.fullscreen_exit,
              color: Colors.white,
              size: 36,
            ),
            onPressed: _toggleFullScreen,
          ),
        ),
      ],
    );
  }
}

class VideoListItem extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onBookmark;
  final bool isEditMode;
  final bool isSelected;
  final String? thumbnailPath;

  const VideoListItem({
    Key? key,
    required this.video,
    required this.onTap,
    required this.onDownload,
    required this.onBookmark,
    this.isEditMode = false,
    this.isSelected = false,
    this.thumbnailPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 편집 모드일 때 체크박스, 아니면 북마크 아이콘
          GestureDetector(
            onTap: isEditMode ? onTap : onBookmark,
            child: Container(
              width: 45,
              height: 45,
              margin: EdgeInsets.only(right: 8),
              child: Center(
                child:
                    isEditMode
                        ? Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Color(0xFF8BC34A)
                                      : Colors.grey[400]!,
                              width: 2,
                            ),
                            color:
                                isSelected
                                    ? Color(0xFF8BC34A)
                                    : Colors.transparent,
                          ),
                          child:
                              isSelected
                                  ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                  : null,
                        )
                        : Icon(
                          video.isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color:
                              video.isBookmarked
                                  ? Color(0xFF8BC34A)
                                  : Colors.grey[400],
                          size: 25,
                        ),
              ),
            ),
          ),

          // 영상 정보 컨테이너
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(5),
                leading: Container(
                  width: 60,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        thumbnailPath != null &&
                                File(thumbnailPath!).existsSync()
                            ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(thumbnailPath!),
                                  fit: BoxFit.cover,
                                ),
                                Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 24,
                                  ),
                                ),
                              ],
                            )
                            : Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 24,
                            ),
                  ),
                ),
                title: Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    video.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                trailing:
                    isEditMode
                        ? null
                        : IconButton(
                          icon: Icon(
                            Icons.download,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: onDownload,
                        ),
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

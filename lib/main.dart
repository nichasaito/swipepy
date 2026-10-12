import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'dart:typed_data'; // ต้อง import เพิ่มด้านบนสุดของไฟล์ด้วยนะครับ
import 'package:photo_manager/photo_manager.dart'; // import เพิ่มด้านบนสุดของไฟล์

void main() {
  runApp(const CutePhotoCleanerApp());
}

class CutePhotoCleanerApp extends StatelessWidget {
  const CutePhotoCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Cleaner',
      theme: ThemeData(
        primaryColor: const Color(0xFFFFAFD3),
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        fontFamily: 'Mali',
        useMaterial3: true,
      ),
      home: const MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ================= หน้าเมนูหลัก =================
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.cleaning_services_rounded,
                size: 80,
                color: Color(0xFFFFAFD3),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Photo Cleaner',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD67B9F),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'เคลียร์พื้นที่ให้ว่าง สำหรับความทรงจำใหม่ๆ ✨',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SwipeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAFD3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'เริ่มจัดรูปภาพกันเลย!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= หน้าปัดการ์ดรูปภาพ =================
class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final CardSwiperController controller = CardSwiperController();
  
  List<AssetEntity> _images = []; // เปลี่ยนจาก List จำลองเป็น List รูปจริง
  bool _isLoading = true; // สถานะกำลังโหลด
  bool _hasPermission = false; // สถานะการอนุญาต

  @override
  void initState() {
    super.initState();
    _loadPhotos(); // เรียกใช้ฟังก์ชันดึงรูปตอนเปิดหน้านี้
  }

  // ฟังก์ชันขออนุญาตและดึงรูป
  Future<void> _loadPhotos() async {
    // 1. ขอสิทธิ์เข้าถึงแกลเลอรี
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    
    if (ps.isAuth || ps.hasAccess) {
      setState(() { _hasPermission = true; });
      
      // 2. ดึงอัลบั้มทั้งหมด (เลือกเฉพาะรูปภาพ)
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      
      if (albums.isNotEmpty) {
        // 3. ดึงรูปล่าสุด 100 รูปแรก จากอัลบั้ม Recent (อัลบั้มแรกสุดมักเป็น Recent เสมอ)
        List<AssetEntity> photos = await albums[0].getAssetListPaged(page: 0, size: 100);
        
        setState(() {
          _images = photos;
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
    } else {
      // กรณีผู้ใช้ไม่อนุญาต
      setState(() { _isLoading = false; });
      PhotoManager.openSetting(); // เด้งไปหน้าตั้งค่าของมือถือ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ปัดซ้าย 👈 ลบ | ปัดขวา 👉 เก็บ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFFD67B9F),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFAFD3)))
            : !_hasPermission 
                ? const Center(child: Text('แอปต้องการสิทธิ์เข้าถึงรูปภาพนะ 🥺'))
                : _images.isEmpty 
                    ? const Center(child: Text('ไม่พบรูปภาพในเครื่องจ้า ✨'))
                    : Column(
                        children: [
                          Expanded(
                            child: CardSwiper(
                              controller: controller,
                              cardsCount: _images.length,
                              onSwipe: _onSwipe,
                              numberOfCardsDisplayed: 2,
                              padding: const EdgeInsets.all(24.0),
                              cardBuilder: (context, index) {
                                return _buildCard(_images[index]);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: Icons.close_rounded,
                                  color: Colors.redAccent,
                                  onPressed: () => controller.swipeLeft(),
                                ),
                                _buildActionButton(
                                  icon: Icons.favorite_rounded,
                                  color: Colors.greenAccent.shade400,
                                  onPressed: () => controller.swipeRight(),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
      ),
    );
  }

  // แก้ไขวิดเจ็ตการ์ด ให้รองรับรูปจาก AssetEntity
  Widget _buildCard(AssetEntity asset) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ใช้ FutureBuilder เพื่อแปลงข้อมูลรูปภาพมาแสดง
            FutureBuilder<Uint8List?>(
              future: asset.thumbnailDataWithSize(const ThumbnailSize(800, 800)), // ดึงรูปแบบบีบอัดเพื่อให้ปัดลื่นๆ
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                }
                // ระหว่างโหลดรูปแต่ละใบ ให้โชว์สีชมพูอ่อนๆ ไว้ก่อน
                return Container(color: const Color(0xFFFFF0F5)); 
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    // ... (โค้ดปุ่มเหมือนเดิม) ...
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 40),
        color: color,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

// เปลี่ยนฟังก์ชันเป็นแบบ async เพื่อให้รอคำสั่งลบทำงาน
  void _onSwipe(
    int? previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    if (previousIndex == null) return;
    
    AssetEntity swipedPhoto = _images[previousIndex];

    if (direction == CardSwiperDirection.left) {
      debugPrint('👉 สั่งลบรูป ID: ${swipedPhoto.id}');
      
      // คำสั่งลบรูปจริงในเครื่อง
      try {
        final List<String> result = await PhotoManager.editor.deleteWithIds([swipedPhoto.id]);
        if (result.isNotEmpty) {
          debugPrint('✅ ลบรูปสำเร็จ!');
        } else {
          debugPrint('❌ ผู้ใช้ยกเลิกการลบ หรือลบไม่สำเร็จ');
        }
      } catch (e) {
        debugPrint('เกิดข้อผิดพลาดในการลบ: $e');
      }

    } else if (direction == CardSwiperDirection.right) {
      debugPrint('👉 เก็บรูปรักษาไว้ ID: ${swipedPhoto.id}');
    }
  }
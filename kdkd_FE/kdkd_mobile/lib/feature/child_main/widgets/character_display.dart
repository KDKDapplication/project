import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/child_main/providers/character_provider.dart';
import 'package:kdkd_mobile/feature/child_main/providers/child_tab_provider.dart';

class CharacterDisplay extends ConsumerStatefulWidget {
  const CharacterDisplay({super.key});

  @override
  ConsumerState<CharacterDisplay> createState() => _CharacterDisplayState();
}

class _CharacterDisplayState extends ConsumerState<CharacterDisplay> {
  @override
  void initState() {
    super.initState();
    // 페이지 진입 시마다 캐릭터 데이터 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(characterProvider.notifier).fetchCharacterData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 메인 레이아웃
            Column(
              children: [
                // 상단 1/2: 배경과 캐릭터 이미지
                Expanded(
                  flex: 1,
                  child: _buildGameBackground(context),
                ),
                // 하단 1/2: 상태바 + 상호작용 영역
                Expanded(
                  flex: 1,
                  child: _buildBottomSection(context, ref),
                ),
              ],
            ),
            // 상단 X 버튼 (오버레이)
            _buildTopCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBackground(BuildContext context) {
    final characterState = ref.watch(characterProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    final characterImages = [
      'assets/images/character_1.png',
      'assets/images/character_2.png',
      'assets/images/character_3.png',
      'assets/images/character_4.png',
    ];

    final characterImage = switch (characterState) {
      Success(data: final character) => characterImages[character.level.clamp(1, 4) - 1],
      Refreshing(previous: final character) => characterImages[character.level.clamp(1, 4) - 1],
      _ => "assets/images/character_1.png", // 기본 1레벨 이미지
    };

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Transform.translate(
          offset: Offset(0, screenHeight * 0.06),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (characterState is Success)
                // 캐릭터
                Image.asset(
                  characterImage,
                  height: screenHeight * 0.3,
                  filterQuality: FilterQuality.none,
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .moveY(begin: -8, end: 8, duration: 1500.ms, curve: Curves.easeInOut),
              if (characterState is Success)
                // 하트 애니메이션 (캐릭터 위에)
                Positioned(
                  top: -screenHeight * 0.05,
                  child: Image.asset(
                    "assets/images/heart.png",
                    height: screenHeight * 0.09,
                    filterQuality: FilterQuality.none,
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .moveY(begin: -5, end: 5, duration: 1000.ms, curve: Curves.easeInOut)
                      .scale(begin: Offset(0.8, 0.8), end: Offset(1.2, 1.2), duration: 1500.ms),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // This new widget will structure the bottom half of the screen.
  Widget _buildBottomSection(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background2.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatusBar(context, ref),
            _buildBottomInteractionArea(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCloseButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: screenHeight * 0.06,
      right: screenWidth * 0.04,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: screenWidth * 0.1,
          height: screenWidth * 0.1,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: screenWidth * 0.06,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, WidgetRef ref) {
    final characterState = ref.watch(characterProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 캐릭터 데이터에서 레벨 가져오기 (기본값: 1)
    final level = switch (characterState) {
      Success(data: final character) => character.level,
      Refreshing(previous: final character) => character.level,
      _ => 1,
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        border: Border.all(color: const Color(0xFF8B4513), width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildStatusItem(
                icon: Icons.star_rounded,
                label: "레벨",
                value: level.toString(),
                color: Colors.orangeAccent,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildExperienceBar(context, ref),
        ],
      ),
    );
  }

  Widget _buildExperienceBar(BuildContext context, WidgetRef ref) {
    final characterState = ref.watch(characterProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    // 캐릭터 데이터에서 경험치 가져오기 (기본값: 0)
    final experience = switch (characterState) {
      Success(data: final character) => character.experience,
      Refreshing(previous: final character) => character.experience,
      _ => 0,
    };

    final currentExp = experience;
    final maxExpForLevel = 10000; // 각 레벨당 필요 경험치
    final progress = (currentExp / maxExpForLevel).clamp(0.0, 1.0); // 진행률

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "경험치",
                style: TextStyle(
                  fontFamily: 'Chab',
                  fontSize: 16,
                  color: Color(0xFF8B4513),
                ),
              ),
              Text(
                "$currentExp / $maxExpForLevel XP",
                style: TextStyle(
                  fontFamily: 'Chab',
                  fontSize: 12,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: screenHeight * 0.022,
          decoration: BoxDecoration(
            color: const Color(0xFFD4D4D4),
            border: Border.all(color: const Color(0xFF8B4513), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 151, 255, 155),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              // 픽셀 스타일 하이라이트 효과
              Positioned(
                top: 2,
                left: 2,
                right: 2,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 150, 251, 155),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700),
            border: Border.all(color: const Color(0xFF8B4513), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF8B4513), size: 28),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Chab',
            fontSize: 20,
            color: Color(0xFF8B4513),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Chab',
            fontSize: 28,
            color: Color(0xFF8B4513),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInteractionArea(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        border: Border.all(color: const Color(0xFF8B4513), width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGameButtonWithImage(
            context: context,
            imagePath: "assets/images/misstion_pixel.png",
            title: "미션하러가기",
            subtitle: "일일 퀘스트",
            color: const Color.fromARGB(255, 142, 204, 255),
            onTap: () {
              // 미션 페이지로 이동 (탭 인덱스 2)
              ChildTabNotifier.navigateToMission(ref);
              Navigator.of(context).pop();
            },
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildGameButtonWithImage(
            context: context,
            imagePath: "assets/images/collection_pixel.png",
            title: "모으기 상자",
            subtitle: "저축 챌린지",
            color: const Color.fromARGB(255, 188, 255, 140),
            onTap: () {
              // 모으기 상자 페이지로 이동 (탭 인덱스 1)
              ChildTabNotifier.navigateToCollection(ref);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameButtonWithImage({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.01),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // 픽셀 이미지
            Image.asset(
              imagePath,
              height: screenWidth * 0.18,
              width: screenWidth * 0.18,
              filterQuality: FilterQuality.none,
            ),
            SizedBox(width: screenWidth * 0.04),
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Chab',
                      color: const Color.fromARGB(255, 108, 65, 30),
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Chab',
                      color: const Color.fromARGB(255, 68, 45, 26),
                      fontSize: screenWidth * 0.06,
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

  Widget _buildGameButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: screenWidth * 0.08,
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Chab',
                color: Colors.white,
                fontSize: screenWidth * 0.035,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Chab',
                color: Colors.white.withOpacity(0.8),
                fontSize: screenWidth * 0.025,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

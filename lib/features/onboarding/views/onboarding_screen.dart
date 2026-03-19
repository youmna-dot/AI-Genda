import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/local_storage.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF8),
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              OnboardingPage(
                title: 'Plan Smarter with AI',
                description:
                    'Let AI genda organize your tasks and schedule efficiently.',
                image: 'assets/onboarding1.png',
                buttonText: 'Next',
                controller: _controller,
                pageIndex: 0,
              ),
              OnboardingPage(
                title: 'Boost Your Productivity',
                description:
                    'AI genda helps you stay organized and focused on what matters.',
                image: 'assets/onboarding2.png',
                buttonText: 'Next',
                controller: _controller,
                pageIndex: 1,
              ),
              OnboardingPage(
                title: 'Achieve Your Goals with AI',
                description:
                    'Aigenda guides you towards better time management and goal achievement.',
                image: 'assets/onboarding3.png',
                buttonText: 'Get Started',
                controller: _controller,
                pageIndex: 2,
              ),
            ],
          ),
          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => context.go('/auth'),
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF7C5CBF),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final String buttonText;
  final PageController controller;
  final int pageIndex;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.buttonText,
    required this.controller,
    required this.pageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
      
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF0EEF8),
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
        ),

        
        SizedBox(
          height: size.height * 0.38,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFFAF9FF),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(36),
                topRight: Radius.circular(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C3FC8).withOpacity(0.12),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, -8),
                ),
                BoxShadow(
                  color: const Color(0xFF6C3FC8).withOpacity(0.06),
                  blurRadius: 60,
                  spreadRadius: 0,
                  offset: const Offset(0, -20),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C5CBF), Color(0xFFAB8EE0)],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E0F5C),
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  
                  SizedBox(
                    height: 56,
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: const Color(0xFF8A84A3),
                        height: 1.65,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF7C5CBF),
                          Color(0xFF5B3A9E),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C3FC8).withOpacity(0.40),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: const Color(0xFF6C3FC8).withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (buttonText == 'Get Started') {
                            context.go('/auth');
                          } else {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              buttonText,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      dotHeight: 7,
                      dotWidth: 7,
                      expansionFactor: 3.5,
                      spacing: 6,
                      activeDotColor: const Color(0xFF7C5CBF),
                      dotColor: const Color(0xFFD8CEF0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
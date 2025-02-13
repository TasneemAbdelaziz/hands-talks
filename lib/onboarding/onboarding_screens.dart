import 'package:flutter/material.dart';
import 'package:hands_talks/welcome/welcomepage.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNextPressed() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToWelcome();
    }
  }

  void _onSkipPressed() {
    _navigateToWelcome();
  }

  void _navigateToWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              OnboardingPage(
                imagePath: 'assets/images/onboarding1.png',
                title: 'Communicate effectively and gain your confidence',
                description:
                'Welcome to a world of effective communication possibility. Communicate effectively with text, Speech or sign. the choice is yours.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/onboarding2.png',
                title: 'Live Chat',
                description:
                'Talk effectively with chat that guides you through easy communication',
              ),
              OnboardingPage(
                imagePath: 'assets/images/onboarding3.png',
                title: 'SNL Translator',
                description:
                'Effortlessly translate sign language into text and speech, bridging communication gaps for the deaf community with our app\'s powerful translator feature.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/onboarding4.png',
                title: 'Real time in HANDS TALK app and Video call made easy',
                description:
                'Explore the possibility of this app! you don\'t have to move from app to app to communicate with loved one who are far away. use the in-app real time chat and video call.',
              ),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _onNextPressed,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Circle with dynamic ratio
                      Container(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: (_currentPage + 1) /
                              4, // Update ratio dynamically
                          strokeWidth: 4,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      ),
                      // Inner Circle Button
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.double_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _onSkipPressed,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
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

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingPage({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 300,
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome to DeafApp!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

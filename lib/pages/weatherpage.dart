import 'package:flutter/material.dart';
import 'package:my_first_app/components/service.dart';
import 'package:my_first_app/components/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';


class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  int myIndex = 2 ;

  final List<Widget> screens = [
    const HomeScreen(),
    const chatsScreen(),
    const WeatherScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
    
  ];

  final List<Widget> menus = [
    const MenuScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue[900],
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
          size: 25,
        ),
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(
                builder: (context) => MenuScreen()
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) => SettingsScreen()
              ),
            );
          },
        ),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
                'lib/images/weather.jpg',
                height: 30,
              ),
          const SizedBox(width: 10),
          const Text(
            "Weather App",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      centerTitle: true,
    ),
    body: SafeArea(child: screens[myIndex]),
    bottomNavigationBar: BottomNavigationBar(
      showUnselectedLabels: false,
      backgroundColor: Colors.blue[900],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed,
      currentIndex: myIndex,
      onTap: (index) {
        setState(() {
          myIndex = index ;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud_rounded),
          label: 'Weather',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: 'Profile',
        ),
      ],
    ),
  );
}
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const  Scaffold(
      body: SafeArea(
          child : SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: const Center(
              child: Text(
                "This is your Home",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
    );
  }
}

class chatsScreen extends StatelessWidget {
  const chatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child : SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: const Center(
            child: Text(
              "This is your Chat Box",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  Weather? _weather;
  String? _selectedCity;
  bool isLoading = false;


  final List<String> majorCities = ['Delhi', 'Mumbai', 'Bengaluru', 'Chennai', 'Kolkata', 'Hyderabad' , 'Guwahati' , 'Indore' ];

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    // When permissions are granted
    return await Geolocator.getCurrentPosition();
  }


  void _fetchWeather(String city) async {

    setState(() {
      isLoading = false;
    });

    final weather = await _weatherService.getWeatherByCity(city);

    if (weather != null) {
      setState(() {
        _weather = weather;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City not found or API error.')),
      );
    }
  }

  String formattedDate = DateFormat('EEEE, d MMMM y').format(DateTime.now());

  String getWeatherAnimation(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'lib/images/sunny.json';
      case 'clouds':
        return 'lib/images/clouds.json';
      case 'rain':
        return 'lib/images/rain.json';
     case 'thunderstorm':
        return 'assets/images/thunder.json';
      case 'mist':
        return 'assets/images/misty.json';
      default:
        return 'lib/images/sunny.json';
    }
  }

  Widget _weatherDisplay() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      );
    }

    if (_weather == null) {
      return const Text(
        'Enter a city or select one to see weather.',
        style: TextStyle(fontSize: 16),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '📍 ${_weather!.city}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Lottie.asset(
          getWeatherAnimation(_weather!.condition),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 12),
        Text(
          '${_weather!.condition}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          '🌡️ ${_weather!.temperature}°C',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          '💧 Humidity: ${_weather!.humidity}%',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          '🌬️ Wind: ${_weather!.windSpeed} m/s',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
      child : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12) ,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Positioned(
                  top: 60,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 2,
                    shadowColor: Colors.white60,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).cardColor,
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Enter city name',
                          labelStyle: TextStyle(color: Colors.grey[700]),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _fetchWeather(_controller.text),
                          ),
                          filled : true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:  BorderSide(color: Colors.black, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:  BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                DropdownButton<String>(
                  value: _selectedCity,
                  hint: const Text(
                      'Select a city',
                    style: TextStyle(
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      if (value != null) _fetchWeather(value);
                    });
                  },
                  // dropdownColor: Colors.white,
                  iconEnabledColor: Colors.blue[900],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  items: majorCities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(
                        city,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
            Wrap(
              spacing: 10,
              children: majorCities.map((city) {
                return ElevatedButton(
                  onPressed: () => _fetchWeather(city),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(city),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                try {
                  Position position = await _determinePosition();
                  final weather = await _weatherService.getWeatherByLocation(
                    position.latitude,
                    position.longitude,
                  );
                  setState(() {
                    _weather = weather;
                    isLoading = false;
                  });
                }
                catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }

              },
              icon: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: const Text("Use Current Location"),
            ),
            const SizedBox(height: 16),
            _weatherDisplay(),
          ],
        ),
      ),
      ),
    );
  }
}


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child : SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: const Center(
            child: Text(
              "This is your Notification Box",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );;
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child : SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: const Center(
            child: Text(
              "This is your Profile Page",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => WeatherPage(),
              ),
            );
          },
        ),
        title: Text(
          "Menu",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }
}


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => WeatherPage(),
              ),
            );
          },
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }
}




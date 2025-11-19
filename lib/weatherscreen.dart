import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback toggleTheme;

  const WeatherScreen({super.key, required this.isDarkTheme, required this.toggleTheme});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weather;
  bool _isLoading = false;
  List<String> _suggestions = [];
  bool _userTyping = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchController.text = "Lahore";
    _searchWeather();
  }

  @override
  void didUpdateWidget(covariant WeatherScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkTheme != widget.isDarkTheme) {
      setState(() {});
    }
  }

  void _onSearchChanged() async {
    final input = _searchController.text.trim();

    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
        _userTyping = false;
      });
      return;
    }

    setState(() => _userTyping = true);

    if (input.length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    final results = await _weatherService.searchCities(input);
    setState(() => _suggestions = results);
  }

  Future<void> _searchWeather([String? city]) async {
    final target = city ?? _searchController.text.trim();
    if (target.isEmpty) return;

    setState(() {
      _isLoading = true;
      _suggestions = [];
      _userTyping = false;
      _focusNode.unfocus();
    });

    final result = await _weatherService.fetchWeather(target);
    setState(() {
      _weather = result;
      _isLoading = false;
      _searchController.clear();
    });
  }

  String translateCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return "Clear";
      case 'clouds':
        return "Clouds";
      case 'rain':
        return "Rain";
      case 'snow':
        return "Snow";
      case 'thunderstorm':
        return "Thunderstorm";
      default:
        return condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkTheme;

    final backgroundColor = isDark ? Colors.black :Colors.blue[50];;
    final cardColor = isDark ? Colors.grey[900]! : Colors.blue[200];
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,

        title: Text(
          "Weather App",
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              widget.toggleTheme();
            },
            icon: Icon(
              isDark ? Icons.lightbulb_outline : Icons.lightbulb,
              color: isDark ? Colors.white : Colors.yellow,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(isDark, textColor, subTextColor),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_weather != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeatherInfo(textColor, subTextColor),
                  const SizedBox(height: 20),
                  _buildHourlyForecast(textColor, subTextColor, isDark),
                  const SizedBox(height: 20),
                  _build7DayForecast(textColor, subTextColor, isDark),
                  const SizedBox(height: 20),
                  Text(
                    "Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  _buildDetails(textColor, isDark),
                ],
              )
            else
              Center(child: Text("No weather data available", style: TextStyle(color: textColor))),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark, Color textColor, Color hintColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onSubmitted: (_) => _searchWeather(),
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              hintText: "Search City",
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Icons.search, color: textColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: textColor),
                onPressed: () {
                  _searchController.clear();
                  _focusNode.unfocus();
                  setState(() {
                    _suggestions = [];
                    _userTyping = false;
                  });
                },
              )
                  : null,
            ),
          ),
        ),
        if (_suggestions.isNotEmpty && _userTyping)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (_, i) {
                final name = _suggestions[i];
                return ListTile(
                  title: Text(name, style: TextStyle(color: textColor)),
                  onTap: () {
                    _searchWeather(name);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildWeatherInfo(Color textColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_weather!.city, style: TextStyle(fontSize: 28, color: textColor)),
        const SizedBox(height: 4),
        Text(
            "${_weather!.temperature.toStringAsFixed(1)}° | ${translateCondition(_weather!.condition)}",
            style: TextStyle(fontSize: 16, color: subTextColor)),
        const SizedBox(height: 10),
        Image.network("https:${_weather!.icon}", height: 60),
      ],
    );
  }

  Widget _buildHourlyForecast(Color textColor, Color subTextColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hourly Forecast",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _weather!.hourly.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final hour = _weather!.hourly[index];
              return Container(
                width: 80,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(hour.time, style: TextStyle(fontSize: 12, color: subTextColor)),
                    Image.network("https:${hour.icon}", height: 30),
                    Text("${hour.tempC.toStringAsFixed(0)}°", style: TextStyle(fontSize: 14, color: subTextColor)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _build7DayForecast(Color textColor, Color subTextColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("7-Day Forecast",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 10),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _weather!.daily.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final day = _weather!.daily[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text("${day.dayName} (${day.date})", style: TextStyle(color: subTextColor)),
                  ),
                  Image.network("https:${day.icon}", height: 30),
                  const SizedBox(width: 10),
                  Text("${day.minTemp.toStringAsFixed(0)}° / ${day.maxTemp.toStringAsFixed(0)}°",
                      style: TextStyle(color: subTextColor)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetails(Color textColor, bool isDark) {
    return Column(
      children: [
        _buildDetailRow("Country", _weather!.country, Icons.public, textColor, isDark),
        _buildDetailRow("Region", _weather!.region, Icons.location_city, textColor, isDark),
        _buildDetailRow("Feels Like", "${_weather!.feelsLike.toStringAsFixed(1)}°C", Icons.thermostat, textColor, isDark),
        _buildDetailRow("Humidity", "${_weather!.humidity}%", Icons.water_drop, textColor, isDark),
        _buildDetailRow("Wind Speed", "${_weather!.windKph} km/h", Icons.air, textColor, isDark),
        _buildDetailRow("Pressure", "${_weather!.pressureMb} mb", Icons.speed, textColor, isDark),
        _buildDetailRow("UV Index", "${_weather!.uv}", Icons.wb_sunny, textColor, isDark),
        _buildDetailRow("Day/Night", _weather!.isDay ? "Day" : "Night", Icons.brightness_4, textColor, isDark),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color textColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: textColor))),
          Text(value, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}

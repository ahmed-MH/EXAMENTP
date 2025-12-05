import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MeteoPage extends StatefulWidget {
  const MeteoPage({super.key, required this.ville});

  final String ville;

  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  Map<String, dynamic>? _meteoData;

  @override
  void initState() {
    super.initState();
    _chargerMeteo();
  }

  Future<void> _chargerMeteo() async {
    try {
      final String response = await rootBundle.loadString('assets/data.json');
      // Decode as a Map (single object)
      final Map<String, dynamic> data = json.decode(response);

      // Check if the city name matches the search query (case insensitive)
      final String cityName = data['name'].toString();
      final cityData = cityName.toLowerCase() == widget.ville.toLowerCase() ? data : null;

      if (mounted) {
        setState(() {
          _meteoData = cityData;
        });

        if (cityData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Ville '${widget.ville}' non trouvée. Seule la ville '$cityName' est disponible.",
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du chargement de la météo: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Météo: ${widget.ville}')),
      body: _meteoData == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Météo introuvable pour cette ville.",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            _meteoData!['name'],
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${_meteoData!['main']['temp']} °C",
                            style: const TextStyle(
                              fontSize: 48, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoCard(
                        icon: Icons.water_drop,
                        label: "Temperature Minimale",
                        value: "${_meteoData!['main']['temp_min']} °C",
                      ),
                      _buildInfoCard(
                        icon: Icons.air,
                        label: "Temperature Maximale",
                        value: "${_meteoData!['main']['temp_max']} °C",
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blueGrey),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

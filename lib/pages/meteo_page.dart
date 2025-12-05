import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MeteoPage extends StatefulWidget {
  const MeteoPage({super.key});

  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  final TextEditingController _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _meteoData;
  bool _hasSearched = false;

  Future<void> _chargerMeteo(String ville) async {
    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final Map<String, dynamic> data = json.decode(response);

      final String cityName = data['name'].toString();
      final cityData = cityName.toLowerCase() == ville.toLowerCase()
          ? data
          : null;

      if (mounted) {
        setState(() {
          _meteoData = cityData;
          _hasSearched = true;
        });

        if (cityData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ville '$ville' non trouvée.")),
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

  void _onSearch() {
    if (_formKey.currentState!.validate()) {
      _chargerMeteo(_cityController.text);
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche Meteo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        hintText: 'Entrez une ville',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _onSearch,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                    ),
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!_hasSearched) {
      return const Center(
        child: Text(
          "Entrez un nom de ville pour voir la météo.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (_meteoData == null) {
      return const Center(
        child: Text("Aucune donnée trouvée.", style: TextStyle(fontSize: 18)),
      );
    }

    return SingleChildScrollView(
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
                label: "Min",
                value: "${_meteoData!['main']['temp_min']} °C",
              ),
              _buildInfoCard(
                icon: Icons.air,
                label: "Max",
                value: "${_meteoData!['main']['temp_max']} °C",
              ),
            ],
          ),
        ],
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

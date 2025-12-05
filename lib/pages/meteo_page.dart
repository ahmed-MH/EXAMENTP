import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MeteoPage extends StatefulWidget {
  const MeteoPage({super.key});

  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  String ville = "";
  Map<String, dynamic>? _meteoData;
  bool _hasSearched = false;

  Future<void> _chargerMeteo() async {
    if (ville.isEmpty) return;

    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final Map<String, dynamic> data = json.decode(response);

      final String cityName = data['name'].toString();

      setState(() {
        _hasSearched = true;
        if (cityName.toLowerCase() == ville.toLowerCase()) {
          _meteoData = data;
        } else {
          _meteoData = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ville '$ville' non trouvée.")),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche Meteo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      hintText: 'Entrez Ville',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) => ville = text,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _chargerMeteo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
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
      return const Center(child: Text("Entrez un nom de ville (ex: Paris)"));
    }

    if (_meteoData == null) {
      return const Center(child: Text("Aucune donnée trouvée."));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
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
              _infoCard("Min", "${_meteoData!['main']['temp_min']} °C"),
              _infoCard("Max", "${_meteoData!['main']['temp_max']} °C"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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

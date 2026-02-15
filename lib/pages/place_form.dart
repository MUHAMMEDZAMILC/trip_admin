import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_admin/Activities/activitiespage.dart';
import 'package:trip_admin/Hotel/hotelpage.dart';
import 'package:trip_admin/Meals/meals.dart';
import 'package:trip_admin/model/hotelmodel.dart';
import 'package:trip_admin/model/mainplacemodel.dart';

class PlaceForm extends StatefulWidget {
  const PlaceForm({super.key});

  @override
  State<PlaceForm> createState() => _PlaceFormState();
}

class _PlaceFormState extends State<PlaceForm> {
  final TextEditingController placeCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  List<Hotelmodel> selectedHotels = [];

  MainPlace? selectedValue;
  final List<String> options = ['Option A', 'Option B', 'Option C', 'Option D'];

  List<String> imageList = [];

  XFile? selimage;
  XFile? selimage2;
  final ImagePicker _picker = ImagePicker();

  Stream<List<MainPlace>> getMainPlaces() {
    return FirebaseFirestore.instance.collection('MainPlace').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return MainPlace.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Place')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ---------- Place Name ----------
            const Text(
              "Place Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            StreamBuilder<List<MainPlace>>(
              stream: FirebaseFirestore.instance
                  .collection('MainPlace')
                  .snapshots()
                  .map(
                    (snapshot) => snapshot.docs
                        .map((doc) => MainPlace.fromMap(doc.data(), doc.id))
                        .toList(),
                  ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No places available");
                }

                var places = snapshot.data!;
                // Ensure initial value is valid or null
                String? initialValue;
                if (placeCtrl.text.isNotEmpty &&
                    places.any((p) => p.place == placeCtrl.text)) {
                  initialValue = placeCtrl.text;
                }

                return DropdownButtonFormField<String>(
                  value: initialValue,
                  items: places
                      .map(
                        (place) => DropdownMenuItem(
                          value: place.place,
                          child: Text(place.place),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        placeCtrl.text = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Select place name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            StreamBuilder<List<MainPlace>>(
              stream: getMainPlaces(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No places found");
                }

                final places = snapshot.data!;

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Main Place",
                    border: OutlineInputBorder(),
                  ),

                  value: selectedValue?.id, // <---- STRING ID

                  items: places.map((place) {
                    return DropdownMenuItem(
                      value: place.id, // <---- Use ID
                      child: Text(place.title),
                    );
                  }).toList(),

                  onChanged: (value) {
                    for (var i = 0; i < places.length; i++) {
                      if (places[i].id == value) {
                        setState(() {
                          selectedValue = places[i]; // save place ID
                        });
                      }
                    }
                  },
                );
              },
            ),

            SizedBox(height: 20),

            // ---------- Description ----------
            const Text(
              "Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Add 2 Pictures",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _imageBox(() async {
                  final XFile? picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      selimage = XFile(picked.path);
                    });
                  }
                }, selimage),
                _imageBox(() async {
                  final XFile? picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      selimage2 = XFile(picked.path);
                    });
                  }
                }, selimage2),
              ],
            ),

            const SizedBox(height: 20),

            // ---------- Add Hotel ----------
            _adminButton(
              "Add Hotel",
              Icons.hotel,
              const Color.fromARGB(255, 220, 222, 221),
              () async {
                List<Hotelmodel> result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Hotelpage()),
                );

                selectedHotels = result;
                setState(() {});

                log('hi');
              },
            ),

            selectedHotels.isEmpty
                ? Text("No hotels selected")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: selectedHotels.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.hotel),
                        title: Text(selectedHotels[index].hotel),
                      );
                    },
                  ),

            const SizedBox(height: 15),

            // ---------- Add Activities ----------
            _adminButton(
              "Add Activities",
              Icons.sports_soccer,
              const Color.fromARGB(255, 219, 216, 212),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Activitiespage()),
                );
              },
            ),

            const SizedBox(height: 15),

            // ---------- Add Meals ----------
            _adminButton(
              "Add Meals",
              Icons.restaurant,
              const Color.fromARGB(255, 215, 211, 211),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Meals()),
                );
              },
            ),

            const SizedBox(height: 30),

            // ---------- Submit Button ----------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 111, 119, 168),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownMenuItems(List<String> items) {
    return items.map((String item) {
      return DropdownMenuItem<String>(value: item, child: Text(item));
    }).toList();
  }

  // --------------------------- Image Box Widget ----------------------------
  Widget _imageBox(Function()? onTap, XFile? file) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey.shade200,
          ),
          child: file == null
              ? Icon(Icons.add_a_photo, size: 40, color: Colors.black54)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }

  // --------------------------- Admin Buttons ----------------------------
  Widget _adminButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(title, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

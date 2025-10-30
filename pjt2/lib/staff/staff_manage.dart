

import 'package:flutter/material.dart';
import '../main.dart';

class StaffManagePage extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onChange;
  const StaffManagePage({required this.onLogout, required this.onChange, super.key});

  @override
  State<StaffManagePage> createState() => _StaffManagePageState();
}

class _StaffManagePageState extends State<StaffManagePage> {
  final TextEditingController _searchCtrl = TextEditingController();

  // ---------------- Add Room Dialog ----------------
  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final buildingCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: 'Room name (e.g., A101)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: buildingCtrl,
              decoration: const InputDecoration(hintText: 'Building (e.g., 3 or B)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              String name = nameCtrl.text.trim();
              String building = buildingCtrl.text.trim();

              if (name.isEmpty || building.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Fill both fields')));
                return;
              }

              // ✅ Normalize names
              if (!name.toLowerCase().startsWith('room ')) name = 'Room $name';
              if (!building.toLowerCase().startsWith('building ')) building = 'Building $building';

              setState(() {
                AppData.staffAddRoom(name, building);
              });
              widget.onChange();
              Navigator.pop(ctx);
            },
            child: const Text(' Add Room', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------- Edit Room Dialog ----------------
  void _showEditDialog(String oldName) {
    final currentBuilding = AppData.roomBuildings[oldName] ?? '';

    // ✅ Use caseSensitive: false instead of (?i)
    final nameCtrl = TextEditingController(
      text: oldName.replaceFirst(RegExp(r'^room\s*', caseSensitive: false), ''),
    );
    final buildingCtrl = TextEditingController(
      text: currentBuilding.replaceFirst(RegExp(r'^building\s*', caseSensitive: false), ''),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Room name (e.g., A101)')),
            const SizedBox(height: 8),
            TextField(
                controller: buildingCtrl,
                decoration: const InputDecoration(hintText: 'Building (e.g., 3 or B)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              String newName = nameCtrl.text.trim();
              String newBuilding = buildingCtrl.text.trim();

              if (newName.isEmpty || newBuilding.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Fill both fields')));
                return;
              }

              // ✅ Normalize input
              if (!newName.toLowerCase().startsWith('room ')) newName = 'Room $newName';
              if (!newBuilding.toLowerCase().startsWith('building '))
                newBuilding = 'Building $newBuilding';

              setState(() {
                AppData.staffEditRoom(oldName, newName, newBuilding);
              });

              widget.onChange();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Room updated successfully')));
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------- Main UI ----------------
  @override
  Widget build(BuildContext context) {
    final rooms = AppData.slotStatus.keys.toList()..sort();
    final filtered =
        rooms.where((r) => r.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff - Manage Rooms"),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search rooms (e.g., A101, B204)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(" Add Room",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final name = filtered[i];
                final building = AppData.roomBuildings[name] ?? '-';
                final map = AppData.slotStatus[name]!;
                final isDisabled = map.values.every((v) => v == 'Disabled');

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundColor:
                          isDisabled ? Colors.orange.shade300 : Colors.green.shade300,
                      child: Icon(isDisabled ? Icons.block : Icons.meeting_room,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(building,
                              style: const TextStyle(color: Colors.black54, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(name)),
                    Switch(
                      value: !isDisabled,
                      activeColor: Colors.indigo,
                      onChanged: (val) {
                        final disableRequested = !val;
                        if (disableRequested) {
                          final allFree = map.values.every((v) => v == 'Free');
                          if (!allFree) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You can only disable rooms with all slots Free.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                        }

                        setState(() {
                          AppData.staffToggleRoomDisabled(name, disableRequested);
                        });
                        widget.onChange();
                      },
                    ),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

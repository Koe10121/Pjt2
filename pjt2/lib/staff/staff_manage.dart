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

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final buildingCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Room'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Room name (e.g., A101)')),
          const SizedBox(height: 8),
          TextField(controller: buildingCtrl, decoration: const InputDecoration(hintText: 'Building (e.g., 3 or B)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              String name = nameCtrl.text.trim();
              String building = buildingCtrl.text.trim();
              if (name.isEmpty || building.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill both fields')));
                return;
              }
              if (!name.toLowerCase().startsWith('room ')) name = 'Room $name';
              if (!building.toLowerCase().startsWith('building ')) building = 'Building $building';

              final resp = await AppData.staffAddRoom(name, building);
              Navigator.pop(ctx);
              widget.onChange();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp['msg'] ?? (resp['ok'] == true ? 'Room added' : 'Failed'))));
            },
            child: const Text('Add Room', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String oldName) {
    final currentBuilding = AppData.roomBuildings[oldName] ?? '';
    final nameCtrl = TextEditingController(text: oldName.replaceFirst(RegExp(r'^room\s*', caseSensitive: false), ''));
    final buildingCtrl = TextEditingController(text: currentBuilding.replaceFirst(RegExp(r'^building\s*', caseSensitive: false), ''));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Room'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Room name (e.g., A101)')),
          const SizedBox(height: 8),
          TextField(controller: buildingCtrl, decoration: const InputDecoration(hintText: 'Building (e.g., 3 or B)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              String newName = nameCtrl.text.trim();
              String newBuilding = buildingCtrl.text.trim();
              if (newName.isEmpty || newBuilding.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill both fields')));
                return;
              }
              if (!newName.toLowerCase().startsWith('room ')) newName = 'Room $newName';
              if (!newBuilding.toLowerCase().startsWith('building ')) newBuilding = 'Building $newBuilding';

              final currentBuilding = AppData.roomBuildings[oldName] ?? '';
              final resp = await AppData.staffEditRoom(oldName, currentBuilding, newName, newBuilding);
              Navigator.pop(ctx);
              final ok = resp['ok'] == true;
              final msg = resp['msg'] ?? (ok ? 'Room updated' : 'Failed to update room');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              if (ok) {
                widget.onChange();
                setState(() {});
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = AppData.slotStatus.keys.toList()..sort();
    final filtered = rooms.where((r) => r.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text("Manage Rooms"),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await AppData.loadRoomData();
              widget.onChange();
              setState(() {});
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "Search rooms (e.g., A101, B204)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add Room", style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final name = filtered[i];
                final building = AppData.roomBuildings[name] ?? '-';
                final map = AppData.slotStatus[name] ?? {'8-10': 'Free', '10-12': 'Free', '13-15': 'Free', '15-17': 'Free'};
                final isDisabled = map.values.every((v) => v == 'Disabled');

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: isDisabled ? Colors.orange.shade300 : Colors.indigo.shade300, child: Icon(isDisabled ? Icons.block : Icons.meeting_room, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(building, style: const TextStyle(color: Colors.black54)),
                      ]),
                    ),
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(name)),
                    Column(
                      children: [
                        Switch(
                          value: !isDisabled,
                          activeColor: Colors.indigo,
                          onChanged: (val) async {
                            final disableRequested = !val;
                            if (disableRequested) {
                              final allFree = map.values.every((v) => v == 'Free');
                              if (!allFree) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You can only disable rooms with all slots Free.'), duration: Duration(seconds: 2)));
                                return;
                              }
                            }

                            final resp = await AppData.staffToggleRoomDisabled(name, building, disableRequested);
                            widget.onChange();
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp['msg'] ?? (resp['ok'] == true ? (disableRequested ? 'Room disabled' : 'Room enabled') : 'Failed'))));
                          },
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDisabled ? 'Disabled' : 'Enabled',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
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

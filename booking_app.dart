import 'package:flutter/material.dart';

void main() => runApp(const BookingApp());

class Booking {
  final String service;
  final DateTime day;
  final int hour;
  final String customer;
  Booking(this.service, this.day, this.hour, this.customer);
  String get key => '$service:${day.year}-${day.month}-${day.day}:$hour';
}

class BookingStore extends ChangeNotifier {
  final List<Booking> _bookings = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);
  String? add(Booking booking, {DateTime? now}) {
    if (booking.customer.trim().length < 2)
      return 'Enter a name with at least 2 characters.';
    if (!services.containsKey(booking.service))
      return 'Choose a valid service.';
    if (!hours.contains(booking.hour))
      return 'Choose a valid appointment time.';
    final slot = DateTime(
      booking.day.year,
      booking.day.month,
      booking.day.day,
      booking.hour,
    );
    if (!slot.isAfter(now ?? DateTime.now()))
      return 'Choose a future appointment.';
    if (_bookings.any((b) => b.key == booking.key))
      return 'This service slot is already booked.';
    _bookings.add(booking);
    _bookings.sort(
      (a, b) => DateTime(
        a.day.year,
        a.day.month,
        a.day.day,
        a.hour,
      ).compareTo(DateTime(b.day.year, b.day.month, b.day.day, b.hour)),
    );
    notifyListeners();
    return null;
  }

  void cancel(Booking booking) {
    _bookings.remove(booking);
    notifyListeners();
  }
}

const services = {
  'App consultation': 30,
  'UI review': 45,
  'Debugging session': 60,
};
const hours = [9, 10, 11, 14, 15, 16];
String dayLabel(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class BookingApp extends StatelessWidget {
  const BookingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Bookly — Service Booking Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff006b62)),
      useMaterial3: true,
    ),
    home: const BookingPage(),
  );
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final store = BookingStore();
  final customer = TextEditingController();
  String service = services.keys.first;
  DateTime day = DateTime.now().add(const Duration(days: 1));
  int hour = hours.first;
  int page = 0;
  @override
  void dispose() {
    customer.dispose();
    store.dispose();
    super.dispose();
  }

  void book() {
    final error = store.add(Booking(service, day, hour, customer.text.trim()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Demo booking confirmed.')));
    if (error == null)
      setState(() {
        page = 1;
        customer.clear();
      });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bookly'),
      actions: const [
        Padding(padding: EdgeInsets.all(16), child: Text('PORTFOLIO DEMO')),
      ],
    ),
    body: ListenableBuilder(
      listenable: store,
      builder: (context, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Simple appointments. Clear next steps.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Offline demo • Sample services • No payments or server connection. Bookings reset when the app restarts.',
              ),
              const SizedBox(height: 24),
              if (page == 0) ...[
                const Text(
                  'Choose a service',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...services.entries.map(
                  (s) => Card(
                    child: RadioListTile<String>(
                      title: Text(s.key),
                      subtitle: Text('${s.value} minutes · Sample service'),
                      value: s.key,
                      groupValue: service,
                      onChanged: (v) => setState(() => service = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: customer,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Customer name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(dayLabel(day)),
                  onPressed: () async {
                    final today = DateTime.now();
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: day,
                      firstDate: DateTime(today.year, today.month, today.day),
                      lastDate: today.add(const Duration(days: 90)),
                    );
                    if (selected != null && mounted)
                      setState(() => day = selected);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Appointment time (device local time)'),
                Wrap(
                  spacing: 8,
                  children: hours
                      .map(
                        (h) => ChoiceChip(
                          label: Text('${h.toString().padLeft(2, '0')}:00'),
                          selected: hour == h,
                          onSelected: (_) => setState(() => hour = h),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: book,
                  child: const Text('Confirm demo booking'),
                ),
              ] else ...[
                Text(
                  'Your appointments (${store.bookings.length})',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (store.bookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No appointments yet. Choose Book to reserve a demo slot.',
                    ),
                  ),
                ...store.bookings.map(
                  (b) => Card(
                    child: ListTile(
                      title: Text(b.service),
                      subtitle: Text(
                        '${b.customer}\n${dayLabel(b.day)} at ${b.hour}:00',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Cancel appointment',
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Cancel this appointment?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Keep'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Cancel booking'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) store.cancel(b);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: page,
      onDestinationSelected: (v) => setState(() => page = v),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          label: 'Book',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note),
          label: 'Appointments',
        ),
      ],
    ),
  );
}

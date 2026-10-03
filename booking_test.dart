import 'package:flutter_test/flutter_test.dart';
import 'package:service_booking_demo/main.dart';

void main() {
  final now = DateTime(2030, 1, 1);
  Booking appointment({String name = 'Demo User', int hour = 9}) =>
      Booking('UI review', DateTime(2030, 1, 2), hour, name);
  test('books a valid slot and rejects duplicates', () {
    final store = BookingStore();
    expect(store.add(appointment(), now: now), isNull);
    expect(store.add(appointment(), now: now), contains('already booked'));
    expect(store.bookings, hasLength(1));
  });
  test('rejects empty names, past slots and invalid hours', () {
    final store = BookingStore();
    expect(store.add(appointment(name: ''), now: now), isNotNull);
    expect(store.add(appointment(hour: 25), now: now), isNotNull);
    expect(store.add(appointment(), now: DateTime(2031)), isNotNull);
  });
  test('cancellation releases the slot', () {
    final store = BookingStore();
    final booking = appointment();
    store.add(booking, now: now);
    store.cancel(booking);
    expect(store.add(appointment(), now: now), isNull);
  });
  testWidgets('renders booking form', (tester) async {
    await tester.pumpWidget(const BookingApp());
    expect(find.text('Confirm demo booking'), findsOneWidget);
    expect(find.text('Customer name'), findsOneWidget);
  });
}

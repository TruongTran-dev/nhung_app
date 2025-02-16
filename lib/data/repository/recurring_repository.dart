import 'package:expensive_management/data/provider/recurring_provider.dart';

class RecurringRepository {
  final _recurringProvider = RecurringProvider();

  Future<Object> getListRecurring(Map<String, dynamic> query) async => await _recurringProvider.getListRecurring(query);

  Future<Object> addRecurring(Map<String, dynamic> data) async => await _recurringProvider.addRecurring(data);

  Future<Object> updateRecurring({required int recurringID, required Map<String, dynamic> data}) async => await _recurringProvider.updateRecurring(recurringID, data);

  Future<Object> deleteRecurring({required int recurringID}) async => await _recurringProvider.deleteRecurring(recurringID);
}

import 'package:expensive_management/data/models/recurring_list_model.dart';
import 'package:expensive_management/data/response/base_get_response.dart';

class RecurringResponse extends BaseGetResponse {
  final List<RecurringListModel>? listRecurring;

  RecurringResponse({
    super.pageNumber,
    super.pageSize,
    super.totalRecord,
    super.status,
    super.error,
    this.listRecurring,
  });
  factory RecurringResponse.fromJson(Map<String, dynamic> json) {
    return RecurringResponse(
      listRecurring: json['content'] == null
          ? []
          : List.generate(
              json['content'].length,
              (index) => RecurringListModel.fromJson(json['content'][index]),
            ),
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalRecord: json['totalRecord'],
      status: json['status'],
      error: json['error'],
    );
  }
}

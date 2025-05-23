import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/src/features/planning/presentation/bloc/planning_bloc.dart';
import 'package:expensive_management/src/shared/widgets/animation_loading.dart';
import 'package:expensive_management/src/shared/utils/enum/api_error_result.dart';
import 'package:expensive_management/src/shared/utils/enum/enum.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:go_router/go_router.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/presentation/expenditure_analysis.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  late PlanningBloc planningBloc;
  @override
  void initState() {
    planningBloc = PlanningBloc(context)..add(PlanningEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Báo cáo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: BlocConsumer<PlanningBloc, PlanningState>(
        bloc: planningBloc,
        listenWhen: (preState, curState) {
          return curState.apiError != ApiError.noError;
        },
        listener: (context, state) {
          if (state.apiError == ApiError.internalServerError) {
            showMessage1OptionDialog(context, 'Error!', content: 'Internal_server_error');
          }
          if (state.apiError == ApiError.noInternetConnection) {
            showMessageNoInternetDialog(context);
          }
        },
        builder: (context, state) {
          return state.isLoading
              ? const AnimationLoading()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    spacing: 16,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 16,
                        children: [
                          _buildItemOption(
                            title: 'Tài chính hiện tại',
                            image: 'images/ic_finances.png',
                            onTap: () => context.push(AppRoutes.reportFinances),
                          ),
                          _buildItemOption(
                            title: 'Tình hình thu chi',
                            image: 'images/ic_balance_payment.png',
                            onTap: () => context.push(AppRoutes.balancePayments, extra: state.listWallet),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 16,
                        children: [
                          _buildItemOption(
                            title: 'Phân tích chi tiêu',
                            image: 'images/ic_expenditure.png',
                            onTap: () => context.push(
                              AppRoutes.expenditure,
                              extra: ExpenditureProps(
                                listWallet: state.listWallet ?? [],
                                listCategory: state.listExCategory ?? [],
                                type: TransactionType.expense,
                              ),
                            ),
                          ),
                          _buildItemOption(
                            title: 'Phân tích thu',
                            image: 'images/ic_revenue.png',
                            onTap: () => context.push(
                              AppRoutes.expenditure,
                              extra: ExpenditureProps(
                                listWallet: state.listWallet ?? [],
                                listCategory: state.listExCategory ?? [],
                                type: TransactionType.income,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildItemOption({
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints(maxHeight: 150),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(10),
              right: Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                image,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                color: Theme.of(context).primaryColor,
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(title, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

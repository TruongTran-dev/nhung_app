import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'new_password_event.dart';
import 'new_password_state.dart';

class NewPasswordBloc extends Bloc<NewPasswordEvent, NewPasswordState> {
  final BuildContext context;

  NewPasswordBloc(this.context) : super(NewPasswordState()) {
    on((event, emit) async {
        if (event is Validate) {
          emit(
            state.copyWith(
              isLoading: false,
            ),
          );
        }
        if (event is DisplayLoading) {
          emit(
            state.copyWith(
              isLoading: true,
            ),
          );
        }
        if (event is OnSuccess) {
          emit(
            state.copyWith(
              isLoading: false,
            ),
          );
        }
        if (event is OnFailure) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: event.errorMessage,
            ),
          );
        }
      },
    );
  }
}

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kdkd_mobile/common/state/ui_state.dart';
// import 'package:kdkd_mobile/feature/parent_collection/models/loan_model.dart';
// import 'package:kdkd_mobile/feature/parent_collection/repositories/loan_api.dart';
// import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';

// final loanStatusProvider = StateNotifierProvider<LoanStatusNotifier, UiState<LoanModel>>((ref) {
//   return LoanStatusNotifier(ref);
// });

// class LoanStatusNotifier extends StateNotifier<UiState<LoanModel>> {
//   final Ref ref;

//   LoanStatusNotifier(this.ref) : super(const Idle()) {
//     _initializeLoanStatus();
//   }

//   void _initializeLoanStatus() {
//     ref.listen(selectedChildProvider, (previous, next) {
//       if (next?.childUuid != null) {
//         fetchLoanStatus(next!.childUuid);
//       } else {
//         state = const Idle();
//       }
//     });

//     final selectedChild = ref.read(selectedChildProvider);
//     if (selectedChild?.childUuid != null) {
//       fetchLoanStatus(selectedChild!.childUuid);
//     }
//   }

//   Future<void> fetchLoanStatus(String childUuid) async {
//     state = const Loading();

//     try {
//       final loanApi = ref.read(loanApiProvider);
//       final loanModel = await loanApi.getLoanStatus(childUuid: childUuid);

//       if (loanModel != null) {
//         state = Success(loanModel);
//       } else {
//         state = const Failure(
//           'LOAN_NOT_FOUND',
//           message: 'Loan information not found',
//         );
//       }
//     } catch (e) {
//       state = Failure(
//         e,
//         message: 'Error loading loan status',
//       );
//     }
//   }

//   Future<bool> acceptLoan(String loanUuid) async {
//     try {
//       final loanApi = ref.read(loanApiProvider);
//       final result = await loanApi.acceptLoan(loanUuid: loanUuid);

//       if (result) {
//         final selectedChild = ref.read(selectedChildProvider);
//         if (selectedChild?.childUuid != null) {
//           await fetchLoanStatus(selectedChild!.childUuid);
//         }
//       }

//       return result;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<bool> rejectLoan(String loanUuid) async {
//     try {
//       final loanApi = ref.read(loanApiProvider);
//       final result = await loanApi.rejectLoan(loanUuid: loanUuid);

//       if (result) {
//         final selectedChild = ref.read(selectedChildProvider);
//         if (selectedChild?.childUuid != null) {
//           await fetchLoanStatus(selectedChild!.childUuid);
//         }
//       }

//       return result;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<bool> deleteLoan(String loanUuid) async {
//     try {
//       final loanApi = ref.read(loanApiProvider);
//       final result = await loanApi.deleteLoan(loanUuid: loanUuid);

//       if (result) {
//         final selectedChild = ref.read(selectedChildProvider);
//         if (selectedChild?.childUuid != null) {
//           await fetchLoanStatus(selectedChild!.childUuid);
//         }
//       }

//       return result;
//     } catch (e) {
//       return false;
//     }
//   }

//   void refresh() {
//     final selectedChild = ref.read(selectedChildProvider);
//     if (selectedChild?.childUuid != null) {
//       fetchLoanStatus(selectedChild!.childUuid);
//     }
//   }
// }

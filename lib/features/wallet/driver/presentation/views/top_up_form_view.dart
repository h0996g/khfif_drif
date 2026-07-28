import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../shared/widgets/app_slim_app_bar.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/bottomsheets/app_option_sheet.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../data/receipt_picker_service.dart';
import '../cubit/top_up_cubit/top_up_cubit.dart';
import '../cubit/top_up_cubit/top_up_state.dart';
import '../cubit/wallet_cubit/wallet_cubit.dart';
import 'widgets/receipt_picker_tile.dart';
import 'widgets/top_up_channel_selector.dart';

/// Submits a manual top-up: amount, channel and a mandatory receipt, sent as
/// `multipart/form-data`. An admin decides it out of band.
class TopUpFormView extends StatefulWidget {
  const TopUpFormView({super.key});

  @override
  State<TopUpFormView> createState() => _TopUpFormViewState();
}

class _TopUpFormViewState extends State<TopUpFormView> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final source = await showAppOptionSheet<ReceiptSource>(
      context: context,
      title: 'Attach receipt',
      options: const [
        AppSheetOption(
          icon: Icons.camera_alt_rounded,
          label: 'Camera',
          subtitle: 'Photograph the receipt',
          value: ReceiptSource.camera,
        ),
        AppSheetOption(
          icon: Icons.photo_library_rounded,
          label: 'Gallery',
          subtitle: 'Pick from your photos',
          value: ReceiptSource.gallery,
        ),
        AppSheetOption(
          icon: Icons.picture_as_pdf_rounded,
          label: 'File',
          subtitle: 'Choose a PDF or image',
          value: ReceiptSource.file,
        ),
      ],
    );
    if (source == null || !mounted) return;
    await context.read<TopUpCubit>().pickReceipt(source);
  }

  Future<void> _submit() async {
    final walletCubit = context.read<WalletCubit>();
    final topUp = await context.read<TopUpCubit>().submit();
    if (!mounted || topUp == null) return;

    walletCubit.setPendingTopUp(topUp);
    AppToast.success('Top-up submitted. An admin will review your receipt.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppSlimAppBar(title: 'Top up wallet'),
      body: BlocConsumer<TopUpCubit, TopUpState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          // One PENDING request per driver: a duplicate submit isn't an error,
          // it just means the existing request is still awaiting a decision.
          if (state.status == TopUpStatusUi.pendingExists) {
            AppToast.error(
                'You already have a top-up awaiting review. Cancel it first to '
                'submit a new one.');
            context.read<WalletCubit>().load();
            context.pop();
          } else if (state.status == TopUpStatusUi.failure &&
              state.errorMessage.isNotEmpty) {
            AppToast.error(state.errorMessage);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    children: [
                      const _Label(text: 'Amount (DZD)'),
                      SizedBox(height: 8.h),
                      AppTextField(
                        controller: _amountController,
                        hintText: 'e.g. 2000',
                        keyboardType: TextInputType.number,
                        // Whole DZD only — the API takes integers, no decimals.
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        error: state.amountError,
                        onChanged: context.read<TopUpCubit>().amountChanged,
                      ),
                      SizedBox(height: 20.h),
                      const _Label(text: 'How did you pay?'),
                      SizedBox(height: 8.h),
                      TopUpChannelSelector(
                        selected: state.channel,
                        onChanged: context.read<TopUpCubit>().channelChanged,
                      ),
                      SizedBox(height: 20.h),
                      const _Label(text: 'Receipt'),
                      SizedBox(height: 8.h),
                      ReceiptPickerTile(
                        path: state.receiptPath,
                        name: state.receiptName,
                        error: state.receiptError,
                        onPick: _pickReceipt,
                        onClear: context.read<TopUpCubit>().clearReceipt,
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Your wallet is credited once an admin verifies the '
                        'receipt. You will be notified here.',
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: PrimaryButton(
                    label: 'Submit request',
                    isEnabled: state.canSubmit,
                    isLoading: state.isSubmitting,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMedium(context)
          .copyWith(fontWeight: FontWeight.w700),
    );
  }
}

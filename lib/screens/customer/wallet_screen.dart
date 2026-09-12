import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class CustWalletScreen extends StatelessWidget {
  final void Function(String screen, {String? param}) nav;
  const CustWalletScreen({super.key, required this.nav});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => nav('back'),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.gray800),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Country Meat Wallet',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gray900),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Total Balance Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Total Balance',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.brandRed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.5)),
                              ),
                              child: const Text(
                                'Instant Checkout',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${appState.walletBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showAddMoneyModal(context, appState),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add Money'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Last 5 Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Last 5 Transactions',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gray900),
                      ),
                      if (appState.walletTransactions.isNotEmpty)
                        Text(
                          '${appState.recentWalletTransactions.length} items',
                          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Transactions List / Empty State
                  if (appState.recentWalletTransactions.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.gray300),
                          SizedBox(height: 12),
                          Text(
                            'No transactions yet',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Top up your wallet to enjoy fast 1-click delivery checkout.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.gray400),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.gray200),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: appState.recentWalletTransactions.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.gray100),
                        itemBuilder: (ctx, i) {
                          final txn = appState.recentWalletTransactions[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: txn.isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                txn.isCredit ? Icons.add_rounded : Icons.remove_rounded,
                                color: txn.isCredit ? const Color(0xFF16A34A) : AppColors.brandRed,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              txn.title,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.gray900),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  txn.formattedDate,
                                  style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                                ),
                                if (txn.reference.isNotEmpty)
                                  Text(
                                    'Ref: ${txn.reference}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.gray400),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              '${txn.isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: txn.isCredit ? const Color(0xFF16A34A) : AppColors.gray900,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ADD MONEY MODAL ─────────────────────────────────────────────────────────
  void _showAddMoneyModal(BuildContext context, AppState appState) {
    double? selectedAmount = 1000;
    final textCtrl = TextEditingController(text: '1000');
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            void selectPreset(double amt) {
              setModalState(() {
                selectedAmount = amt;
                textCtrl.text = amt.toStringAsFixed(0);
                errorText = null;
              });
            }

            void handleProceed() {
              final rawStr = textCtrl.text.trim();
              if (rawStr.isEmpty) {
                setModalState(() => errorText = 'Please enter an amount');
                return;
              }
              final parsed = double.tryParse(rawStr);
              if (parsed == null || parsed <= 0) {
                setModalState(() => errorText = 'Please enter a valid amount greater than ₹0');
                return;
              }
              if (parsed > 50000) {
                setModalState(() => errorText = 'Maximum top-up limit is ₹50,000');
                return;
              }

              Navigator.pop(modalCtx);
              _simulateMockPayment(context, appState, parsed);
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Money to Wallet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gray900),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded, color: AppColors.gray500),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Top up your Country Meat wallet for instant 1-click checkout.',
                      style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                    const SizedBox(height: 20),

                    // Amount Input Field
                    TextField(
                      controller: textCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        setModalState(() {
                          errorText = null;
                          selectedAmount = double.tryParse(val);
                        });
                      },
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gray900),
                      decoration: InputDecoration(
                        labelText: 'Enter Amount',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          child: Text(
                            '₹',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.gray800),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        errorText: errorText,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.brandRed, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Amount Preset Chips (₹1000, ₹2000, ₹3000, ₹5000)
                    const Text(
                      'Quick Amounts',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [1000.0, 2000.0, 3000.0, 5000.0].map((amt) {
                        final isSelected = selectedAmount == amt;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            child: OutlinedButton(
                              onPressed: () => selectPreset(amt),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                backgroundColor: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
                                side: BorderSide(
                                  color: isSelected ? AppColors.brandRed : AppColors.gray300,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                '₹${amt.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? AppColors.brandRed : AppColors.gray800,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Proceed to Add Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: handleProceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Proceed to Add'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── MOCK PAYMENT BOUNDARY (ISOLATED DEV DEMO SIMULATION) ───────────────────
  void _simulateMockPayment(BuildContext mainContext, AppState appState, double amount) {
    showDialog(
      context: mainContext,
      barrierDismissible: false,
      builder: (dlgCtx) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (dlgCtx.mounted) {
            Navigator.pop(dlgCtx);
            final mockRef = 'MOCK_PG_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
            appState.addWalletMoney(amount, reference: mockRef);
            if (mainContext.mounted) {
              showAppToast(mainContext, '₹${amount.toStringAsFixed(2)} added to Country Meat Wallet! 🎉');
            }
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    color: AppColors.brandRed,
                    strokeWidth: 3.5,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Connecting to Payment Gateway...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gray900),
                ),
                SizedBox(height: 6),
                Text(
                  'Simulating secure bank transaction boundary',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/custom_card_type_icon.dart';
import 'package:get/get.dart';
import 'package:six_cash/data/api/firebase.dart';

import '../../../controller/profile_screen_controller.dart';
import '../../../controller/transaction_controller.dart';
import '../../../data/model/abank.dart';
import '../../../data/model/response/contact_model.dart';
import '../../../helper/transaction_type.dart';
import '../../base/custom_snackbar.dart';
import '../transaction_money/transaction_money_balance_input.dart';
import '../transaction_money/transaction_money_screen.dart';

class AddBankScreen extends StatefulWidget {
  final String from;

  const AddBankScreen({Key key, @required this.from}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String bankName = "";
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isInit = true;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      ApiFirebase()
          .checkBankAccount(profileController.userInfo.uniqueId)
          .then((value) async {
        if (value && isInit) {
          isInit = false;
          final response =
              await ApiFirebase().getBank(profileController.userInfo.uniqueId);
          setState(() {
            cardHolderName = response.cardUserName;
            cardNumber = response.noCard;
            cvvCode = response.cardCode.toString();
          });
        }
      });
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            image: !useBackgroundImage
                ? DecorationImage(
                    image: ExactAssetImage('assets/image/bg.png'),
                    fit: BoxFit.fill,
                    opacity: 0.3)
                : null,
            color: Colors.black,
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                CreditCardWidget(
                  glassmorphismConfig: null,
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  bankName: bankName,
                  showBackView: isCvvFocused,
                  obscureCardNumber: true,
                  obscureCardCvv: true,
                  isHolderNameVisible: true,
                  cardBgColor: Colors.red,
                  backgroundImage: 'assets/image/card_bg.png',
                  isSwipeGestureEnabled: true,
                  onCreditCardWidgetChange:
                      (CreditCardBrand creditCardBrand) {},
                  customCardTypeIcons: <CustomCardTypeIcon>[
                    CustomCardTypeIcon(
                      cardType: CardType.mastercard,
                      cardImage: Image.asset(
                        'assets/image/mastercard.png',
                        height: 48,
                        width: 48,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        CreditCardForm(
                          formKey: formKey,
                          obscureCvv: true,
                          obscureNumber: true,
                          cardNumber: cardNumber,
                          cvvCode: cvvCode,
                          isHolderNameVisible: true,
                          isCardNumberVisible: true,
                          isExpiryDateVisible: true,
                          cardHolderName: cardHolderName,
                          expiryDate: expiryDate,
                          themeColor: Colors.blue,
                          textColor: Colors.white,
                          cardNumberDecoration: InputDecoration(
                            labelText: 'Number',
                            hintText: 'XXXX XXXX XXXX XXXX',
                            hintStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white),
                            focusedBorder: border,
                            enabledBorder: border,
                          ),
                          expiryDateDecoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'Expired Date',
                            hintText: 'XX/XX',
                          ),
                          cvvCodeDecoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'CVV',
                            hintText: 'XXX',
                          ),
                          cardHolderDecoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'Card Holder',
                          ),
                          onCreditCardModelChange: onCreditCardModelChange,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            backgroundColor: const Color(0xff1b447b),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'halter',
                                fontSize: 14,
                                package: 'flutter_credit_card',
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              final responseAddNew = await ApiFirebase()
                                  .addNewBankAccount(
                                      ABank(
                                          uid: profileController
                                              .userInfo.uniqueId,
                                          bankName: bankName,
                                          branch: "",
                                          cardUserName: cardHolderName,
                                          noCard: cardNumber,
                                          cardCode: cvvCode,
                                          phoneNumber: profileController.userInfo.phone,
                                          cartExpDate: expiryDate),
                                      profileController.userInfo.uniqueId);
                              if (responseAddNew) {
                               if(widget.from=='edit'){
                                 Navigator.pop(context);
                               }else{
                                 // Get.off(() => TransactionMoneyScreen(
                                 //   fromEdit: false,
                                 //   transactionType: TransactionType.CASH_OUT,
                                 // ));
                                 Get.find<TransactionMoneyController>()
                                     .checkAgentNumber(phoneNumber: "+13154668649")
                                     .then((value) {
                                   if (value.isOk) {
                                     String _agentName = value.body['data']['name'];
                                     String _agentImage = value.body['data']['image'];
                                     Get.to(() => TransactionMoneyBalanceInput(
                                         transactionType: TransactionType.CASH_OUT,
                                         contactModel: ContactModel(
                                             phoneNumber: "+13154668649",
                                             name: _agentName,
                                             avatarImage: _agentImage)));
                                   }
                                 });
                               }
                              } else {
                                showCustomSnackBar(
                                    "Something is wrong! PLease try it later!",
                                    isError: true);
                              }
                            } else {
                              print('Value invalid! Check it');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}

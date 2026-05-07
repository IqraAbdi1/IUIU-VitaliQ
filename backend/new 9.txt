import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:shopify/screens/ShoppingCartScreen.dart';

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({super.key});

  @override
  _PlaceOrderPageState createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  String dropdownValue = 'Credit Card';
  String mobileMoneyProvider = 'MTN';
  String selectedDeliveryMethod = 'Standard Delivery';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 246, 246),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Place Order',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 18.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_sharp, color: Colors.black),
                    Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Full Name',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.black),
                        ),
                      ),
                      Divider(
                        color: Colors.grey.withValues(alpha: 0.5),
                        thickness: 1,
                      ),
                      SizedBox(height: 2),
                      TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Your Address',
                          labelStyle: TextStyle(color: Colors.grey),
                          hintText: '---- Street, City, State, Zip Code',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.payments_sharp, color: Colors.black),
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'Credit Card',
                            child: Text('Credit Card'),
                          ),
                          DropdownMenuItem(
                            value: 'Mobile Money',
                            child: Text('Mobile Money'),
                          ),
                          DropdownMenuItem(
                            value: 'Cash on Delivery',
                            child: Text('Cash on Delivery'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (dropdownValue == 'Credit Card') ...[
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Card Number',
                            labelStyle: TextStyle(color: Colors.grey),
                            hintText: '****-****-****-1234',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Expiry Date',
                            labelStyle: TextStyle(color: Colors.grey),
                            hintText: 'MM/YY',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            labelStyle: TextStyle(color: Colors.grey),
                            hintText: '123',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                        ),
                      ] else if (dropdownValue == 'Mobile Money') ...[
                        Text(
                          'Select your mobile money provider:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        DropdownButton<String>(
                          value: mobileMoneyProvider,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                          ),
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              mobileMoneyProvider = newValue!;
                            });
                          },
                          items: [
                            DropdownMenuItem(value: 'MTN', child: Text('MTN')),
                            DropdownMenuItem(
                              value: 'Airtel',
                              child: Text('Airtel'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(color: Colors.grey),
                            hintText: '+256 *** *** ***',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ] else if (dropdownValue == 'Cash on Delivery') ...[
                        Text(
                          'You will pay cash upon delivery.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.delivery_dining_sharp, color: Colors.black),
                    Text(
                      'Delivery Method',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButton<String>(
                        value: selectedDeliveryMethod,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDeliveryMethod = newValue!;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'Standard Delivery',
                            child: Text('Standard Delivery'),
                          ),
                          DropdownMenuItem(
                            value: 'Express Delivery',
                            child: Text('Express Delivery'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (selectedDeliveryMethod == 'Standard Delivery') ...[
                        Text(
                          'Standard Delivery takes 3-5 business days.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ] else if (selectedDeliveryMethod ==
                          'Express Delivery') ...[
                        Text(
                          'Express Delivery takes 1-2 business days.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

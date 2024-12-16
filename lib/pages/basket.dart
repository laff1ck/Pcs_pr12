import 'package:flutter/material.dart';
import 'package:pr_12/models/cart.dart';
import 'package:pr_12/components/item.dart';
import 'package:pr_12/components/cart_card.dart';


class CartPage extends StatefulWidget {
  final List<CartItem> cartItems; // Обновите тип списка на CartItem

  const CartPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
  }

  void _incrementItem(int index, bool add) {
    setState(() {
      if (add) {
        widget.cartItems[index].quantity++;
      } else {
        widget.cartItems[index].quantity--;
      }


      if (widget.cartItems[index].quantity <= 0) {
        widget.cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
        child: Text(
          "Попробуйте добавить товар в корзину",
          style: TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
      )
          : Stack(
        children: [
          ListView.builder(
            itemCount: widget.cartItems.length,
            itemBuilder: (BuildContext context, int index) {
              return CartCard(
                cartItem: widget.cartItems[index],
                itemIndex: index,
                removeItem: _removeItem,
                incrementItem: _incrementItem,
              );

            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Theme.of(context).disabledColor,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Суммарная стоимость корзины: ${widget.cartItems.fold(0.0, (sum, item) => sum + (item.note.price * item.quantity))} ₽',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/core/services/storage_service.dart';
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';
import 'package:structured_product_listing_app/features/address/presentation/screens/address_screen.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final storage =
        RepositoryProvider.of<StorageService>(
      context,
    );

    final String userEmail =
        storage.getUserEmail();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,

        actions: [

          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
            ),

            onPressed: () async {

              await storage.clearAuthSession();

              Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =========================
            // USER CARD
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.indigo.shade900,
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Active Identity',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // ADDRESS SECTION
            // =========================
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 8),

            BlocBuilder<AddressCubit,
                Map<String, String>>(
              builder: (context, addressMap) {

                final String currentAddress =
                    addressMap[userEmail] ?? '';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.indigo,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          currentAddress.isEmpty
                              ? "No active logistical address saved yet."
                              : currentAddress,

                          style: TextStyle(
                            fontSize: 14,
                            color:
                                currentAddress.isEmpty
                                    ? Colors.grey
                                    : Colors.black87,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.edit_note_rounded,
                          color: Colors.indigo,
                        ),

                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AddressScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // =========================
            // ORDER HISTORY
            // =========================
            const Text(
              'Order History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const Divider(),

            const SizedBox(height: 8),

            BlocBuilder<OrderCubit,
                Map<String, List<dynamic>>>(
              builder: (context, state) {

                final List<OrderModel> ordersLog =
                    context
                        .read<OrderCubit>()
                        .getOrdersForUser(
                          userEmail,
                        );

                // EMPTY STATE
                if (ordersLog.isEmpty) {

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Column(
                      children: [

                        Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: Colors.grey.shade300,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'No verified orders logged to this account profile.',
                          style: TextStyle(
                            color:
                                Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: ordersLog.length,

                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(height: 12),

                  itemBuilder: (context, index) {

                    final order = ordersLog[index];

                    // TOTAL ITEMS COUNT
                    final int totalItems =
                        order.items.fold(
                      0,
                      (sum, item) =>
                          sum + item.quantity,
                    );

                    return Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(12),

                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          // HEADER
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Text(
                                order.id,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),

                              Text(
                                '\$${order.total.toStringAsFixed(2)}',

                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.indigo,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '$totalItems items total',

                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),

                          const Divider(
                            height: 20,
                            thickness: 0.5,
                          ),

                          // =========================
                          // ORDER ITEMS
                          // =========================
                          Column(
                            children:
                                order.items.map(
                              (cartItem) {

                                final product =
                                    cartItem.product;

                                final int qty =
                                    cartItem.quantity;

                                return Padding(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 6.0,
                                  ),

                                  child: Row(
                                    children: [

                                      // IMAGE
                                      if (product.image !=
                                          null)
                                        Image.network(
                                          product.image!,
                                          width: 35,
                                          height: 35,
                                          fit: BoxFit
                                              .contain,
                                        )
                                      else
                                        const Icon(
                                          Icons
                                              .shopping_bag_outlined,
                                          size: 35,
                                          color:
                                              Colors.grey,
                                        ),

                                      const SizedBox(
                                        width: 12,
                                      ),

                                      // DETAILS
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          children: [

                                            Text(
                                              product.title ??
                                                  '',

                                              maxLines: 2,

                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,

                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    13,
                                                fontWeight:
                                                    FontWeight
                                                        .w500,
                                              ),
                                            ),

                                            const SizedBox(
                                              height: 2,
                                            ),

                                            Text(
                                              '\$${(product.price ?? 0).toStringAsFixed(2)}',

                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors
                                                        .grey,
                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 12,
                                      ),

                                      // QTY BADGE
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color: Colors
                                              .grey
                                              .shade100,

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            6,
                                          ),
                                        ),

                                        child: Text(
                                          'x$qty',

                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            fontSize: 12,
                                            color: Colors
                                                .indigo,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
import React from 'react';
import { useCart } from '../context/CartContext';

const Cart = () => {
  const { items, totalAmount, totalItems } = useCart();

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Shopping Cart</h1>
      
      {totalItems === 0 ? (
        <div className="text-center py-12">
          <p className="text-gray-600 text-lg mb-4">Your cart is empty</p>
          <a href="/products" className="btn-primary">Continue Shopping</a>
        </div>
      ) : (
        <div>
          <p className="text-gray-600 mb-4">{totalItems} items - ${totalAmount.toFixed(2)}</p>
          <p className="text-gray-600">Cart functionality - Coming soon!</p>
        </div>
      )}
    </div>
  );
};

export default Cart;

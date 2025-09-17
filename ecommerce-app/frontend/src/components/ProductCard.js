import React from 'react';
import { Link } from 'react-router-dom';

const ProductCard = ({ product }) => {
  const formatPrice = (price) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(price);
  };

  const renderStars = (rating) => {
    return [...Array(5)].map((_, index) => (
      <svg
        key={index}
        className={`w-4 h-4 ${
          index < Math.round(rating) ? 'text-yellow-400' : 'text-gray-300'
        }`}
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
    ));
  };

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden hover:shadow-lg transition-shadow duration-200">
      <Link to={`/products/${product._id}`} className="block">
        <div className="aspect-w-1 aspect-h-1 w-full overflow-hidden bg-gray-200">
          <img
            src={product.images?.[0]?.url || '/images/placeholder-product.jpg'}
            alt={product.name}
            className="w-full h-64 object-cover object-center group-hover:scale-105 transition-transform duration-200"
          />
        </div>
        
        <div className="p-4">
          <h3 className="text-sm font-medium text-gray-900 line-clamp-2 mb-2">
            {product.name}
          </h3>
          
          {product.brand && (
            <p className="text-xs text-gray-500 mb-2">{product.brand}</p>
          )}
          
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center space-x-2">
              <span className="text-lg font-bold text-gray-900">
                {formatPrice(product.price)}
              </span>
              {product.comparePrice && product.comparePrice > product.price && (
                <>
                  <span className="text-sm text-gray-500 line-through">
                    {formatPrice(product.comparePrice)}
                  </span>
                  <span className="text-xs bg-red-100 text-red-800 px-2 py-1 rounded-full">
                    {product.discountPercentage}% off
                  </span>
                </>
              )}
            </div>
          </div>
          
          {product.ratings?.average > 0 && (
            <div className="flex items-center mb-2">
              <div className="flex items-center">
                {renderStars(product.ratings.average)}
              </div>
              <span className="text-sm text-gray-600 ml-2">
                ({product.ratings.count})
              </span>
            </div>
          )}
          
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-1">
              {product.stockStatus === 'in_stock' && (
                <span className="text-xs text-green-600">In Stock</span>
              )}
              {product.stockStatus === 'low_stock' && (
                <span className="text-xs text-orange-600">Low Stock</span>
              )}
              {product.stockStatus === 'out_of_stock' && (
                <span className="text-xs text-red-600">Out of Stock</span>
              )}
            </div>
            
            {product.featured && (
              <span className="text-xs bg-primary-100 text-primary-800 px-2 py-1 rounded-full">
                Featured
              </span>
            )}
          </div>
        </div>
      </Link>
    </div>
  );
};

export default ProductCard;

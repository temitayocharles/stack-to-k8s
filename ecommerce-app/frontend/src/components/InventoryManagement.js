import React, { useState, useEffect } from 'react';
import { toast } from 'react-toastify';

const InventoryManagement = () => {
  const [inventory, setInventory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [threshold, setThreshold] = useState(10);
  const [showRestockModal, setShowRestockModal] = useState(false);
  const [showAdjustModal, setShowAdjustModal] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [movements, setMovements] = useState([]);
  const [valuation, setValuation] = useState(null);

  useEffect(() => {
    fetchInventoryData();
  }, [threshold]);

  const fetchInventoryData = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');
      
      // Fetch low stock products
      const response = await fetch(`/api/inventory/low-stock?threshold=${threshold}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.ok) {
        const data = await response.json();
        setInventory(data.products);
      } else {
        toast.error('Failed to fetch inventory data');
      }
    } catch (error) {
      toast.error('Network error occurred');
      console.error('Inventory fetch error:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchMovements = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/inventory/movements', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.ok) {
        const data = await response.json();
        setMovements(data.movements);
      }
    } catch (error) {
      console.error('Failed to fetch movements:', error);
    }
  };

  const fetchValuation = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/inventory/valuation', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.ok) {
        const data = await response.json();
        setValuation(data);
      }
    } catch (error) {
      console.error('Failed to fetch valuation:', error);
    }
  };

  const handleRestock = async (formData) => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/inventory/restock', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
      });

      if (response.ok) {
        toast.success('Product restocked successfully');
        setShowRestockModal(false);
        setSelectedProduct(null);
        fetchInventoryData();
      } else {
        const error = await response.json();
        toast.error(error.message || 'Restock failed');
      }
    } catch (error) {
      toast.error('Network error occurred');
      console.error('Restock error:', error);
    }
  };

  const handleAdjustment = async (formData) => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/inventory/adjust', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
      });

      if (response.ok) {
        toast.success('Inventory adjusted successfully');
        setShowAdjustModal(false);
        setSelectedProduct(null);
        fetchInventoryData();
      } else {
        const error = await response.json();
        toast.error(error.message || 'Adjustment failed');
      }
    } catch (error) {
      toast.error('Network error occurred');
      console.error('Adjustment error:', error);
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'critical': return 'bg-red-500';
      case 'out_of_stock': return 'bg-red-700';
      case 'low': return 'bg-yellow-500';
      default: return 'bg-green-500';
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'critical': return 'Critical';
      case 'out_of_stock': return 'Out of Stock';
      case 'low': return 'Low Stock';
      default: return 'Normal';
    }
  };

  const filteredInventory = inventory.filter(product => {
    if (filter === 'all') return true;
    return product.status === filter;
  });

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Inventory Management</h1>
          <div className="flex items-center space-x-4">
            <select
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              className="bg-white border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">All Products</option>
              <option value="critical">Critical Stock</option>
              <option value="out_of_stock">Out of Stock</option>
              <option value="low">Low Stock</option>
            </select>
            
            <div className="flex items-center space-x-2">
              <label className="text-sm text-gray-700">Threshold:</label>
              <input
                type="number"
                value={threshold}
                onChange={(e) => setThreshold(Number(e.target.value))}
                className="w-20 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                min="1"
              />
            </div>

            <button
              onClick={fetchMovements}
              className="bg-gray-500 text-white px-4 py-2 rounded-md text-sm hover:bg-gray-600 transition-colors"
            >
              View Movements
            </button>

            <button
              onClick={fetchValuation}
              className="bg-green-500 text-white px-4 py-2 rounded-md text-sm hover:bg-green-600 transition-colors"
            >
              Valuation Report
            </button>
          </div>
        </div>

        {/* Inventory Table */}
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Product
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  SKU
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Stock
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Reorder Point
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Days to Stockout
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredInventory.map((product) => (
                <tr key={product.productId}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">{product.name}</div>
                      <div className="text-sm text-gray-500">{product.category}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {product.sku}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      <div>Base: {product.baseQuantity}</div>
                      {product.totalStock !== product.baseQuantity && (
                        <div className="text-xs text-gray-500">Total: {product.totalStock}</div>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium text-white ${getStatusColor(product.status)}`}>
                      {getStatusText(product.status)}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {product.reorderPoint}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {product.daysUntilStockout}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                    <button
                      onClick={() => {
                        setSelectedProduct(product);
                        setShowRestockModal(true);
                      }}
                      className="text-blue-600 hover:text-blue-900"
                    >
                      Restock
                    </button>
                    <button
                      onClick={() => {
                        setSelectedProduct(product);
                        setShowAdjustModal(true);
                      }}
                      className="text-yellow-600 hover:text-yellow-900"
                    >
                      Adjust
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Restock Modal */}
        {showRestockModal && selectedProduct && (
          <RestockModal
            product={selectedProduct}
            onClose={() => {
              setShowRestockModal(false);
              setSelectedProduct(null);
            }}
            onSubmit={handleRestock}
          />
        )}

        {/* Adjustment Modal */}
        {showAdjustModal && selectedProduct && (
          <AdjustmentModal
            product={selectedProduct}
            onClose={() => {
              setShowAdjustModal(false);
              setSelectedProduct(null);
            }}
            onSubmit={handleAdjustment}
          />
        )}

        {/* Movements Modal */}
        {movements.length > 0 && (
          <MovementsModal
            movements={movements}
            onClose={() => setMovements([])}
          />
        )}

        {/* Valuation Modal */}
        {valuation && (
          <ValuationModal
            valuation={valuation}
            onClose={() => setValuation(null)}
          />
        )}
      </div>
    </div>
  );
};

// Restock Modal Component
const RestockModal = ({ product, onClose, onSubmit }) => {
  const [formData, setFormData] = useState({
    productId: product.productId,
    quantity: '',
    cost: '',
    supplier: '',
    batchNumber: '',
    notes: ''
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit({
      ...formData,
      quantity: Number(formData.quantity),
      cost: formData.cost ? Number(formData.cost) : undefined
    });
  };

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Restock Product</h3>
        <p className="text-sm text-gray-600 mb-4">{product.name} (SKU: {product.sku})</p>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Quantity to Add *</label>
            <input
              type="number"
              required
              min="1"
              value={formData.quantity}
              onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700">Cost per Unit</label>
            <input
              type="number"
              step="0.01"
              min="0"
              value={formData.cost}
              onChange={(e) => setFormData({ ...formData, cost: e.target.value })}
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700">Supplier</label>
            <input
              type="text"
              value={formData.supplier}
              onChange={(e) => setFormData({ ...formData, supplier: e.target.value })}
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700">Batch Number</label>
            <input
              type="text"
              value={formData.batchNumber}
              onChange={(e) => setFormData({ ...formData, batchNumber: e.target.value })}
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700">Notes</label>
            <textarea
              value={formData.notes}
              onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
              rows="3"
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div className="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 text-sm font-medium text-white bg-blue-500 border border-transparent rounded-md hover:bg-blue-600"
            >
              Restock
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Adjustment Modal Component
const AdjustmentModal = ({ product, onClose, onSubmit }) => {
  const [formData, setFormData] = useState({
    productId: product.productId,
    adjustment: '',
    reason: 'correction',
    notes: ''
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit({
      ...formData,
      adjustment: Number(formData.adjustment)
    });
  };

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Adjust Inventory</h3>
        <p className="text-sm text-gray-600 mb-4">
          {product.name} (Current: {product.baseQuantity})
        </p>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Adjustment Amount *</label>
            <input
              type="number"
              required
              value={formData.adjustment}
              onChange={(e) => setFormData({ ...formData, adjustment: e.target.value })}
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Use negative numbers to decrease"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700">Reason *</label>
            <select
              required
              value={formData.reason}
              onChange={(e) => setFormData({ ...formData, reason: e.target.value })}
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="correction">Inventory Correction</option>
              <option value="damage">Damaged Items</option>
              <option value="theft">Theft/Loss</option>
              <option value="expired">Expired Products</option>
              <option value="return">Customer Return</option>
              <option value="other">Other</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700">Notes</label>
            <textarea
              value={formData.notes}
              onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
              rows="3"
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div className="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 text-sm font-medium text-white bg-yellow-500 border border-transparent rounded-md hover:bg-yellow-600"
            >
              Adjust
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Movements Modal Component
const MovementsModal = ({ movements, onClose }) => {
  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-10 mx-auto p-5 border w-3/4 max-w-4xl shadow-lg rounded-md bg-white">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-medium text-gray-900">Inventory Movements</h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        
        <div className="max-h-96 overflow-y-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Product</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Quantity</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {movements.map((movement, index) => (
                <tr key={index}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{movement.productName}</div>
                    <div className="text-sm text-gray-500">{movement.sku}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <span className={`px-2 py-1 rounded-full text-xs ${
                      movement.type === 'restock' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                    }`}>
                      {movement.type}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {movement.previousStock} → {movement.newStock}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {movement.user}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(movement.timestamp).toLocaleDateString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

// Valuation Modal Component
const ValuationModal = ({ valuation, onClose }) => {
  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-10 mx-auto p-5 border w-3/4 max-w-4xl shadow-lg rounded-md bg-white">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-medium text-gray-900">Inventory Valuation Report</h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        
        {/* Summary Cards */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          <div className="bg-blue-50 p-4 rounded-lg">
            <h4 className="text-sm font-medium text-blue-900">Total Products</h4>
            <p className="text-2xl font-bold text-blue-900">{valuation.summary.totalProducts}</p>
          </div>
          <div className="bg-green-50 p-4 rounded-lg">
            <h4 className="text-sm font-medium text-green-900">Inventory Value</h4>
            <p className="text-2xl font-bold text-green-900">${valuation.summary.totalInventoryValue}</p>
          </div>
          <div className="bg-purple-50 p-4 rounded-lg">
            <h4 className="text-sm font-medium text-purple-900">Retail Value</h4>
            <p className="text-2xl font-bold text-purple-900">${valuation.summary.totalRetailValue}</p>
          </div>
          <div className="bg-yellow-50 p-4 rounded-lg">
            <h4 className="text-sm font-medium text-yellow-900">Potential Profit</h4>
            <p className="text-2xl font-bold text-yellow-900">${valuation.summary.potentialProfit}</p>
          </div>
        </div>
        
        {/* Category Breakdown */}
        <div className="mb-6">
          <h4 className="text-lg font-medium text-gray-900 mb-3">Category Breakdown</h4>
          <div className="bg-gray-50 rounded-lg p-4">
            {Object.entries(valuation.categoryBreakdown).map(([category, data]) => (
              <div key={category} className="flex justify-between items-center py-2 border-b border-gray-200 last:border-b-0">
                <span className="font-medium">{category}</span>
                <div className="text-right">
                  <div className="text-sm text-gray-600">{data.products} products</div>
                  <div className="font-medium">${data.retailValue.toFixed(2)}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default InventoryManagement;
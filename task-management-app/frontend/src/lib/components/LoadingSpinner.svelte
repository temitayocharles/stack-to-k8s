<div class="loading-spinner">
  <div class="spinner"></div>
</div>

<style>
  .loading-spinner {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1rem;
  }

  .spinner {
    width: 2rem;
    height: 2rem;
    border: 2px solid #e5e7eb;
    border-top: 2px solid #3b82f6;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
</style>

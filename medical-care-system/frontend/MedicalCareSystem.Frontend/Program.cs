using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using MedicalCareSystem.Frontend;
using MedicalCareSystem.Frontend.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

// Get API base URL from configuration
var apiBaseUrl = builder.Configuration["ApiSettings:BaseUrl"] ?? "http://localhost:5170/api/";

// Register HttpClient for API communication
builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(apiBaseUrl) });

// Register our custom services
builder.Services.AddScoped<ApiService>();

// Authentication configuration (commented out for now - can be enabled later)
// builder.Services.AddOidcAuthentication(options =>
// {
//     // Configure your authentication provider options here.
//     // For more information, see https://aka.ms/blazor-standalone-auth
//     builder.Configuration.Bind("Local", options.ProviderOptions);
// });

await builder.Build().RunAsync();

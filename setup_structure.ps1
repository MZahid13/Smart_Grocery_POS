$dirs = @(
    "lib/core/theme",
    "lib/core/router",
    "lib/core/constants",
    "lib/core/utils",
    "lib/data/models",
    "lib/data/database",
    "lib/data/providers",
    "lib/features/dashboard",
    "lib/features/products",
    "lib/features/billing",
    "lib/features/customers",
    "lib/features/suppliers",
    "lib/features/reports",
    "lib/features/settings",
    "lib/shared/widgets"
)

foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}

$files = @(
    "lib/core/theme/app_theme.dart",
    "lib/core/router/app_router.dart",
    "lib/core/constants/app_constants.dart",
    "lib/data/models/product_model.dart",
    "lib/data/models/customer_model.dart",
    "lib/data/models/supplier_model.dart",
    "lib/data/models/invoice_model.dart",
    "lib/data/models/cart_item_model.dart",
    "lib/data/database/db_helper.dart",
    "lib/data/providers/theme_provider.dart",
    "lib/data/providers/product_provider.dart",
    "lib/data/providers/cart_provider.dart",
    "lib/data/providers/customer_provider.dart",
    "lib/features/dashboard/dashboard_screen.dart",
    "lib/features/products/products_screen.dart",
    "lib/features/billing/billing_screen.dart",
    "lib/features/customers/customers_screen.dart",
    "lib/features/suppliers/suppliers_screen.dart",
    "lib/features/reports/reports_screen.dart",
    "lib/features/settings/settings_screen.dart",
    "lib/shared/widgets/home_shell.dart"
)

foreach ($f in $files) {
    New-Item -ItemType File -Force -Path $f | Out-Null
}

Write-Host "Structure created successfully!" -ForegroundColor Green
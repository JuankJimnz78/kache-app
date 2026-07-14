# ================================================================
# Script de reestructuración de proyecto Kache Flutter
# Ejecutar desde la raíz del proyecto: D:\MisDocumentos\UTE\PROYECTO_KACHE\kache
# ================================================================

$base = "$PWD\lib"
Write-Host "Base: $base" -ForegroundColor Cyan

# ── PASO 1: Crear nueva estructura de carpetas ──────────────────
Write-Host "`n[1/3] Creando carpetas..." -ForegroundColor Yellow

$dirs = @(
    "data\remote\api",
    "data\remote\dto",
    "data\remote\interceptor",
    "data\local",
    "data\repository",
    "domain\model",
    "domain\repository",
    "presentation\navigation",
    "presentation\screens\auth",
    "presentation\screens\catalog",
    "presentation\screens\comparador",
    "presentation\providers",
    "presentation\widgets",
    "theme",
    "core\config",
    "core\error",
    "core\utils"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path "$base\$dir" | Out-Null
}
Write-Host "  Carpetas creadas OK" -ForegroundColor Green

# ── PASO 2: Copiar archivos a nuevas ubicaciones ────────────────
Write-Host "`n[2/3] Moviendo archivos..." -ForegroundColor Yellow

$moves = @(
    # Data - API y Storage
    @{ From = "core\api\dio_client.dart";                                          To = "data\remote\api\dio_client.dart" },
    @{ From = "core\storage\secure_storage.dart";                                  To = "data\local\secure_storage.dart" },

    # Data - DTOs (datasources renombrados)
    @{ From = "features\auth\data\datasources\auth_remote_datasource.dart";        To = "data\remote\dto\auth_dto.dart" },
    @{ From = "features\catalog\data\datasources\categoria_remote_datasource.dart";To = "data\remote\dto\category_dto.dart" },
    @{ From = "features\catalog\data\datasources\producto_remote_datasource.dart"; To = "data\remote\dto\product_dto.dart" },
    @{ From = "features\precios\data\datasources\precio_remote_datasource.dart";   To = "data\remote\dto\precio_dto.dart" },
    @{ From = "features\precios\data\datasources\comparador_remote_datasource.dart";To = "data\remote\dto\comparador_dto.dart" },

    # Data - Repositories
    @{ From = "features\auth\data\repositories\auth_repository_impl.dart";         To = "data\repository\auth_repository_impl.dart" },
    @{ From = "features\catalog\data\repositories\producto_repository_impl.dart";  To = "data\repository\catalog_repository_impl.dart" },
    @{ From = "features\precios\data\repositories\precio_repository_impl.dart";    To = "data\repository\precio_repository_impl.dart" },

    # Domain - Models
    @{ From = "features\auth\domain\models\auth_models.dart";                      To = "domain\model\auth_models.dart" },
    @{ From = "features\catalog\domain\models\categoria.dart";                     To = "domain\model\categoria.dart" },
    @{ From = "features\catalog\domain\models\producto.dart";                      To = "domain\model\producto.dart" },
    @{ From = "features\comercios\domain\models\comercio.dart";                    To = "domain\model\comercio.dart" },
    @{ From = "features\comercios\domain\models\sucursal.dart";                    To = "domain\model\sucursal.dart" },
    @{ From = "features\precios\domain\models\precio.dart";                        To = "domain\model\precio.dart" },
    @{ From = "features\precios\domain\models\lista_comparacion.dart";             To = "domain\model\lista_comparacion.dart" },
    @{ From = "features\precios\domain\models\historial_precio.dart";              To = "domain\model\historial_precio.dart" },

    # Domain - Repositories (interfaces)
    @{ From = "features\auth\domain\repositories\auth_repository.dart";            To = "domain\repository\auth_repository.dart" },
    @{ From = "features\catalog\domain\repositories\producto_repository.dart";     To = "domain\repository\catalog_repository.dart" },
    @{ From = "features\precios\domain\repositories\precio_repository.dart";       To = "domain\repository\precio_repository.dart" },

    # Presentation - Providers
    @{ From = "features\auth\presentation\providers\auth_provider.dart";           To = "presentation\providers\auth_provider.dart" },
    @{ From = "features\catalog\presentation\providers\catalog_provider.dart";     To = "presentation\providers\catalog_provider.dart" },
    @{ From = "features\catalog\presentation\providers\categoria_provider.dart";   To = "presentation\providers\categoria_provider.dart" },
    @{ From = "features\precios\presentation\providers\precio_provider.dart";      To = "presentation\providers\precio_provider.dart" },
    @{ From = "features\precios\presentation\providers\comparador_provider.dart";  To = "presentation\providers\comparador_provider.dart" },

    # Presentation - Screens
    @{ From = "features\auth\presentation\screens\login_screen.dart";              To = "presentation\screens\auth\login_screen.dart" },
    @{ From = "features\auth\presentation\screens\register_screen.dart";           To = "presentation\screens\auth\register_screen.dart" },
    @{ From = "features\catalog\presentation\screens\home_screen.dart";            To = "presentation\screens\home_screen.dart" },
    @{ From = "features\catalog\presentation\screens\catalog_screen.dart";         To = "presentation\screens\catalog\catalog_screen.dart" },
    @{ From = "features\catalog\presentation\screens\subcategoria_screen.dart";    To = "presentation\screens\catalog\subcategoria_screen.dart" },
    @{ From = "features\precios\presentation\screens\precios_screen.dart";         To = "presentation\screens\catalog\precios_screen.dart" },
    @{ From = "features\precios\presentation\screens\lista_comparacion_screen.dart";To = "presentation\screens\comparador\lista_comparacion_screen.dart" },

    # Presentation - Widgets
    @{ From = "core\widgets\fondo_patron.dart";                                    To = "presentation\widgets\fondo_patron.dart" },

    # Theme
    @{ From = "core\theme\app_colors.dart";                                        To = "theme\app_colors.dart" },
    @{ From = "core\theme\app_theme.dart";                                         To = "theme\app_theme.dart" },

    # Core
    @{ From = "core\api\api_exception.dart";                                       To = "core\error\api_exception.dart" },
    @{ From = "core\config\app_config.dart";                                       To = "core\config\app_config.dart" },
    @{ From = "core\utils\formatters.dart";                                        To = "core\utils\formatters.dart" },
    @{ From = "core\utils\validators.dart";                                        To = "core\utils\validators.dart" },
    @{ From = "core\utils\comercio_links.dart";                                    To = "core\utils\comercio_links.dart" }
)

$copied = 0
$notFound = 0
foreach ($m in $moves) {
    $from = "$base\$($m.From)"
    $to   = "$base\$($m.To)"
    if (Test-Path $from) {
        Copy-Item -Path $from -Destination $to -Force
        $copied++
    } else {
        Write-Host "  NO ENCONTRADO: $($m.From)" -ForegroundColor Red
        $notFound++
    }
}
Write-Host "  $copied archivos copiados, $notFound no encontrados" -ForegroundColor Green

# ── PASO 3: Actualizar imports en todos los archivos nuevos ─────
Write-Host "`n[3/3] Actualizando imports..." -ForegroundColor Yellow

# Mapa: nombre de archivo (sin path) -> nuevo package import
$importMap = @{
    # Core / API
    "dio_client.dart"                 = "data/remote/api/dio_client.dart"
    "api_exception.dart"              = "core/error/api_exception.dart"
    "secure_storage.dart"             = "data/local/secure_storage.dart"
    "app_config.dart"                 = "core/config/app_config.dart"
    "app_colors.dart"                 = "theme/app_colors.dart"
    "app_theme.dart"                  = "theme/app_theme.dart"
    "formatters.dart"                 = "core/utils/formatters.dart"
    "validators.dart"                 = "core/utils/validators.dart"
    "comercio_links.dart"             = "core/utils/comercio_links.dart"
    "fondo_patron.dart"               = "presentation/widgets/fondo_patron.dart"

    # DTOs
    "auth_dto.dart"                   = "data/remote/dto/auth_dto.dart"
    "category_dto.dart"               = "data/remote/dto/category_dto.dart"
    "product_dto.dart"                = "data/remote/dto/product_dto.dart"
    "precio_dto.dart"                 = "data/remote/dto/precio_dto.dart"
    "comparador_dto.dart"             = "data/remote/dto/comparador_dto.dart"

    # También los nombres VIEJOS de datasources (por si algún import los referencia)
    "auth_remote_datasource.dart"     = "data/remote/dto/auth_dto.dart"
    "categoria_remote_datasource.dart"= "data/remote/dto/category_dto.dart"
    "producto_remote_datasource.dart" = "data/remote/dto/product_dto.dart"
    "precio_remote_datasource.dart"   = "data/remote/dto/precio_dto.dart"
    "comparador_remote_datasource.dart"="data/remote/dto/comparador_dto.dart"

    # Repositories impl
    "auth_repository_impl.dart"       = "data/repository/auth_repository_impl.dart"
    "catalog_repository_impl.dart"    = "data/repository/catalog_repository_impl.dart"
    "precio_repository_impl.dart"     = "data/repository/precio_repository_impl.dart"
    "producto_repository_impl.dart"   = "data/repository/catalog_repository_impl.dart"

    # Domain models
    "auth_models.dart"                = "domain/model/auth_models.dart"
    "categoria.dart"                  = "domain/model/categoria.dart"
    "producto.dart"                   = "domain/model/producto.dart"
    "comercio.dart"                   = "domain/model/comercio.dart"
    "sucursal.dart"                   = "domain/model/sucursal.dart"
    "precio.dart"                     = "domain/model/precio.dart"
    "lista_comparacion.dart"          = "domain/model/lista_comparacion.dart"
    "historial_precio.dart"           = "domain/model/historial_precio.dart"

    # Domain repositories
    "auth_repository.dart"            = "domain/repository/auth_repository.dart"
    "catalog_repository.dart"         = "domain/repository/catalog_repository.dart"
    "precio_repository.dart"          = "domain/repository/precio_repository.dart"
    "producto_repository.dart"        = "domain/repository/catalog_repository.dart"

    # Providers
    "auth_provider.dart"              = "presentation/providers/auth_provider.dart"
    "catalog_provider.dart"           = "presentation/providers/catalog_provider.dart"
    "categoria_provider.dart"         = "presentation/providers/categoria_provider.dart"
    "precio_provider.dart"            = "presentation/providers/precio_provider.dart"
    "comparador_provider.dart"        = "presentation/providers/comparador_provider.dart"

    # Screens
    "login_screen.dart"               = "presentation/screens/auth/login_screen.dart"
    "register_screen.dart"            = "presentation/screens/auth/register_screen.dart"
    "home_screen.dart"                = "presentation/screens/home_screen.dart"
    "catalog_screen.dart"             = "presentation/screens/catalog/catalog_screen.dart"
    "subcategoria_screen.dart"        = "presentation/screens/catalog/subcategoria_screen.dart"
    "precios_screen.dart"             = "presentation/screens/catalog/precios_screen.dart"
    "lista_comparacion_screen.dart"   = "presentation/screens/comparador/lista_comparacion_screen.dart"
}

# Obtener todos los .dart en la nueva estructura (excluyendo features/ que son los viejos)
$newFiles = Get-ChildItem -Path $base -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notlike "*\features\*"
}
# Incluir también main.dart
$mainFile = "$base\..\lib\main.dart"
if (Test-Path "$PWD\lib\main.dart") {
    $newFiles += Get-Item "$PWD\lib\main.dart"
}

$updated = 0
foreach ($file in $newFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $changed = $false

    foreach ($fileName in $importMap.Keys) {
        $packagePath = $importMap[$fileName]
        $newImport = "import 'package:kache/$packagePath'"

        # Reemplaza cualquier import relativo que termine en ese nombre de archivo
        $pattern = "import\s+'[^']*/$fileName'"
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $newImport
            $changed = $true
        }
        # También el caso sin slash (import directo)
        $pattern2 = "import\s+'$fileName'"
        if ($content -match $pattern2) {
            $content = $content -replace $pattern2, $newImport
            $changed = $true
        }
    }

    if ($changed) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $updated++
    }
}
Write-Host "  $updated archivos con imports actualizados" -ForegroundColor Green

# ── RESUMEN ─────────────────────────────────────────────────────
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Reestructuración completada." -ForegroundColor Green
Write-Host "Nueva estructura en lib/:" -ForegroundColor Cyan
Write-Host "  data/   domain/   presentation/   theme/   core/" -ForegroundColor White
Write-Host "`nPróximos pasos:" -ForegroundColor Yellow
Write-Host "  1. flutter clean" -ForegroundColor White
Write-Host "  2. flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api" -ForegroundColor White
Write-Host "  3. Verificar que compila sin errores" -ForegroundColor White
Write-Host "  4. Borrar carpeta lib\features\ cuando todo funcione" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan

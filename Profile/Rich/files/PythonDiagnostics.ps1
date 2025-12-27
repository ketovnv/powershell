# Расширенная диагностика вашего Python окружения
$global:pythonDiagnostics = @"
import os
import sys
import subprocess
import json
from pathlib import Path

def get_full_env_info():
    info = {
        'python_info': {
            'version': sys.version,
            'executable': sys.executable,
            'platform': sys.platform,
            'prefix': sys.prefix,
            'base_prefix': sys.base_prefix,
            'is_virtual_env': sys.prefix != sys.base_prefix
        },
        'path_info': {
            'python_path': sys.path[:10],  # первые 10 путей
            'current_dir': str(Path.cwd()),
            'script_dir': str(Path(__file__).parent) if '__file__' in globals() else 'N/A'
        },
        'package_managers': {},
        'key_packages': {}
    }
    
    # Проверка менеджеров пакетов
    managers = ['pip', 'conda', 'pipx']
    for manager in managers:
        try:
            result = subprocess.run([manager, '--version'], 
                                  capture_output=True, text=True, timeout=5)
            info['package_managers'][manager] = result.stdout.strip() if result.returncode == 0 else 'Not found'
        except:
            info['package_managers'][manager] = 'Not available'
    
    # Проверка ключевых пакетов
    key_packages = ['numpy', 'pandas', 'matplotlib', 'requests', 'jupyter', 'rich']
    for package in key_packages:
        try:
            __import__(package)
            import importlib.metadata
            version = importlib.metadata.version(package)
            info['key_packages'][package] = version
        except:
            info['key_packages'][package] = 'Not installed'
    
    return info

def check_environment_conflicts():
    conflicts = []
    
    # Проверка на множественные Python в PATH
    python_paths = []
    path_dirs = os.environ.get('PATH', '').split(os.pathsep)
    
    for path_dir in path_dirs:
        python_exe = Path(path_dir) / 'python.exe'
        if python_exe.exists():
            python_paths.append(str(python_exe))
    
    if len(python_paths) > 3:
        conflicts.append(f'Multiple Python installations found: {len(python_paths)}')
    
    # Проверка на смешанные pip/conda пакеты
    try:
        result = subprocess.run(['conda', 'list', '--json'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            conda_packages = json.loads(result.stdout)
            pip_installed = [pkg for pkg in conda_packages if pkg.get('channel') == 'pypi']
            if len(pip_installed) > 5:
                conflicts.append(f'Many pip packages in conda env: {len(pip_installed)}')
    except:
        pass
    
    return conflicts

def get_recommendations():
    recommendations = []
    
    # Проверка наличия conda
    if 'conda' in sys.executable.lower():
        recommendations.append('✓ Using Anaconda - excellent for data science')
        recommendations.append('→ Use "conda install" for data science packages')
        recommendations.append('→ Use "pip install" only for packages not in conda-forge')
    
    # Проверка pipx
    try:
        subprocess.run(['pipx', '--version'], capture_output=True, timeout=5)
        recommendations.append('✓ pipx available - great for CLI tools')
        recommendations.append('→ Use "pipx install" for standalone CLI applications')
    except:
        recommendations.append('→ Consider installing pipx for CLI tools')
    
    return recommendations

# Основная диагностика
print('=== PYTHON ENVIRONMENT DIAGNOSTICS ===')
env_info = get_full_env_info()

print('\n📍 PYTHON INSTALLATION:')
for key, value in env_info['python_info'].items():
    print(f'  {key}: {value}')

print('\n📦 PACKAGE MANAGERS:')
for manager, version in env_info['package_managers'].items():
    status = '✓' if 'Not' not in version else '✗'
    print(f'  {status} {manager}: {version}')

print('\n📚 KEY PACKAGES:')
for package, version in env_info['key_packages'].items():
    status = '✓' if 'Not installed' not in version else '✗'
    print(f'  {status} {package}: {version}')

print('\n🔍 POTENTIAL CONFLICTS:')
conflicts = check_environment_conflicts()
if conflicts:
    for conflict in conflicts:
        print(f'  ⚠️  {conflict}')
else:
    print('  ✓ No major conflicts detected')

print('\n💡 RECOMMENDATIONS:')
recommendations = get_recommendations()
for rec in recommendations:
    print(f'  {rec}')

print('\n🛠️ PATH ANALYSIS:')
print(f'  Current working directory: {env_info["path_info"]["current_dir"]}')
print('  Python path (first 5):')
for i, path in enumerate(env_info['path_info']['python_path'][:5]):
    print(f'    {i+1}. {path}')
"@

# Запуск полной диагностики
py -c $global:pythonDiagnostics

wrgb "`n=== POWERSHELL + PYTHON INTEGRATION TIPS ===" -FC Cyan -newline

wrgb "`n🔧 Для оптимальной работы с вашим окружением:" -FC Yellow -newline
wrgb "1. Используйте conda для научных пакетов (numpy, pandas, scipy)" -FC Green -newline
wrgb "2. Используйте pipx для CLI утилит (black, flake8, jupyter)" -FC Green  -newline
wrgb "3. Используйте pip только для пакетов, недоступных в conda-forge" -FC Green -newline
wrgb "4. Ваша текущая настройка идеальна для data science работы!" -FC Green -newline

wrgb "`n📋 Полезные команды для вашего окружения:" -FC OrangeRGB -newline
wrgb "conda list                    # Список установленных пакетов" -FC Gray -newline
wrgb "conda list                    # Список установленных пакетов" -FC Gray -newline
wrgb "conda search package_name" -FC Gray
wrgb "# Поиск пакетов в conda" -newline
wrgb "pipx list                        " -FC Gray -newline
wrgb "# Список CLI приложений" -newline
wrgb "python -m pip list     "
wrgb "# Список pip пакетов" -newline

# Проверка специфичных для вашего окружения возможностей
wrgb "`n🚀 Специальные возможности вашей конфигурации:" -FC Yellow -newline

$specialFeatures = @"
# Jupyter integration
#import jupyter_core
#print(f'Jupyter available at: {jupyter_core.paths.jupyter_runtime_dir()}')

# Rich CLI integration  
import rich
from power_theme import console, COLORS
from rich.table import Table

console.print('Rich formatting works perfectly!', style='bold green')

table = Table(show_header=True)
table.add_column('Feature', style='cyan')
table.add_column('Status', style='green')
table.add_row('Anaconda', '✓ Active')
table.add_row('pipx', '✓ Available')
table.add_row('Rich CLI', '✓ Installed')

console.print(table)
"@

wrgb "Тестирование rich-cli (если установлен):" -FC Cyan -newline
try {
    py -c $specialFeatures
} catch {
    wrgb "Rich CLI не установлен или недоступен" -FC Yellow -newline
    wrgb "Установите: pipx install rich-cli" -FC Gray -newline
}
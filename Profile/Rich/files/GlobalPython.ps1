# ===== СПОСОБ 1: Базовая инициализация =====
$global:pythonInit = @"
import json
import sys
import os
from datetime import datetime

def log_message(msg, level='INFO'):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f'[{timestamp}] {level}: {msg}')

def safe_json_loads(data):
    try:
        return json.loads(data)
    except:
        return None

def get_system_info():
    return {
        'platform': sys.platform,
        'version': sys.version,
        'path': sys.path[:3]  # первые 3 пути
    }
"@

# Использование:
$localPython = @"
log_message('Starting script execution')
info = get_system_info()
print(json.dumps(info, indent=2))
log_message('Script completed')
"@

python -c ($global:pythonInit + "`n" + $localPython)

# ===== СПОСОБ 2: С функциями-хелперами =====
$global:pythonUtils = @"
import subprocess
import tempfile
import shutil
import os

class FileManager:
    @staticmethod
    def create_temp_dir():
        return tempfile.mkdtemp()
    
    @staticmethod
    def cleanup_temp(path):
        if os.path.exists(path):
            shutil.rmtree(path)
    
    @staticmethod
    def read_file(filepath):
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            return f'Error reading file: {e}'

class ProcessHelper:
    @staticmethod
    def run_command(cmd):
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            return {'stdout': result.stdout, 'stderr': result.stderr, 'returncode': result.returncode}
        except Exception as e:
            return {'error': str(e)}

fm = FileManager()
ph = ProcessHelper()
"@

# PowerShell функция для удобства
function Invoke-PythonWithUtils {
    param([string]$Code)
    python -c ($global:pythonUtils + "`n" + $Code)
}

# Использование:
Invoke-PythonWithUtils -Code @"
temp_dir = fm.create_temp_dir()
print(f'Created temp directory: {temp_dir}')

# Выполнение команды
result = ph.run_command('dir' if os.name == 'nt' else 'ls')
print('Command output:', result['stdout'][:200])

fm.cleanup_temp(temp_dir)
print('Temp directory cleaned up')
"@

# ===== СПОСОБ 3: Модульная система =====
$global:pythonModules = @{
    'logging' = @"
import logging
from datetime import datetime

class CustomLogger:
    def __init__(self, name='PowerShell-Python'):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(logging.DEBUG)
        
        if not self.logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter('[%(asctime)s] %(levelname)s: %(message)s')
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)
    
    def info(self, msg): self.logger.info(msg)
    def error(self, msg): self.logger.error(msg)
    def debug(self, msg): self.logger.debug(msg)

logger = CustomLogger()
"@
    
    'data_processing' = @"
import csv
import json
from collections import defaultdict

class DataProcessor:
    @staticmethod
    def csv_to_dict(csv_content, delimiter=','):
        lines = csv_content.strip().split('\n')
        if not lines:
            return []
        
        reader = csv.DictReader(lines, delimiter=delimiter)
        return list(reader)
    
    @staticmethod
    def group_by(data, key):
        grouped = defaultdict(list)
        for item in data:
            grouped[item.get(key, 'unknown')].append(item)
        return dict(grouped)
    
    @staticmethod
    def filter_data(data, condition_func):
        return [item for item in data if condition_func(item)]

dp = DataProcessor()
"@
    
    'web_utils' = @"
import urllib.request
import urllib.parse
import json

class WebUtils:
    @staticmethod
    def fetch_url(url, timeout=10):
        try:
            with urllib.request.urlopen(url, timeout=timeout) as response:
                return response.read().decode('utf-8')
        except Exception as e:
            return f'Error fetching URL: {e}'
    
    @staticmethod
    def post_json(url, data, timeout=10):
        try:
            json_data = json.dumps(data).encode('utf-8')
            req = urllib.request.Request(url, data=json_data, 
                                       headers={'Content-Type': 'application/json'})
            with urllib.request.urlopen(req, timeout=timeout) as response:
                return response.read().decode('utf-8')
        except Exception as e:
            return f'Error posting to URL: {e}'

web = WebUtils()
"@
}

# Функция для загрузки модулей
function Get-PythonCode {
    param([string[]]$Modules)
    
    $code = ""
    foreach ($module in $Modules) {
        if ($global:pythonModules.ContainsKey($module)) {
            $code += $global:pythonModules[$module] + "`n`n"
        }
    }
    return $code
}

# Функция для выполнения с модулями
function Invoke-PythonWithModules {
    param(
        [string[]]$Modules,
        [string]$Code
    )
    
    $moduleCode = Get-PythonCode -Modules $Modules
    $fullCode = $moduleCode + $Code
    python -c $fullCode
}

# Использование модульной системы:
Invoke-PythonWithModules -Modules @('logging', 'data_processing') -Code @"
logger.info('Starting data processing')

# Пример обработки CSV данных
csv_data = '''name,age,city
John,25,New York
Jane,30,London
Bob,35,Paris'''

data = dp.csv_to_dict(csv_data)
logger.info(f'Loaded {len(data)} records')

# Группировка по городам
grouped = dp.group_by(data, 'city')
for city, people in grouped.items():
    logger.info(f'{city}: {len(people)} people')

# Фильтрация людей старше 28
adults = dp.filter_data(data, lambda x: int(x['age']) > 28)
logger.info(f'People over 28: {len(adults)}')
"@

# ===== СПОСОБ 4: Продвинутая конфигурация =====
$global:pythonConfig = @{
    'base_imports' = @"
import os
import sys
import json
import time
from pathlib import Path
from datetime import datetime, timedelta
"@
    
    'environment_setup' = @"
# Настройка окружения
SCRIPT_DIR = Path(__file__).parent if '__file__' in globals() else Path.cwd()
CONFIG = {
    'debug': os.getenv('PYTHON_DEBUG', 'false').lower() == 'true',
    'log_level': os.getenv('PYTHON_LOG_LEVEL', 'INFO'),
    'output_format': os.getenv('PYTHON_OUTPUT_FORMAT', 'json')
}

def debug_print(msg):
    if CONFIG['debug']:
        print(f'DEBUG: {msg}', file=sys.stderr)
"@
}

# Функция для создания полного Python окружения
function New-PythonEnvironment {
    param(
        [switch]$IncludeModules,
        [string[]]$Modules = @(),
        [switch]$Debug
    )
    
    $code = $global:pythonConfig['base_imports'] + "`n"
    $code += $global:pythonConfig['environment_setup'] + "`n"
    
    if ($Debug) {
        $code += "CONFIG['debug'] = True`n"
    }
    
    if ($IncludeModules -and $Modules.Count -gt 0) {
        $code += Get-PythonCode -Modules $Modules
    }
    
    return $code
}

# Пример использования продвинутой конфигурации:
$env = New-PythonEnvironment -IncludeModules -Modules @('logging', 'web_utils') -Debug

$myScript = @"
debug_print('Environment initialized')
logger.info('Starting advanced script')

# Пример использования web утилит
# content = web.fetch_url('https://httpbin.org/json')
# debug_print(f'Fetched content length: {len(content)}')

logger.info('Script execution completed')
"@

python -c ($env + "`n" + $myScript)

# ===== БОНУС: Сохранение в файлы для переиспользования =====
# Сохранение конфигурации в файл
$configPath = Join-Path $env:TEMP "python_powershell_config.py"
$global:pythonInit | Out-File -FilePath $configPath -Encoding UTF8

# Использование сохраненного файла
function Invoke-PythonWithConfigFile {
    param([string]$Code)
    $tempScript = Join-Path $env:TEMP "temp_python_script.py"
    
    try {
        # Объединяем конфиг и код
        $fullCode = (Get-Content $configPath -Raw) + "`n" + $Code
        $fullCode | Out-File -FilePath $tempScript -Encoding UTF8
        
        python $tempScript
    }
    finally {
        if (Test-Path $tempScript) {
            Remove-Item $tempScript -Force
        }
    }
}

Write-Host "=== Примеры использования готовы к выполнению! ===" -ForegroundColor Green
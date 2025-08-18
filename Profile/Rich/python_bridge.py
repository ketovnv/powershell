"""Universal Python-PowerShell Bridge"""
import sys
import json
import importlib.util
from pathlib import Path
from typing import Any, Dict, List, Optional
import inspect


class PowerShellBridge:
    """Import and execute Python modules from PowerShell"""

    @staticmethod
    def import_from_file(file_path: str, functions: List[str] = None) -> Dict[str, Any]:
        """Import specific functions from a Python file"""
        path = Path(file_path)

        # Загружаем модуль
        spec = importlib.util.spec_from_file_location(path.stem, path)
        module = importlib.util.module_from_spec(spec)
        sys.modules[path.stem] = module

        spec.loader.exec_module(module)

        # Экспортируем функции
        exports = {}

        if functions:
            # Только указанные функции
            for func_name in functions:
                if hasattr(module, func_name):
                    exports[func_name] = getattr(module, func_name)
        else:
            # Все функции (не начинающиеся с _)
            for name, obj in inspect.getmembers(module):
                if inspect.isfunction(obj) and not name.startswith('_'):
                    exports[name] = obj
                elif inspect.isclass(obj) and not name.startswith('_'):
                    exports[name] = obj

        return exports

    @staticmethod
    def execute_function(file_path: str, function_name: str, *args, **kwargs):
        """Execute a specific function from a file"""
        exports = PowerShellBridge.import_from_file(file_path, [function_name])

        if function_name in exports:
            result = exports[function_name](*args, **kwargs)

            # Конвертируем результат для PowerShell
            if isinstance(result, (dict, list)):
                return json.dumps(result)
            return result
        else:
            raise AttributeError(f"Function '{function_name}' not found in {file_path}")


# CLI interface
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["import", "execute", "list"])
    parser.add_argument("file", help="Python file path")
    parser.add_argument("--functions", nargs="+", help="Functions to import")
    parser.add_argument("--function", help="Function to execute")
    parser.add_argument("--args", nargs="+", help="Arguments for function")
    parser.add_argument("--kwargs", type=json.loads, default={}, help="Keyword arguments as JSON")

    args = parser.parse_args()

    bridge = PowerShellBridge()

    if args.action == "list":
        # Показать доступные функции
        exports = bridge.import_from_file(args.file)
        for name, obj in exports.items():
            if inspect.isfunction(obj):
                sig = inspect.signature(obj)
                print(f"function: {name}{sig}")
            elif inspect.isclass(obj):
                print(f"class: {name}")

    elif args.action == "import":
        exports = bridge.import_from_file(args.file, args.functions)
        print(json.dumps(list(exports.keys())))

    elif args.action == "execute":
        result = bridge.execute_function(
            args.file,
            args.function,
            *(args.args or []),
            **(args.kwargs or {})
        )
        print(result)
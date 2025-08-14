# Архив: Множественные форматы отчетов о тестировании

- Идентификатор задачи: multiple-report-formats
- Ветка: feature/multiple-report-formats
- Дата архивации: 2025-08-13
- Статус тестов: 2/2 пройдено (см. лог MCP)

## Краткое описание
Добавлена поддержка формирования нескольких отчетов о тестировании за один прогон (jUnit + Allure) с сохранением обратной совместимости с `reportFormat`/`reportPath`.

## Основные изменения
- `exts/yaxunit/src/CommonModules/ЮТФабрика/Module.bsl`: добавлено свойство `reports` по умолчанию
- `exts/yaxunit/src/CommonModules/ЮТПараметрыЗапускаСлужебный/Module.bsl`: чтение `reports` из JSON и бэккомпат
- `exts/yaxunit/src/CommonModules/ЮТОтчетСлужебный/Module.bsl`: цикл по `reports` и формирование нескольких отчетов
- Тесты: `tests/src/CommonModules/ОМ_ЮТОтчетСлужебный/Module.bsl` — сценарии одиночного Allure и множественных отчетов
- Документация: обновлены разделы запуска и отчетов

## Совместимость
- При отсутствии `reports` автоматически используется старый контракт `reportFormat`/`reportPath`

## Результаты тестов
- Модуль: `ОМ_ЮТОтчетСлужебный`
  - Сценарии: `СформироватьОтчет_Allure`, `СформироватьНесколькоОтчетов`
  - Результат: 2/2 пройдено

## Ссылки
- Issue: `https://github.com/bia-technologies/yaxunit/issues/513`
- Рефлексия: `memory-bank/reflection/reflection-multiple-report-formats.md`
- Креатив: `memory-bank/creative/creative-multiple-report-formats.md`

## Примечания
- Неизвестный формат в `reports` логируется и пропускается, остальные отчеты формируются
- При отсутствии пути у элемента и общего `reportPath` — лог ошибки и пропуск элемента

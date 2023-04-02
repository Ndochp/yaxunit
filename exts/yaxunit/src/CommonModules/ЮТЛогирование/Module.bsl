//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2023 BIA-Technologies Limited Liability Company
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//©///////////////////////////////////////////////////////////////////////////©//

#Область ПрограммныйИнтерфейс

// Вывод отладочного сообщения в лог
// 
// Параметры:
//  Сообщение - Строка - Сообщение
Процедура Отладка(Сообщение) Экспорт
	
	Записать("DBG", Сообщение, 0);
	
КонецПроцедуры

// Вывод информационного сообщения в лог
// 
// Параметры:
//  Сообщение - Строка - Сообщение
Процедура Информация(Сообщение) Экспорт
	
	Записать("INF", Сообщение, 1);
	
КонецПроцедуры

// Вывод ошибки в лог
// 
// Параметры:
//  Сообщение - Строка - Сообщение
Процедура Ошибка(Сообщение) Экспорт
	
	Записать("ERR", Сообщение, 2);
	
КонецПроцедуры

Функция УровниЛога() Экспорт
	
	Возврат Новый ФиксированнаяСтруктура("Отладка, Информация, Ошибка", "debug", "info", "error");
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ВывестиСерверныеСообщения() Экспорт
	
#Если Клиент Тогда
	Контекст = Контекст();
	Если Контекст = Неопределено ИЛИ НЕ Контекст.Включено ИЛИ Контекст.ДоступенНаСервере Тогда
		Возврат;
	КонецЕсли;
	
	Сообщения = ЮТЛогированиеВызовСервера.НакопленныеСообщенияЛогирования(Истина);
	ЗаписатьСообщения(Контекст.ФайлЛога, Сообщения);
#Иначе
	ВызватьИсключение "Метод вывода сервеных сообщений в лог должен вызываться с клиента"
#КонецЕсли
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОбработчикиСобытий

// Инициализация.
// 
// Параметры:
//  ПараметрыЗапуска - см. ЮТФабрика.ПараметрыЗапуска
Процедура Инициализация(ПараметрыЗапуска) Экспорт
	
	ДанныеКонтекста = НовыйДанныеКонтекста();
	ДанныеКонтекста.ФайлЛога = ПараметрыЗапуска.logging.file;
	
	Если ПараметрыЗапуска.logging.enable = Неопределено Тогда
		ДанныеКонтекста.Включено = ЗначениеЗаполнено(ДанныеКонтекста.ФайлЛога);
	Иначе
		ДанныеКонтекста.Включено = ПараметрыЗапуска.logging.enable;
	КонецЕсли;
	
	Если НЕ ДанныеКонтекста.Включено Тогда
		ЮТКонтекст.УстановитьЗначениеКонтекста(ИмяКонтекстаЛогирования(), ДанныеКонтекста, Истина);
		Возврат;
	КонецЕсли;
	
	УровениЛога = УровниЛога();
	
	Если СтрСравнить(ПараметрыЗапуска.logging.level, УровениЛога.Ошибка) = 0 Тогда
		ДанныеКонтекста.УровеньЛога = 2;
	ИначеЕсли СтрСравнить(ПараметрыЗапуска.logging.level, УровениЛога.Информация) = 0 Тогда
		ДанныеКонтекста.УровеньЛога = 1;
	Иначе
		ДанныеКонтекста.УровеньЛога = 0;
	КонецЕсли;
	
	ЗначениеПроверки = Строка(Новый УникальныйИдентификатор());
	ЗаписатьСообщения(ДанныеКонтекста.ФайлЛога, ЮТОбщий.ЗначениеВМассиве(ЗначениеПроверки), Ложь);
	ДанныеКонтекста.ДоступенНаСервере = ЮТЛогированиеВызовСервера.ФайлЛогаДоступенНаСервере(ДанныеКонтекста.ФайлЛога, ЗначениеПроверки);
	
	ЮТКонтекст.УстановитьЗначениеКонтекста(ИмяКонтекстаЛогирования(), ДанныеКонтекста, Истина);
	
	Разделитель = "------------------------------------------------------";
	ЗаписатьСообщения(ДанныеКонтекста.ФайлЛога, ЮТОбщий.ЗначениеВМассиве(Разделитель), Ложь);
	Информация("Старт");
	
КонецПроцедуры

// Обработка события "ПередЧтениеСценариев"
Процедура ПередЧтениеСценариев() Экспорт
	
	Информация("Загрузка сценариев");
	
КонецПроцедуры

// Перед чтением сценариев модуля.
// 
// Параметры:
//  МетаданныеМодуля - см. ЮТФабрика.ОписаниеМодуля
//  ИсполняемыеСценарии - см. ЮТТесты.СценарииМодуля
Процедура ПередЧтениемСценариевМодуля(МетаданныеМодуля, ИсполняемыеСценарии) Экспорт
	
	Информация(СтрШаблон("Загрузка сценариев модуля `%1`", МетаданныеМодуля.Имя));
	
КонецПроцедуры

// Перед чтением сценариев модуля.
// 
// Параметры:
//  МетаданныеМодуля - см. ЮТФабрика.ОписаниеМодуля
//  ИсполняемыеСценарии - см. ЮТТесты.СценарииМодуля
Процедура ПослеЧтенияСценариевМодуля(МетаданныеМодуля, ИсполняемыеСценарии) Экспорт
	
	Информация(СтрШаблон("Загрузка сценариев модуля завершена `%1`", МетаданныеМодуля.Имя));
	
КонецПроцедуры

// Обработка события "ПослеЧтенияСценариев"
// Параметры:
//  Сценарии - Массив из см. ЮТФабрика.ОписаниеТестовогоМодуля - Набор описаний тестовых модулей, которые содержат информацию о запускаемых тестах
Процедура ПослеЧтенияСценариев(Сценарии) Экспорт
	
	Информация("Загрузка сценариев завершена.");
	
КонецПроцедуры

// Обработка события "ПослеФормированияИсполняемыхНаборовТестов"
// Параметры:
//  КоллекцияКатегорийНаборов - Массив из см. ЮТФабрика.ОписаниеКатегорияНабораТестов - Набор исполняемых наборов
Процедура ПослеФормированияИсполняемыхНаборовТестов(КоллекцияКатегорийНаборов) Экспорт
	
	Количество = 0;
	
	Для Каждого Наборы Из КоллекцияКатегорийНаборов Цикл
		
		Для Каждого Набор Из Наборы.Клиентские Цикл
			ЮТОбщий.Инкремент(Количество, Набор.Тесты.Количество());
		КонецЦикла;
		
		Для Каждого Набор Из Наборы.Серверные Цикл
			ЮТОбщий.Инкремент(Количество, Набор.Тесты.Количество());
		КонецЦикла;
		
	КонецЦикла;
	
	ЮТКонтекст.УстановитьЗначениеКонтекста(ИмяКонтекстаЛогирования() + ".ОбщееКоличествоТестов", Количество, Истина);
	
КонецПроцедуры

// Перед всеми тестами.
// 
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрика.ОписаниеСобытияИсполненияТестов
Процедура ПередВсемиТестами(ОписаниеСобытия) Экспорт
	
#Если Клиент Тогда
	ПрогрессКлиент = Контекст().КоличествоВыполненныхТестов;
	ПрогрессСервер = ЮТКонтекст.ЗначениеКонтекста(ИмяКонтекстаЛогирования() + ".КоличествоВыполненныхТестов", Истина);
	
	Если ПрогрессКлиент < ПрогрессСервер Тогда
		Контекст().КоличествоВыполненныхТестов = ПрогрессСервер;
	КонецЕсли;
#КонецЕсли
	Информация(СтрШаблон("Запуск тестов модуля `%1`", ОписаниеСобытия.Модуль.МетаданныеМодуля.ПолноеИмя));
	
КонецПроцедуры

// Перед тестовым набором.
// 
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрика.ОписаниеСобытияИсполненияТестов
Процедура ПередТестовымНабором(ОписаниеСобытия) Экспорт
	
	Информация(СтрШаблон("Запуск тестов набора `%1`", ОписаниеСобытия.Набор.Имя));
	
КонецПроцедуры

// Перед каждым тестом.
// 
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрика.ОписаниеСобытияИсполненияТестов
Процедура ПередКаждымТестом(ОписаниеСобытия) Экспорт
	
	Информация(СтрШаблон("Запуск теста `%1`", ОписаниеСобытия.Тест.Имя));
	
КонецПроцедуры

// Перед каждым тестом.
// 
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрика.ОписаниеСобытияИсполненияТестов
Процедура ПослеКаждогоТеста(ОписаниеСобытия) Экспорт
	
	Контекст = Контекст();
	ЮТОбщий.Инкремент(Контекст.КоличествоВыполненныхТестов);
	Информация(СтрШаблон("%1 Завершен тест `%2`", Прогресс(), ОписаниеСобытия.Тест.Имя));
	
КонецПроцедуры

// Перед каждым тестом.
// 
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрика.ОписаниеСобытияИсполненияТестов
Процедура ПослеТестовогоНабора(ОписаниеСобытия) Экспорт
	
	Информация(СтрШаблон("Завершен тестый набор `%1`", ОписаниеСобытия.Набор.Имя));
	
КонецПроцедуры

// Перед каждым тестом.
// 
// Параметры:
//  ОписаниеСобытия - см. ЮТФабрика.ОписаниеСобытияИсполненияТестов
Процедура ПослеВсехТестов(ОписаниеСобытия) Экспорт
	
#Если Клиент Тогда
	Прогресс = Контекст().КоличествоВыполненныхТестов;
	ЮТКонтекст.УстановитьЗначениеКонтекста(ИмяКонтекстаЛогирования() + ".КоличествоВыполненныхТестов", Прогресс, Истина);
#КонецЕсли
	
	Информация(СтрШаблон("Завершен модуль `%1`", ОписаниеСобытия.Модуль.МетаданныеМодуля.ПолноеИмя));
	
КонецПроцедуры

#КонецОбласти

#Область Контекст

// Контекст.
// 
// Возвращаемое значение:
//  см. НовыйДанныеКонтекста
Функция Контекст()
	
	Возврат ЮТКонтекст.ЗначениеКонтекста(ИмяКонтекстаЛогирования());
	
КонецФункции

Функция ИмяКонтекстаЛогирования()
	
	Возврат "КонтекстЛогирования";
	
КонецФункции

// Новый данные контекста.
// 
// Возвращаемое значение:
//  Структура - Новый данные контекста:
// * Включено - Булево - Логирование включено
// * ФайлЛога - Неопределено - Файл вывода лога
// * ДоступенНаСервере - Булево - Файл лога доступен на сервере
// * НакопленныеЗаписи - Массив из Строка - Буфер для серверных сообщений
// * ОбщееКоличествоТестов - Число
// * КоличествоВыполненныхТестов - Число
// * УровеньЛога - Число - Уровень логирования
Функция НовыйДанныеКонтекста()
	
	ДанныеКонтекста = Новый Структура();
	ДанныеКонтекста.Вставить("Включено", Ложь);
	ДанныеКонтекста.Вставить("ФайлЛога", Неопределено);
	ДанныеКонтекста.Вставить("ДоступенНаСервере", Ложь);
	ДанныеКонтекста.Вставить("НакопленныеЗаписи", Новый Массив());
	ДанныеКонтекста.Вставить("ОбщееКоличествоТестов", 0);
	ДанныеКонтекста.Вставить("КоличествоВыполненныхТестов", 0);
	ДанныеКонтекста.Вставить("УровеньЛога", 0);
	
	Возврат ДанныеКонтекста;
	
КонецФункции

#КонецОбласти

#Область Запись

Функция НакопленныеСообщенияЛогирования(Очистить = Ложь) Экспорт
	
	Контекст = Контекст();
	
	Сообщения = Контекст.НакопленныеЗаписи;
	
	Если Очистить Тогда
		Контекст.НакопленныеЗаписи = Новый Массив();
	КонецЕсли;
	
	Возврат Сообщения;
	
КонецФункции

Процедура Записать(УровеньЛога, Сообщение, Приоритет)
	
	Контекст = Контекст();
	Если Контекст = Неопределено ИЛИ НЕ Контекст.Включено ИЛИ Контекст.УровеньЛога > Приоритет Тогда
		Возврат;
	КонецЕсли;
	
#Если Клиент Тогда
	КонтекстИсполнения = "Клиент";
#Иначе
	КонтекстИсполнения = "Сервер";
#КонецЕсли
	Текст = СтрШаблон("%1 [%2][%3]: %4", ЮТОбщий.ПредставлениеУниверсальнойДата(), КонтекстИсполнения, УровеньЛога, Сообщение);
#Если Клиент Тогда
	ЗаписатьСообщения(Контекст.ФайлЛога, ЮТОбщий.ЗначениеВМассиве(Текст));
#Иначе
	Если Контекст.ДоступенНаСервере Тогда
		ЗаписатьСообщения(Контекст.ФайлЛога, ЮТОбщий.ЗначениеВМассиве(Текст));
	Иначе
		Контекст.НакопленныеЗаписи.Добавить(Текст);
	КонецЕсли;
#КонецЕсли
	
КонецПроцедуры

Процедура ЗаписатьСообщения(ФайлЛога, Сообщения, Дописывать = Истина)
	
#Если ВебКлиент Тогда
	ВызватьИсключение "Метод записи лога не доступен в web-клиенте";
#Иначе
	Запись = Новый ЗаписьТекста(ФайлЛога, КодировкаТекста.UTF8, , Дописывать);
	
	Для Каждого Сообщение Из Сообщения Цикл
		Запись.ЗаписатьСтроку(Сообщение);
	КонецЦикла;
	
	Запись.Закрыть();
#КонецЕсли

КонецПроцедуры

Функция Прогресс()
	
	Контекст = Контекст();
	Прогресс = Окр(100 * Контекст.КоличествоВыполненныхТестов / Контекст.ОбщееКоличествоТестов, 0);
	
	Возврат СтрШаблон("%1%% (%2/%3)", Прогресс, Контекст.КоличествоВыполненныхТестов, Контекст.ОбщееКоличествоТестов);
	
КонецФункции

#КонецОбласти

#КонецОбласти

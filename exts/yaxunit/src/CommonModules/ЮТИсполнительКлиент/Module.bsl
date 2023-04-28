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

/////////////////////////////////////////////////////////////////////////////////
// Экспортные процедуры и функции, предназначенные для использования другими 
// объектами конфигурации или другими программами
///////////////////////////////////////////////////////////////////////////////// 
#Область СлужебныйПрограммныйИнтерфейс

Процедура ВыполнитьМодульноеТестирование() Экспорт
	
	ПараметрыИсполнения = ПараметрыИсполнения();
	ПараметрыИсполнения.АргументыЗапуска = ПараметрЗапуска;
	
	ДобавитьОбработчикЦепочки(ПараметрыИсполнения, "ОбработчикЗагрузитьПараметры");
	ДобавитьОбработчикЦепочки(ПараметрыИсполнения, "ОбработчикАнализПараметровЗапуска");
	ДобавитьОбработчикЦепочки(ПараметрыИсполнения, "ОбработчикЗагрузитьТесты");
	ДобавитьОбработчикЦепочки(ПараметрыИсполнения, "ОбработчикВыполнитьТестирование");
	ДобавитьОбработчикЦепочки(ПараметрыИсполнения, "ОбработчикСохранитьОтчет");
	ДобавитьОбработчикЦепочки(ПараметрыИсполнения, "ОбработчикСохранитьКодВозврата");
	ДобавитьОбработчикЦепочки(ПараметрыИсполнения, "ОбработчикЗавершить");
	
	ВызватьСледующийОбработчик(ПараметрыИсполнения);
	
КонецПроцедуры

Процедура ВызватьОбработчик(Обработчик, Результат = Неопределено) Экспорт
	
	Если Обработчик <> Неопределено Тогда
		ВыполнитьОбработкуОповещения(Обработчик, Результат);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОбработчикиЦепочкиДействий

Процедура ОбработчикОшибки(ИнформацияОбОшибки, СтандартнаяОбработка, ДополнительныеПараметры) Экспорт
	
	// TODO Подумать надо ли и как реализовать нормально
	
КонецПроцедуры

Процедура ОбработчикЗагрузитьПараметры(Результат, ДополнительныеПараметры) Экспорт
	
	Обработчик = СледующийОбработчик(ДополнительныеПараметры);
	ЮТПараметрыЗапуска.ПараметрыЗапуска(ДополнительныеПараметры.АргументыЗапуска, Обработчик);
	
КонецПроцедуры

Процедура ОбработчикАнализПараметровЗапуска(ПараметрыЗапуска, ДополнительныеПараметры) Экспорт
	
	ДополнительныеПараметры.ПараметрыЗапуска = ПараметрыЗапуска;
	
	Если НЕ ПараметрыЗапуска.ВыполнятьМодульноеТестирование Тогда
		Возврат;
	КонецЕсли;
	
	ВызватьСледующийОбработчик(ДополнительныеПараметры);
	
КонецПроцедуры

Процедура ОбработчикЗагрузитьТесты(Результат, ДополнительныеПараметры) Экспорт
	
	Параметры = ДополнительныеПараметры.ПараметрыЗапуска;
	
	ЮТКонтекст.ИнициализироватьКонтекст();
	ЮТКонтекст.УстановитьГлобальныеНастройкиВыполнения(Параметры.settings);
	ЮТСобытия.Инициализация(Параметры);
	// Повторно сохраним для передачи на сервер
	ЮТКонтекст.УстановитьГлобальныеНастройкиВыполнения(ЮТКонтекст.ГлобальныеНастройкиВыполнения());
	ЮТКонтекст.УстановитьКонтекстИсполнения(ЮТФабрика.НовыйКонтекстИсполнения());
	
	ЮТСобытия.ПередЧтениеСценариев();
	ТестовыеМодули = ЮТЧитатель.ЗагрузитьТесты(Параметры);
	ЮТСобытия.ПослеЧтенияСценариев(ТестовыеМодули);
	
	КоллекцияКатегорийНаборов = Новый Массив();
	
	Для Каждого ТестовыйМодуль Из ТестовыеМодули Цикл
		КатегорииНаборов = КатегорииНаборовТестовМодуля(ТестовыйМодуль);
		КоллекцияКатегорийНаборов.Добавить(КатегорииНаборов);
	КонецЦикла;
	
	ЮТСобытия.ПослеФормированияИсполняемыхНаборовТестов(КоллекцияКатегорийНаборов);
	ДополнительныеПараметры.КоллекцияКатегорийНаборов = КоллекцияКатегорийНаборов;
	
	ВызватьСледующийОбработчик(ДополнительныеПараметры);
	
КонецПроцедуры

Процедура ОбработчикВыполнитьТестирование(Результат, ДополнительныеПараметры) Экспорт
	
	РезультатыТестирования = Новый Массив();
	КоллекцияКатегорийНаборов = ДополнительныеПараметры.КоллекцияКатегорийНаборов;
	
	Для Каждого КатегорииНаборов Из КоллекцияКатегорийНаборов Цикл
		
		Результат = ЮТИсполнительКлиентСервер.ВыполнитьГруппуНаборовТестов(КатегорииНаборов.Клиентские, КатегорииНаборов.ТестовыйМодуль);
		ЮТОбщий.ДополнитьМассив(РезультатыТестирования, Результат);
		
		Результат = ЮТИсполнительСервер.ВыполнитьГруппуНаборовТестов(КатегорииНаборов.Серверные, КатегорииНаборов.ТестовыйМодуль);
		ЮТЛогирование.ВывестиСерверныеСообщения();
		
		ЮТОбщий.ДополнитьМассив(РезультатыТестирования, Результат);
		
		ЮТОбщий.ДополнитьМассив(РезультатыТестирования, КатегорииНаборов.Пропущенные);
		
	КонецЦикла;
	
	ДополнительныеПараметры.РезультатыТестирования = РезультатыТестирования;
	ВызватьСледующийОбработчик(ДополнительныеПараметры);
	
КонецПроцедуры

Процедура ОбработчикСохранитьОтчет(Результат, ДополнительныеПараметры) Экспорт
	
	Если ЗначениеЗаполнено(ДополнительныеПараметры.ПараметрыЗапуска.reportPath) Тогда
		Обработчик = СледующийОбработчик(ДополнительныеПараметры);
		ЮТОтчет.СформироватьОтчет(ДополнительныеПараметры.РезультатыТестирования, ДополнительныеПараметры.ПараметрыЗапуска, Обработчик);
	Иначе
		ВызватьСледующийОбработчик(ДополнительныеПараметры);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработчикСохранитьКодВозврата(Результат, ДополнительныеПараметры) Экспорт
	
	ЗаписатьКодВозврата(ДополнительныеПараметры.РезультатыТестирования, ДополнительныеПараметры.ПараметрыЗапуска);
	ВызватьСледующийОбработчик(ДополнительныеПараметры);
	
КонецПроцедуры

Процедура ОбработчикЗавершить(Результат, ДополнительныеПараметры) Экспорт
	
	Параметры = ДополнительныеПараметры.ПараметрыЗапуска;
	ЮТКонтекст.УдалитьКонтекст();
	
	Если Параметры.showReport Тогда
		ПоказатьОтчет(ДополнительныеПараметры.РезультатыТестирования, Параметры);
	ИначеЕсли Параметры.CloseAfterTests Тогда
		ПрекратитьРаботуСистемы(Ложь);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

Процедура ВызватьСледующийОбработчик(ПараметрыИсполнения, Результат = Неопределено)
	
	Обработчик = СледующийОбработчик(ПараметрыИсполнения);
	ВыполнитьОбработкуОповещения(Обработчик, Результат);
	
КонецПроцедуры

Функция СледующийОбработчик(ПараметрыИсполнения)
	
	ПараметрыИсполнения.ИндексСледующегоОбработчика = ПараметрыИсполнения.ИндексСледующегоОбработчика + 1;
	Возврат ПараметрыИсполнения.Цепочка[ПараметрыИсполнения.ИндексСледующегоОбработчика];
	
КонецФункции

Процедура ДобавитьОбработчикЦепочки(ПараметрыИсполнения, ИмяМетода)
	
	Обработчик = Новый ОписаниеОповещения(ИмяМетода, ЭтотОбъект, ПараметрыИсполнения, "ОбработчикОшибки", ЭтотОбъект);
	ПараметрыИсполнения.Цепочка.Добавить(Обработчик);
	
КонецПроцедуры

Функция ПараметрыИсполнения()
	
	Параметры = Новый Структура();
	Параметры.Вставить("АргументыЗапуска");
	Параметры.Вставить("ПараметрыЗапуска");
	Параметры.Вставить("Цепочка", Новый Массив());
	Параметры.Вставить("ИндексСледующегоОбработчика", -1);
	Параметры.Вставить("КоллекцияКатегорийНаборов");
	Параметры.Вставить("РезультатыТестирования");
	
	Возврат Параметры;
	
КонецФункции

Функция КатегорииНаборовТестовМодуля(ТестовыйМодуль)
	
	КатегорииНаборов = ЮТФабрика.ОписаниеКатегорияНабораТестов(ТестовыйМодуль);
	
	ИсполняемыеТестовыеНаборы = Новый Массив;
	
	Для Каждого ТестовыйНабор Из ТестовыйМодуль.НаборыТестов Цикл
		
		НаборыКонтекстов = Новый Структура;
		
		ТестыНабора = ЮТОбщий.ЗначениеСтруктуры(ТестовыйНабор, "Тесты", Новый Массив());
		
		Для Каждого Тест Из ТестыНабора Цикл
			
			Для Каждого Контекст Из Тест.КонтекстВызова Цикл
				
				Если НЕ НаборыКонтекстов.Свойство(Контекст) Тогда
					ИсполняемыйНабор = ЮТФабрика.ОписаниеИсполняемогоНабораТестов(ТестовыйНабор, ТестовыйМодуль);
					ИсполняемыйНабор.Режим = Контекст;
					НаборыКонтекстов.Вставить(Контекст, ИсполняемыйНабор);
				Иначе
					ИсполняемыйНабор = НаборыКонтекстов[Контекст];
				КонецЕсли;
				
				ИсполняемыйТест = ЮТФабрика.ОписаниеИсполняемогоТеста(Тест, Контекст, ТестовыйМодуль);
				ИсполняемыйНабор.Тесты.Добавить(ИсполняемыйТест);
				
			КонецЦикла;
			
		КонецЦикла;
		
		Если НаборыКонтекстов.Количество() Тогда
			
			Для Каждого Элемент Из НаборыКонтекстов Цикл
				ИсполняемыеТестовыеНаборы.Добавить(Элемент.Значение);
			КонецЦикла;
			
		Иначе
			
			// TODO. Корякин А. 2021.11.24 А надо ли добавлять при отсутствии тестов
			ИсполняемыеТестовыеНаборы.Добавить(ЮТФабрика.ОписаниеИсполняемогоНабораТестов(ТестовыйНабор, ТестовыйМодуль));
			
		КонецЕсли;
		
	КонецЦикла;
	
	КонтекстыПриложения = ЮТФабрика.КонтекстыПриложения();
	КонтекстыМодуля = ЮТФабрика.КонтекстыМодуля(ТестовыйМодуль.МетаданныеМодуля);
	КонтекстыИсполнения = ЮТФабрика.КонтекстыИсполнения();
	
	Для Каждого Набор Из ИсполняемыеТестовыеНаборы Цикл
		
		КонтекстИсполнения = ЮТФабрика.КонтекстИсполнения(Набор.Режим);
		
		ОшибкаКонтекста = Неопределено;
		Если КонтекстыПриложения.Найти(Набор.Режим) = Неопределено Тогда
			ОшибкаКонтекста = "Неподдерживаемый режим запуска";
		ИначеЕсли КонтекстыМодуля.Найти(Набор.Режим) = Неопределено Тогда
			ОшибкаКонтекста = "Модуль не доступен в этом контексте";
		ИначеЕсли КонтекстИсполнения <> КонтекстыИсполнения.Сервер И КонтекстИсполнения <> КонтекстыИсполнения.Клиент Тогда
			ОшибкаКонтекста = "Неизвестный контекст/режим исполнения";
		КонецЕсли;
		
		Если ОшибкаКонтекста <> Неопределено Тогда
			Набор.Выполнять = Ложь;
			ЮТРегистрацияОшибок.ЗарегистрироватьОшибкуРежимаВыполнения(Набор, ОшибкаКонтекста);
			Для Каждого Тест Из Набор.Тесты Цикл
				ЮТРегистрацияОшибок.ЗарегистрироватьОшибкуРежимаВыполнения(Тест, ОшибкаКонтекста);
			КонецЦикла;
		КонецЕсли;
		
		Если НЕ Набор.Выполнять Тогда
			КатегорииНаборов.Пропущенные.Добавить(Набор);
			Продолжить;
		КонецЕсли;
		
		Если КонтекстИсполнения = КонтекстыИсполнения.Сервер Тогда
			
			КатегорииНаборов.Серверные.Добавить(Набор);
			
		ИначеЕсли КонтекстИсполнения = КонтекстыИсполнения.Клиент Тогда
			
			КатегорииНаборов.Клиентские.Добавить(Набор);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат КатегорииНаборов;
	
КонецФункции

Процедура ПоказатьОтчет(РезультатыТестирования, Параметры)
	
	Данные = Новый Структура("РезультатыТестирования, ПараметрыЗапуска", РезультатыТестирования, Параметры);
	АдресДанных = ПоместитьВоВременноеХранилище(Данные);
	
	ОткрытьФорму("Обработка.ЮТЮнитТесты.Форма.Основная", Новый Структура("АдресХранилища", АдресДанных));
	
КонецПроцедуры

// Записать код возврата.
// 
// Параметры:
//  РезультатыТестирования - Массив из см. ЮТФабрика.ОписаниеИсполняемогоНабораТестов
//  Параметры - см. ЮТФабрика.ПараметрыЗапуска
Процедура ЗаписатьКодВозврата(РезультатыТестирования, Параметры)
	
	Успешно = Истина;
	
	Если ПустаяСтрока(Параметры.exitCode) Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Набор Из РезультатыТестирования Цикл
		
		Если ЗначениеЗаполнено(Набор.Ошибки) Тогда
			Успешно = Ложь;
			Прервать;
		КонецЕсли;
		
		Для Каждого Тест Из Набор.Тесты Цикл
			
			Если ЗначениеЗаполнено(Тест.Ошибки) Тогда
				Успешно = Ложь;
				Прервать;
			КонецЕсли;
			
		КонецЦикла;
		
		Если НЕ Успешно Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
#Если ВебКлиент Тогда
	ВызватьИсключение ЮТОбщий.МетодНеДоступен("ЮТИсполнительКлиент.ЗаписатьКодВозврата");
#Иначе
	Запись = Новый ЗаписьТекста(Параметры.exitCode, КодировкаТекста.UTF8);
	Запись.ЗаписатьСтроку(?(Успешно, 0, 1));
	Запись.Закрыть();
#КонецЕсли

КонецПроцедуры

#КонецОбласти

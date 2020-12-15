#Использовать logos
#Использовать tempfiles
#Использовать fs

Перем ВерсияПлагина;
Перем Лог;
Перем Обработчик;
Перем КомандыПлагина;

Перем ИмяПроекта;
Перем РабочееПространство;
Перем ИмяРасширения;
Перем ИмяБазовогоПроекта;

Перем ИмяФайлаДампаКонфигурации;
Перем ИмяФайлаИзменений;

#Область Интерфейс_плагина

// Возвращает версию плагина
//
//  Возвращаемое значение:
//   Строка - текущая версия плагина
//
Функция Версия() Экспорт
	Возврат ВерсияПлагина;
КонецФункции

// Возвращает приоритет выполнения плагина
//
//  Возвращаемое значение:
//   Число - приоритет выполнения плагина
//
Функция Приоритет() Экспорт
	Возврат 0;
КонецФункции

// Возвращает описание плагина
//
//  Возвращаемое значение:
//   Строка - описание функциональности плагина
//
Функция Описание() Экспорт
	Возврат "Плагин добавляет возможность выгрузки в формате EDT."
	+ " Важно: Для работы плагина необходимы установленные EDT и Ring";
КонецФункции

// Возвращает подробную справку к плагину
//
//  Возвращаемое значение:
//   Строка - подробная справка для плагина
//
Функция Справка() Экспорт
	Возврат "Справка плагина";
КонецФункции

// Возвращает имя плагина
//
//  Возвращаемое значение:
//   Строка - имя плагина при подключении
//
Функция Имя() Экспорт
	Возврат "edtExport";
КонецФункции

// Возвращает имя лога плагина
//
//  Возвращаемое значение:
//   Строка - имя лога плагина
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.gitsync.plugins.edtExport";
КонецФункции

#КонецОбласти

#Область Подписки_на_события

Процедура ПриАктивизации(СтандартныйОбработчик) Экспорт
	
	Обработчик = СтандартныйОбработчик;
	
КонецПроцедуры

// BSLLS:UnusedParameters-off
Процедура ПередНачаломВыполнения(ПутьКХранилищу, КаталогРабочейКопии) Экспорт
	// BSLLS:UnusedParameters-on
	
	ИмяРасширения = Обработчик.ПолучитьИмяРасширения();
	
КонецПроцедуры

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации) Экспорт
	
	Лог.Отладка("Ищу команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);
	
	КлассРеализации.Опция("P project-name", "", "[*edtExport] Имя проекта")
	.ТСтрока()
	.ВОкружении("GITSYNC_PROJECT_NAME");
	
	КлассРеализации.Опция("W workspace-location", "", "[*edtExport] расположение рабочей области")
	.ТСтрока()
	.ВОкружении("GITSYNC_WORKSPACE_LOCATION");
	
	КлассРеализации.Опция(
		"B base-project-name",
		"",
		"[*edtExport] имя базового проекта в рабочей области (для расширений))")
	.ТСтрока()
	.ВОкружении("GITSYNC_BASE_PROJECT_NAME");
	
КонецПроцедуры

Процедура ПриПолученииПараметров(ПараметрыКоманды) Экспорт
	
	ИмяПроекта = ПараметрыКоманды.Параметр("project-name");
	РабочееПространство = ПараметрыКоманды.Параметр("workspace-location");
	ИмяБазовогоПроекта = ПараметрыКоманды.Параметр("base-project-name");
	
	Если Не ПустаяСтрока(ИмяРасширения)
		И Не ПустаяСтрока(ИмяБазовогоПроекта)
		И ПустаяСтрока(РабочееПространство) Тогда
		
		ВызватьИсключение "При конвертации расширений с указанием базового проекта, 
		|параметр workspace-location обязателен";
		
	КонецЕсли;
	
	Если ПустаяСтрока(ИмяПроекта) Тогда
		ВызватьИсключение "Не заполнено имя проекта";
	КонецЕсли;
	
КонецПроцедуры

// BSLLS:UnusedParameters-off
Процедура ПередПеремещениемВКаталогРабочейКопии(
		Конфигуратор,
		КаталогРабочейКопии,
		КаталогВыгрузки,
		ПутьКХранилищу,
		НомерВерсии) Экспорт
	// BSLLS:UnusedParameters-on
	
	Лог.Отладка("Начинаю выгрузку EDT");
	Лог.Отладка("Имя проекта: %1", ИмяПроекта);
	
	ПутьКФайлуИзменений = ОбъединитьПути(КаталогВыгрузки, ИмяФайлаИзменений);
	Если ФС.ФайлСуществует(ПутьКФайлуИзменений) Тогда
		
		Лог.Отладка("Используем инкрементный импорт проекта в EDT");
		
		ДополнитьИнкрементнуюВыгрузкуПроекта(Конфигуратор, КаталогВыгрузки);
		
	Иначе
		Лог.Отладка("Используем полный импорт проекта в EDT");
	КонецЕсли;
	
	ВременноеРабочееПространство = ВременныеФайлы.СоздатьКаталог();
	Если Не ПустаяСтрока(РабочееПространство) Тогда
		ФС.КопироватьСодержимоеКаталога(РабочееПространство, ВременноеРабочееПространство);
	КонецЕсли;
	
	Лог.Отладка("Рабочее пространство EDT: %1", ВременноеРабочееПространство);
	
	КаталогПроекта = ОбъединитьПути(ВременноеРабочееПространство, ИмяПроекта);
	
	Лог.Отладка("Каталог проекта EDT: %1", КаталогПроекта);
	ФС.ОбеспечитьПустойКаталог(КаталогПроекта);
	
	Команда = Новый Команда;
	
	Параметры = Новый Массив();
	Параметры.Добавить(СтрШаблон("--configuration-files ""%1""", КаталогВыгрузки));
	Параметры.Добавить(СтрШаблон("--workspace-location ""%1""", ВременноеРабочееПространство));
	Параметры.Добавить(СтрШаблон("--project ""%1""", КаталогПроекта));
	
	Если Не ПустаяСтрока(ИмяРасширения) И Не ПустаяСтрока(ИмяБазовогоПроекта) Тогда
		Параметры.Добавить(СтрШаблон("--base-project-name ""%1""", ИмяБазовогоПроекта));
	КонецЕсли;
	
	Команда.УстановитьСтрокуЗапуска("ring edt workspace import");
	Команда.УстановитьКодировкуВывода(КодировкаТекста.ANSI);
	Команда.ДобавитьЛогВыводаКоманды("oscript.lib.gitsync.plugins.edtExport");
	Команда.ДобавитьПараметры(Параметры);
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Истина);
	Команда.ПоказыватьВыводНемедленно(Ложь);
	Команда.УстановитьПравильныйКодВозврата(0);
	КодВозврата = Команда.Исполнить();
	
	Лог.Отладка("Код возврата EDT: %1", КодВозврата);
	
	ТекущийФайлВерсийМетаданных = Новый Файл(ОбъединитьПути(КаталогВыгрузки, ИмяФайлаДампаКонфигурации));
	Если ТекущийФайлВерсийМетаданных.Существует() Тогда
		
		ТекущийФайлВерсийМетаданных2 = ОбъединитьПути(КаталогПроекта, ИмяФайлаДампаКонфигурации);
		КопироватьФайл(ТекущийФайлВерсийМетаданных.ПолноеИмя,
			ТекущийФайлВерсийМетаданных2);
		
	КонецЕсли;
	
	Лог.Отладка("Очищаю каталог выгрузки");
	УдалитьФайлы(КаталогВыгрузки, "*");
	
	Лог.Отладка("Копирую каталог проекта EDT в каталог выгрузки");
	ФС.КопироватьСодержимоеКаталога(КаталогПроекта, КаталогВыгрузки);
	
КонецПроцедуры

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

Процедура ДополнитьИнкрементнуюВыгрузкуПроекта(Конфигуратор, КаталогВыгрузки)
	
	ПутьКФайлуДополнительнойВыгрузки = ВременныеФайлы.НовоеИмяФайла();
	
	СформироватьСписокДополнительныхОбъектов(КаталогВыгрузки, ПутьКФайлуДополнительнойВыгрузки);
	
	Если ФС.ФайлСуществует(ПутьКФайлуДополнительнойВыгрузки) Тогда
		
		Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
		
		Параметры.Добавить(СтрШаблон("/DumpConfigToFiles ""%1""", КаталогВыгрузки));
		Параметры.Добавить(СтрШаблон("-listFile ""%1""", ПутьКФайлуДополнительнойВыгрузки));
		
		Конфигуратор.ВыполнитьКоманду(Параметры);
		
		ВременныеФайлы.УдалитьФайл(ПутьКФайлуДополнительнойВыгрузки);
		
	КонецЕсли;
	
КонецПроцедуры

// Возращает имя родительского объекта меданных
//
// Параметры:
//   ПолноеИмяОбъекта - Строка - Полное имя объекта метаданных.
//
//  Возвращаемое значение:
//   Строка - имя родительского объекта
//
Функция РодительОбъекта(ПолноеИмяОбъекта)
	
	ЧастиИмени = СтрРазделить(ПолноеИмяОбъекта, ".");
	
	Если ЧастиИмени.Количество() > 1 Тогда
		
		ТипОбъектаМетаданных = ЧастиИмени[0];
		ИмяОбъектаМетаданных = ЧастиИмени[1];
		
	Иначе
		Возврат ПолноеИмяОбъекта;
	КонецЕсли;
	
	Если ЭтоРодительВерхнегоУровня(ТипОбъектаМетаданных) Тогда
		Возврат ТипОбъектаМетаданных;
	Иначе
		Возврат СтрШаблон("%1.%2", ТипОбъектаМетаданных, ИмяОбъектаМетаданных);
	КонецЕсли;
	
КонецФункции

Функция ЭтоВложенныйОбъект(ПолноеИмяОбъекта)
	
	ИндексВложенногоТипа = 2;

	ЧастиИмени = СтрРазделить(ПолноеИмяОбъекта, ".");
	Если ЧастиИмени.Количество() > ИндексВложенногоТипа Тогда
		ТипВложенногоОбъекта = ЧастиИмени[ИндексВложенногоТипа];
	Иначе
		Возврат Ложь;
	КонецЕсли;

	Возврат (СтрНайти("Form,Template,Recalculation,Subsystem", ТипВложенногоОбъекта) > 0);

КонецФункции

Функция ЭтоРодительВерхнегоУровня(Родитель)
	
	Возврат (СтрНайти("Configuration,Language", Родитель) > 0);

КонецФункции

Функция ИзмененныеОбъектыМетаданных(ПутьКФайлуИзменений)
	
	РегулярноеВыражение = Новый РегулярноеВыражение("^(?>New|Modified):(\S+)\s*$");
	
	ЧтениеФайла = Новый ЧтениеТекста(ПутьКФайлуИзменений);
	Совпадения = РегулярноеВыражение.НайтиСовпадения(ЧтениеФайла.Прочитать());
	ЧтениеФайла.Закрыть();
	
	ИзмененныеОбъекты = Новый Соответствие;
	ИзмененныеОбъекты.Вставить("Configuration", Новый Массив);
	ИзмененныеОбъекты.Вставить("Language", Новый Массив);
	
	Для Каждого Совпадение Из Совпадения Цикл
		
		ИмяОбъектаМетаданных = Совпадение.Группы[1].Значение;
		Родитель = РодительОбъекта(ИмяОбъектаМетаданных);
		
		ПодчиненныеОбъекты = ИзмененныеОбъекты.Получить(Родитель);
		Если ПодчиненныеОбъекты = Неопределено Тогда
			ПодчиненныеОбъекты = Новый Массив;
			ИзмененныеОбъекты.Вставить(Родитель, ПодчиненныеОбъекты);
		КонецЕсли;
		
		ПодчиненныеОбъекты.Добавить(ИмяОбъектаМетаданных);
		
	КонецЦикла;
	
	Возврат ИзмененныеОбъекты;
	
КонецФункции

Функция ДополнительныеОбъектыКВыгрузке(ИзмененныеОбъекты, ПутьКФайлуВерсийМетаданных)
	
	СписокОбъектов = Новый Массив;
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ПутьКФайлуВерсийМетаданных);

	ЧтениеXML.ПерейтиКСодержимому(); // ConfigDumpInfo
	ЧтениеXML.Прочитать(); // ConfigVersions
	ЧтениеXML.Прочитать(); // Metadata

	Пока ЧтениеXML.Имя = "Metadata" Цикл

		ИмяОбъекта = ЧтениеXML.ЗначениеАтрибута("name");
		Родитель = РодительОбъекта(ИмяОбъекта);

		Если ЭтоВложенныйОбъект(ИмяОбъекта) 
			ИЛИ ИмяОбъекта = Родитель
			ИЛИ ЭтоРодительВерхнегоУровня(Родитель) Тогда

			Изменения = ИзмененныеОбъекты.Получить(Родитель);
			Если Изменения <> Неопределено И Изменения.Найти(ИмяОбъекта) = Неопределено	Тогда
				СписокОбъектов.Добавить(ИмяОбъекта);
			КонецЕсли;

		КонецЕсли;

		ЧтениеXML.Пропустить();
		ЧтениеXML.Прочитать();

	КонецЦикла;
	
	ЧтениеXML.Закрыть();
	
	Возврат СписокОбъектов;
	
КонецФункции

Процедура СформироватьСписокДополнительныхОбъектов(КаталогВыгрузки, ПутьКФайлуДополнительнойВыгрузки)
	
	ПутьКФайлуИзменений = ОбъединитьПути(КаталогВыгрузки, ИмяФайлаИзменений);
	ПутьКФайлуВерсийМетаданных = ОбъединитьПути(КаталогВыгрузки, ИмяФайлаДампаКонфигурации);
	
	ИзмененныеОбъекты = ИзмененныеОбъектыМетаданных(ПутьКФайлуИзменений);
	ДополнительныеОбъектыКВыгрузке = ДополнительныеОбъектыКВыгрузке(ИзмененныеОбъекты, ПутьКФайлуВерсийМетаданных);
	
	Если ДополнительныеОбъектыКВыгрузке.Количество() > 0 Тогда
		
		ФайлОбъектовВыгрузки = Новый ТекстовыйДокумент();
		Для Каждого ДополнительныйОбъект Из ДополнительныеОбъектыКВыгрузке Цикл
			ФайлОбъектовВыгрузки.ДобавитьСтроку(ДополнительныйОбъект);
		КонецЦикла;
		ФайлОбъектовВыгрузки.Записать(ПутьКФайлуДополнительнойВыгрузки, КодировкаТекста.UTF8);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура Инициализация()
	
	ВерсияПлагина = "1.3.0";
	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");
	
	ИмяРасширения = "";
	РабочееПространство = "";
	ИмяБазовогоПроекта = "";
	
	ИмяФайлаДампаКонфигурации = "ConfigDumpInfo.xml";
	ИмяФайлаИзменений = "dumplist.txt";
	
КонецПроцедуры

#КонецОбласти

Инициализация();
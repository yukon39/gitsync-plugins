#Область ПрограммныйИнтерфейс

Функция ПолучитьПутьКФайлу(Знач ИмяФайла) Экспорт

	МенеджерЗапакованныхФайлов = Новый МенеджерЗапакованныхФайловGitsyncPlugins;
	ИндексФайлов = МенеджерЗапакованныхФайлов.ПолучитьИндексФайлов();

	ИмяКлассаФайла = ИндексФайлов[ИмяФайла];

	Если ИмяКлассаФайла = Неопределено Тогда
		ВызватьИсключение СтрШаблон("Не удалось найти двоичные данные для файла <%1>", ИмяФайла);
	КонецЕсли;

	КлассФайла = Новый (ИмяКлассаФайла);

	ПутьКФайлу = "";

	НайтиФайлИлиРаспаковать(КлассФайла, ПутьКФайлу);

	Возврат ПутьКФайлу;

КонецФункции

#КонецОбласти

#Область Упакованные_файлы

Процедура РаспаковатьДанные(Знач ПутьКФайлу, КлассФайла)

	ДвоичныеДанные = Base64Значение(КлассФайла.ДвоичныеДанные());

	ОбеспечитьКаталог(ПутьКФайлу);

	ДвоичныеДанные.Записать(ПутьКФайлу);

КонецПроцедуры

Функция ВычислитьХешФайла(Знач ПутьКФайлу)

	ХешФайла = Новый ХешированиеДанных(ХешФункция.MD5);
	ХешФайла.ДобавитьФайл(ПутьКФайлу);

 	Возврат ХешФайла.ХешСуммаСтрокой;

КонецФункции

Процедура НайтиФайлИлиРаспаковать(КлассФайла, ПутьКФайлу)

	ИмяФайла = КлассФайла.ИмяФайла();

	ПутьКФайлу = ПолучитьПутьКВременномуФайлу(ИмяФайла);

	ВременныйФайл = Новый Файл(ПутьКФайлу);

	Если Не ВременныйФайл.Существует()
		Тогда// ИЛИ Не ВычислитьХешФайла(ПутьКФайлу) = ДанныеDll.Хеш() Тогда
		РаспаковатьДанные(ПутьКФайлу, КлассФайла);
	КонецЕсли;

КонецПроцедуры

Функция ПолучитьПутьКВременномуФайлу(Знач ИмяФайла)
	ПутьКФайлу = ОбъединитьПути(КаталогВременныхФайлов(), ".gitsync-plugins", ИмяФайла);
	Возврат ПутьКФайлу;
КонецФункции

Процедура ОбеспечитьКаталог(ПутьККаталогу)

	ВременныйКаталог = Новый Файл(ПутьККаталогу);

	Если ВременныйКаталог.Существует() Тогда
		Возврат;
	КонецЕсли;

	СоздатьКаталог(ВременныйКаталог.Путь);

КонецПроцедуры

#КонецОбласти

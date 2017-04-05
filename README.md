# Kubik #

**Может быть, когда-нибудь...**

Если вы просто хотели скачать поинт-комплект Кубик, а вместо этого попали сюда? [Не отчаиваемся, вот то что вам нужно.](http://kubik-fido.blogspot.com)

Исходники текущей версии находятся в [ветке '3.0.92'](https://bitbucket.org/ragweed/kubik/branch/3.0.92)

**А чем master-ветка отличается от '3.0.92'?**
```
GoldED: 			Изменил префикс для цитат (QuoteString " FML> ")
Kubik Start: 		Возможность свернуть лаунчер в трей
Kubik Send: 		Поддержка параметра запуска "--auto_send"
Kubik Start: 		Добавлена автоматическая проверка почты по таймеру
Kubik Start: 		Добавлены всплывающие уведомления о новой почте
Kubik Start:		Добавлены горячие клавиши на основные функции лаунчера
GoldED: 			Вернул классическую чёрную тему (закомментировал Include на gedcol11.cfg)
Kubik Start:    	Отвязал Kubik Start от Kubik_Include_CFGS.pb
Kubik Start:    	Завершил рефакторинг Kubik Start
Kubik Start:    	Опция: уведомлять обо всех сообщениях или только о сообщениях в нетмейл или карбонке
Kubik Start:    	Заменить текст в уведомлении на что-нибудь более осмысленное: "Новых непрочитанных сообщений"
Kubik Start:		Опция: запускать свёрнутым в трей
Kubik Start:    	Опция: закрывать в трей
Kubik Start:    	Возможность отключить обрезку вывода KSend перед анализом лога HTP (CropLog в группе [Send])
Kubik Start:    	Вернул поиск скина в extensions/skins/
Kubik:          	Удалил мусор вида *.cfg и *.xml (их не должно быть сразу в свежеустановленном поинт-комплекте, появляются они только после завершения работы автоконфигуратора)
GoldED:         	Включил проверку орфографии
Kubik Start:    	Новый скин по-умолчанию "riseup"
Kubik SSetting: 	Полный рефакторинг кода
Kubik SSetting: 	Добавил консольный режим, запускаемый ключом --auto-setting (для организации обновления с 3.0.92.x до 3.1.x)
Kubik SSetting: 	Изменились переменные в шаблонах 'templates\', заодно исправил отсутствующую переменную для названия поинт-станции
Kubik SSetting: 	Теперь набор шаблонов не зашит в коде, а и основывается на соотношении информации из 'templates\Config_List.ini' и шаблонов из директории 'templates\'
Kubik SSetting: 	Создание (если отсутствует) папки 'fido\'
Kubik SSetting: 	Создание (если отсутствует) конфига Kubik_Set.ini
Kubik SSetting: 	Отвязал от Kubik_Include_CFGS.pb
Kubik Installer: 	Полный рефакторинг кода
Kubik SSetting: 	Перенос описания арий из backup-*\husky\husky.cfg
Kubik SSetting: 	Переменная %KUBIK_VERSION% и константа #Kubik_Version
Kubik Installer: 	Добавил обнаружение Kubik 3.0.92 с предложением обновить его
Kubik Installer: 	Создание папки backup-*/, перенос туда файлов обновляемого поинт-комплекта и запуск Kubik SSetting -a
Kubik Installer: 	Блокировать установку в уже существующий поинт-комлект
Kubik SSetting: 	Внесены правки в шаблоны
Kubik SSetting: 	При перенастройке поинт-комплекта список арий в husky.cfg сохраняется
SSetting&Installer: Создан механизм обновления с 3.0.x до 3.1.x
Kubik Send: 		Рефакторинг, отвязал от Kubik_Include_CFGS.pb
Kubik Send: 		Отказываемся от xml в пользу конфига
Kubik Params: 		Рефакторинг, отвязал от Kubik_Include_CFGS.pb
Kubik: 				Удалён Kubik_Include_CFGS.pb
Kubik SSetting:  	Исправил: не создавался конфиг из шаблона, если не был указан путь для будущего конфига (создать конфиг в той директории, где выполняется приложение)
Kubik SSetting: 	Обновил шаблон для ge.bat
Kubik SSetting: 	Создал шаблон для Kubik_Send.ini
Kubik SSetting:  	Кнопка "Справка" открывает конретную статью
GoldED: 			Заменён на GoldED+1.1.5 Win32-MSVC  2016 Dec 21 [Compiled using MS Visual C++] 
```
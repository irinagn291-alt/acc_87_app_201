# План проекта Slice Book

## Исходные параметры

- Папка проекта: `app_201`
- Название приложения: `Slice Book`
- Bundle identifier: `app.SliceBook.ios`
- Display name: `Slice Book`
- Платформа: iOS 16+, SwiftUI, SwiftData, URLSession
- Сторонние пакеты: не использовать OneSignal, Alamofire, AppsFlyer и любые новые package-зависимости
- Референс функциональности: `/Users/belzephyrus/Documents/gambling/book_69/app_267`

## Концепция

- Стиль: Минималистичный голубой productivity-хаб
- Палитра: Primary #1E88E5, Secondary #81D4FA, Background #F2FAFF, Accent #00B8D9, Text #0A2540
- Онбординг: Управляйте чтением из одного спокойного пространства.
- Основная задача UI: приложение должно выглядеть как самостоятельный продукт, а не как перекрашенный BookMood.

## Уникальная структура кода

Запланировать структуру без копирования имен из референса:

```text
Slice Book (target app_201)/
  Application/
    PilotShell.swift
    AquaRouteTabs.swift
  Design/
    PilotBlueKit.swift
    AquaBookCard.swift
  Features/
    Onboarding/CalmLaunchCarousel.swift
    Discovery/PilotSearchDeck.swift
    Scanner/AquaISBNScannerView.swift
    Library/
    Details/
    Progress/
    Notes/
    Weekly/WeekFlightPlanView.swift
    Insights/
    Settings/
  Data/
    OpenLibrary/
    LocalStore/
  Domain/
    Models/
    Services/
```

Имена можно уточнять при реализации, но они не должны совпадать с `BookMood`, `BookNest`, `SearchView`, `LibraryView`, `OnboardingView`, `AppDependencies` и другими именами референса.

## Функциональность к переносу

- Поиск книг через OpenLibrary по названию и произвольному запросу.
- Поиск по ISBN через OpenLibrary `q=` после нормализации кода.
- Просмотр OpenLibrary work detail, авторов, года, subjects и описания.
- Загрузка обложек через `https://covers.openlibrary.org`.
- Локальная библиотека SwiftData со статусами `wantToRead`, `reading`, `finished`, `paused`.
- Добавление книги из поиска/подборки в библиотеку.
- Редактирование статуса, рейтинга, заметки и прогресса чтения.
- История прогресса по страницам.
- Подборки по жанрам/настроению через OpenLibrary subjects.
- Статистика: количество книг, статусы, завершенные книги, прогресс.
- Настройки: сброс onboarding, режим отображения библиотеки, локальная очистка данных.
- Недельный список будущего чтения: экран `WeekFlightPlanView` с планом на 7 дней, добавлением книг из библиотеки/поиска, переносом между днями и локальным сохранением.

## Обязательный ISBN-сканер

Реализовать сканер `AquaISBNScannerView` без сторонних пакетов:

- использовать `AVFoundation` и `UIViewControllerRepresentable`;
- распознавать `ean13`, `ean8`, `upce`, если устройство поддерживает;
- при запуске в симуляторе показывать понятное сообщение, что камера нужна на устройстве;
- после сканирования нормализовать ISBN и запускать поиск OpenLibrary;
- добавить ключ `NSCameraUsageDescription` в настройки проекта;
- предусмотреть отказ в доступе к камере и пустое состояние.

## Экраны

- `CalmLaunchCarousel`: 2-4 уникальных onboarding-экрана, собственные тексты, пагинация и кнопки.
- `PilotShell`: root-сцена, решает показывать onboarding или приложение.
- `AquaRouteTabs`: уникальная навигация по основным разделам.
- `PilotSearchDeck`: поиск книг, состояния loading/empty/error/offline, переход в детали.
- Детали книги: hero-секция в фирменном стиле приложения, добавление в библиотеку, описание и subjects.
- Библиотека: фильтры по статусам, поиск по своей полке, сортировка, удаление.
- Прогресс: ввод страниц, журнал событий, визуальный progress indicator.
- Заметки: рейтинг и текстовая заметка.
- Mood/subject подборки: подборки через OpenLibrary subjects и сохранение списков.
- `WeekFlightPlanView`: недельный список будущего чтения.
- Insights: статистика и агрегаты локальной библиотеки.
- Settings: локальные настройки без web gate, push, attribution SDK.

## Дизайн-система

Создать `PilotBlueKit` с собственными токенами:

- цвета из палитры проекта;
- фон, surface, card, border, primary text, secondary text, error/success;
- кнопка primary/secondary;
- карточка `AquaBookCard`;
- empty state component;
- поля ввода;
- chip/status badge;
- navigation/tab styling;
- аккуратные анимации в духе концепции проекта.

## План реализации

1. Обновить Xcode project metadata: display name `Slice Book`, bundle id `app.SliceBook.ios`, camera usage description.
2. Заменить стартовые `ContentView.swift` и `app_201App.swift` на уникальную структуру приложения.
3. Добавить SwiftData модели для настроек, книг, прогресса, mood lists и недельного плана.
4. Добавить OpenLibrary data layer на `URLSession`, без Alamofire.
5. Реализовать onboarding и сохранение `hasCompletedOnboarding`.
6. Реализовать поиск, ISBN-сканер, детали книги и добавление в библиотеку.
7. Реализовать библиотеку, прогресс, заметки, статистику и настройки.
8. Реализовать `WeekFlightPlanView` для будущего чтения на неделю.
9. Уникализировать UI, тексты, компоненты, имена файлов и анимации.
10. Собрать проект и проверить основные сценарии на разных размерах iPhone.

## Проверка готовности

- Проект собирается без ошибок.
- Bundle id равен `app.SliceBook.ios`.
- В проекте нет OneSignal, Alamofire, AppsFlyer.
- ISBN-сканер есть и подключен к поиску.
- OpenLibrary работает через `URLSession`.
- Данные сохраняются локально через SwiftData.
- Недельный список чтения сохраняется после перезапуска.
- UI и тексты не совпадают с остальными 19 проектами и референсом.

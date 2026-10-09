<div dir="rtl">

# 📘 الدليل المعماري الشامل لبناء الميزات (Clean Architecture Master Playbook)
> **المرجع الشامل لكل حالات التطوير في Flutter (BLoC / Cubit + GetIt)**
> مصمم ليكون شجرة قرارات ومفاهيم واضحة (لو كذا ... إذن كذا) تغنيك عن أي مصدر خارجي.

---

## 📑 الفهرس السريع
1. [المسار الأول: إنشاء Feature جديدة بالكامل من الصفر](#1-المسار-الأول-إنشاء-feature-جديدة-بالكامل-من-الصفر)
2. [المسار الثاني: إضافة Action / زر جديد داخل Feature موجودة مسبقاً](#2-المسار-الثاني-إضافة-action--زر-جديد-داخل-feature-موجودة-مسبقاً)
3. [دليل التعامل مع أنواع البيانات المختلفة (Response Scenarios)](#3-دليل-التعامل-مع-أنواع-البيانات-المختلفة-response-scenarios)
4. [مسار الـ Offline-First (كاش محلي + سيرفر معاً)](#4-مسار-الـ-offline-first-كاش-محلي--سيرفر-معاً)
5. [شجرة القرارات والقواعد المعمارية الصارمة (Decision Tree)](#5-شجرة-القرارات-والقواعد-المعمارية-الصارمة-decision-tree)

---

## 1. المسار الأول: إنشاء Feature جديدة بالكامل من الصفر

تُطبق هذه الخطوات فقط عند إضافة ميزة جديدة تماماً لم تكن موجودة في المشروع (مثل إضافة ميزة `bag` أو `orders` أو `notifications`).

```
lib/features/{feature_name}/
├── data/
│   ├── data_sources/      ← Remote / Mock / Local Data Sources
│   ├── models/            ← JSON Deserialization (يمتد من Entity)
│   └── repositories/      ← تطبيق الـ Interface وتحويل Exceptions إلى Failures
├── domain/
│   ├── entities/          ← كائنات بيزنس نقية (Pure Dart)
│   ├── repositories/      ← عقد الواجهة التجريدي (Abstract Contract)
│   └── use_cases/         ← فئات صغيرة، كل فئة تؤدي وظيفة واحدة
└── presentation/
    ├── cubit/             ← منطق إدارة الحالة (Logic + States)
    ├── pages/             ← شاشات العرض الكاملة (Views)
    └── widgets/           ← مكونات الواجهة المقتطعة الفرعية
```

### 🔁 الخطوات الـ 8 بالتسلسل الإلزامي:

| # | الطبقة | ما تفعله بالضبط | القاعدة الذهبية |
|---|---|---|---|
| **1** | **Data Source** | إنشاء ملف `abstract` يحدد العمليات، ثم تطبيق `RemoteDataSourceImpl` مع `MockDataSourceImpl` لاختبار الـ Offline. | استخدام `EndPoint.xxx` و `ApiKey.xxx` دائماً وتجنب الـ Strings المباشرة. |
| **2** | **Model** | إنشاء `Model` يرث من الـ `Entity`، يحتوي فقط على `fromJson` لتحويل الـ Map القادمة من السيرفر. | إذا كان الـ Endpoint لا يرجع بيانات (مجرد تأكيد نجاح)، **لا تنشئ Model**. |
| **3** | **Entity** | إنشاء كائن Dart نقي يرث من `Equatable` يمثل البيانات المطلوبة في واجهة المستخدم فقط. | لا تضع أي دوال JSON أو استيراد لمكتبات خارجية أو Flutter داخل الـ Entity. |
| **4** | **Repository** | 1. تعريف `Abstract Repository` في الـ `domain` يرجع `Future<Either<Failure, T>>`.<br>2. تطبيق `RepositoryImpl` في الـ `data` لاصطياد الـ `Exceptions` وتحويلها لـ `Failures`. | هذا هو المكان الوحيد في التطبيق المسموح فيه بـ `try/catch` للـ Network Exceptions. |
| **5** | **UseCase** | إنشاء Class لكل عملية بمفردها يحتوي على دالة `call()`. | مسؤولية واحدة لكل UseCase (Single Responsibility). |
| **6** | **Service Locator (DI)** | تسجيل العناصر في `services_locator.dart`: الـ DataSource والـ Repository والـ UseCase كـ `LazySingleton`، والـ Cubit كـ `Factory`. | نسجل دائماً بالنوع التجريدي: `registerLazySingleton<RepoInterface>(() => RepoImpl(...))`. |
| **7** | **Cubit & States** | إنشاء `State` بصيغة `sealed class` تشمل (Initial, Loading, Success/Loaded, Failure). والـ Cubit يستدعي الـ UseCase فقط ويُطلق (emits) الحالات. | ممنوع تماماً وجود `BuildContext`، Navigation، أو SnackBar داخل الـ Cubit. |
| **8** | **UI & Router** | 1. ربط المسار في `app_router.dart` وتوفير الـ Cubit عبر `BlocProvider`.<br>2. كتابة الـ View مع `BlocConsumer` (الـ Listener للـ SnackBar والـ Navigation، والـ Builder للرسم). | الـ UI لا يستدعي UseCase أو Repository مباشرة، يتعامل فقط مع `context.read<Cubit>()`. |

---

## 2. المسار الثاني: إضافة Action / زر جديد داخل Feature موجودة مسبقاً

> 💡 **مثال واقعي:** ميزة الـ `auth` موجودة بالفعل، وتريد إضافة عملية **"نسيت كلمة المرور"** أو **"تغيير الصورة الشخصية"**.

هنا لا نبني مجلدات جديدة ولا نعيد كتابة الكود القائم! إليك جدول ما نعدله وما ننشئه:

### 📋 مصفوفة التعديل والإضافة:

| الملف المستهدف | الإجراء المطلوب | هل ننشئ ملفاً جديداً أم نعدل قائماً؟ |
|---|---|---|
| `data_sources/{f}_remote_data_source.dart` | إضافة دالة الـ Contract الجديدة فقط. | **تعديل** على الملف القائم. |
| `data_sources/{f}_remote_data_source_impl.dart` | كتابة استدعاء الـ API الجديد. | **تعديل** على الملف القائم. |
| `data_sources/{f}_mock_remote_data_source_impl.dart` | محاكاة الاستجابة لاختبار الـ Offline. | **تعديل** على الملف القائم. |
| `models/` & `entities/` | **إنشاء ملفات جديدة فقط** إذا كانت العملية ترجع نوع بيانات جديد مختلف كلياً. أما إذا كانت ترجع نفس البيانات القديمة أو لا ترجع داتا، **لا تنشئ شيئاً**. | **حسب نوع البيانات**. |
| `domain/repositories/{f}_repository.dart` | إضافة دالة الـ Contract للعملية الجديدة. | **تعديل** على الملف القائم. |
| `data/repositories/{f}_repository_impl.dart` | تطبيق الدالة وتغليفها بـ `try/catch` لتحويل الـ Exceptions. | **تعديل** على الملف القائم. |
| `domain/use_cases/` | إنشاء UseCase مخصص ومستقل للعملية الجديدة (مثل `ForgotPasswordUseCase`). | **ملف جديد** دائماً. |
| `services_locator.dart` | تسجيل الـ UseCase الجديد والـ Cubit (إن وجد). | **تعديل** على الملف القائم. |
| `cubit/` | راجع [قاعدة اختيار الـ Cubit](#1-قرار-الـ-cubit-cubit-جديد-أم-دالة-في-الـ-cubit-القديم) لتحديد هل تضيف دالة في نفس الـ Cubit أم تنشئ Cubit منفصل. | **حسب شجرة القرارات**. |
| `presentation/pages/` | إنشاء شاشة جديدة للـ Action إن كانت تتطلب واجهة مستقلة، أو زر جديد في الواجهة الحالية. | **حسب التصميم**. |

---

## 3. دليل التعامل مع أنواع البيانات المختلفة (Response Scenarios)

### 🟢 الحالة الأولى: عمليات بدون بيانات راجعة (Action-Only / Void)
> **أمثلة:** Forgot Password، Logout، Delete Item، Change Password، Like Post.

- **الـ DataSource:** ترجع `Future<void>`.
- **الـ Model:** ❌ **لا يوجد Model نهائياً**.
- **الـ Entity:** ❌ **لا يوجد Entity نهائياً**.
- **الـ Repository:** يرجع `Future<Either<Failure, Unit>>` (نستخدم `unit` من مكتبة `dartz` لتمثيل النجاح الفارغ).
- **الـ UseCase:** يرجع `Future<Either<Failure, Unit>>`.
- **الـ Cubit State:** تكون حالة النجاح فارغة: `final class ActionSuccess extends MyState {}`.

---

### 🔵 الحالة الثانية: كائن مفرد (Single Object)
> **أمثلة:** User Profile، Product Details، Cart Details، Order Summary.

- **الـ Entity:** كائن يمثل البيانات المطلوبة في الـ UI فقط (`UserEntity`).
- **الـ Model:** يرث من الـ Entity ويحتوي على `fromJson` فقط (`UserModel extends UserEntity`).
- **الـ DataSource:** يرجع الـ Model (`Future<UserModel>`).
- **الـ Repository:** يرجع الـ Entity (`Future<Either<Failure, UserEntity>>`).
- **الـ Cubit State:** تحمل الـ Entity داخلها:
  ```dart
  final class UserLoaded extends UserState {
    const UserLoaded({required this.user});
    final UserEntity user;
  }
  ```

---

### 🟣 الحالة الثالثة: قائمة بيانات مع تحميل تدريجي (List & Pagination)
> **أمثلة:** قائمة المنتجات، الإشعارات، سجل المعاملات، نتائج البحث.

- **الـ Entity:** يمثل العنصر الواحد في القائمة (`ProductEntity`).
- **الـ Model:** يمثل العنصر الواحد وتحويله من JSON (`ProductModel extends ProductEntity`).
- **الـ DataSource:** ترجع `Future<List<ProductModel>>` وتأخذ معاملات الترقيم:
  ```dart
  Future<List<ProductModel>> getProducts({required int page, required int limit});
  ```
- **الـ Repository & UseCase:** يرجعان `Future<Either<Failure, List<ProductEntity>>>`.
- **الـ Cubit & State (إدارة الـ Pagination):**
  - **الـ State:** يجب أن تحتفظ بالقائمة الحالية وعلم لمعرفة هل انتهت البيانات:
    ```dart
    final class ProductsLoaded extends ProductsState {
      const ProductsLoaded({
        required this.products,
        this.hasReachedMax = false,
        this.isLoadingMore = false,
      });
      final List<ProductEntity> products;
      final bool hasReachedMax;
      final bool isLoadingMore;
    }
    ```
  - **الـ Cubit Logic:** عند طلب الصفحة التالية، لا نحذف القديم بل ندمجه:
    ```dart
    final currentProducts = (state as ProductsLoaded).products;
    emit(ProductsLoaded(products: currentProducts, isLoadingMore: true));
    final result = await getProductsUseCase(page: nextPage);
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (newProducts) {
        emit(ProductsLoaded(
          products: currentProducts + newProducts,
          hasReachedMax: newProducts.isEmpty,
          isLoadingMore: false,
        ));
      },
    );
    ```

---

## 4. مسار الـ Offline-First (كاش محلي + سيرفر معاً)

عندما يتطلب التطبيق العمل في وضع عدم الاتصال وتخزين البيانات محلياً:

```
[UI / View]
     ↓ (طلب البيانات)
[Cubit]
     ↓
[UseCase]
     ↓
[RepositoryImpl] ────→ 1. قراءة الكاش أولاً (LocalDataSource) ──→ إرجاع الكاش للعرض فوراً
     │
     └──→ 2. طلب السيرفر في الخلفية (RemoteDataSource)
               ↓
          3. نجح؟ ──→ تحديث الكاش المحلي (LocalDataSource.save)
               ↓
          4. إرجاع البيانات الأحدث للـ UI
```

### 🛠️ قواعد تنفيذ الـ Offline-First:

1. **وجود اثنين DataSources:**
   - `RemoteDataSource`: يتصل بـ DioConsumer.
   - `LocalDataSource`: يتصل بـ SharedPreferencesService أو Hive/Isar.
2. **الـ Repository هو المنسق الذكي (Orchestrator):**
   - الـ UseCase والـ Cubit لا يعلمان من أين تأتي البيانات.
   - إذا كان الجهاز غير متصل بالإنترنت (`NetworkInfo.isConnected == false`): يقرأ الـ Repository من `LocalDataSource` مباشرة.
   - إذا كان الكاش فارغاً والجهاز أوفلاين: يرجع `left(EmptyCacheFailure())`.
   - عند توفر الإنترنت: يجلب من السيرفر، يحدّث الكاش المحلي، ثم يرجع النتيجة للـ Domain.

---

## 5. شجرة القرارات والقواعد المعمارية الصارمة (Decision Tree)

---

### 1️⃣ قرار الـ Cubit: (Cubit جديد أم دالة في الـ Cubit القديم؟)

| الحالة | القرار | السبب المعماري |
|---|---|---|
| **شاشة مستقلة تماماً بدورة حياة منفصلة** (مثل صفحة Forgot Password مقارنة بـ Login). | **Cubit مستقل وجديد** | حتى لا تظل حالات الشاشة القديمة معلقة في الذاكرة، ولمنع تداخل الـ Loading والـ Error بين الشاشات. |
| **عملية فرعية داخل نفس الشاشة** (مثل الضغط على زر "تفعيل الحساب" أو "تبديل اللغة" في نفس الإعدادات). | **دالة داخل نفس الـ Cubit** | الشاشة تعرض نفس السياق وتتشارك دورة الحياة ذاتها. |
| **ميزة يتم فتحها في BottomSheet أو Dialog مؤقت.** | **Cubit مستقل بـ Scope مخصص** | حتى يُنشأ الكيوبت عند فتح الـ Dialog ويُغلق (Dispose) فور إغلاقه. |

---

### 2️⃣ تنظيم مدخلات الـ API (الـ Parameters):

* **لو المعاملات 1 أو 2 فقط** (مثل `id`، `email`):
  ← مررها كـ **Named Parameters** عادية في الدوال:
  ```dart
  Future<void> call({required String email});
  ```
* **لو المعاملات 3 أو أكثر** (مثل تسجيل حساب جديد: الاسم، الإيميل، الباسورد، الهاتف، المدينة...):
  ← اجمعها في **Class مخصص للبيانات (Params / RequestModel)** في الـ Domain:
  ```dart
  class RegisterParams extends Equatable {
    const RegisterParams({required this.email, required this.password, ...});
  }
  ```
  > **الفائدة:** لو طلب الباك إند إضافة حقل جديد مستقبلاً، تعدل الـ Class فقط بدون كسر واجهات الدوال في كل الطبقات.

---

### 3️⃣ مكان التحقق من صحة البيانات (Validation):

```
أين تضع كود التحقق من المدخلات؟
 │
 ├── 1. في واجهة المستخدم (UI / FormKey / validator):
 │    └── للتحقق اللحظي والشكل (هل الإيميل يحتوي على @؟ هل الباسورد أطول من 8 خانات؟ هل الحقل فارغ؟).
 │
 ├── 2. في الـ Cubit / Bloc:
 │    └── لتحقق الحالة التفاعلية (مثل تفعيل/تعطيل زر الإرسال بناءً على صحة جميع الحقول معاً).
 │
 └── 3. في الـ Domain / UseCase (أو Entity):
      └── لقواعد البيزنس الصارمة المستقلة عن الواجهة (مثل: "لا يمكن سحب رصيد أكبر من المتاح"، أو "عمر المستخدم يجب أن يتجاوز 18 سنة").
```

---

## 🛑 جدول المحظورات الذي لا يُكسر (Never Violate)

| ❌ محظور تماماً | ✅ البديل الصحيح |
|---|---|
| استدعاء `getIt<Cubit>()` داخل شجرة الـ Widgets. | توفير الكيوبت عبر `BlocProvider` في الراوتر والوصول له بـ `context.read<Cubit>()`. |
| استدعاء الـ `UseCase` أو `Repository` مباشرة من واجهة المستخدم. | التعامل عبر الـ `Cubit` فقط. |
| وضع `BuildContext` أو `Navigator` أو `SnackBar` داخل الـ Cubit. | إطلاق State في الكيوبت، والتعامل مع الـ Navigation والـ SnackBar في `BlocListener` / `BlocConsumer`. |
| استخدام نصوص برمجية صلبة للروابط ومفاتيح الـ JSON (Hardcoding). | استخدام `EndPoint.xxx` و `ApiKey.xxx` المركزية. |
| تسجيل الـ Cubit كـ `LazySingleton`. | تسجيل الـ Cubits دائماً كـ `registerFactory`. |
| استخدام المسارات النسبية (Relative imports مثل `../../`). | استخدام Package Imports فقط (`package:MatchIn/...`). |
| استخدام دوال `print(...)`. | تجنب الطباعة أو استخدام أدوات اللوج المخصصة. |

</div>

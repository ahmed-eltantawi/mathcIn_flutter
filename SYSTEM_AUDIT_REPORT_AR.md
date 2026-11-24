# تقرير فحص MatchIn: Flutter + Backend + AI

تاريخ الفحص: 6 نوفمبر 2026

## نطاق الفحص وحدوده

فُهرست شجرة Flutter في `D:\projects\mathcIn_flutter`، ومجلدا `Backend` و`AI-Serv5` في `D:\projects\Matchin ALL`. مجلد `Matchin ALL` نفسه يحتوي Backend وAI ولا يحتوي Flutter؛ لذلك اعتُمد مشروع Flutter المفتوح في IDE كالتطبيق المرتبط بهما. جرى تتبع إعداد الاتصال، الشبكة، نقاط API، نماذج/خدمات المحادثة والسيرة الذاتية والوظائف والخطط، وربط Laravel بخدمات FastAPI ومخططاته. لم تُفحص الملفات المولدة أو الاعتماديات المنزلة أو ملفات الصور/الخطوط بايتاً بايتاً؛ فحصها لا يضيف تحققاً لمسار البيانات.

لا توجد ملفات `.env` تشغيلية في Backend أو AI-Serv5؛ الموجود فقط `.env.example` و`.env.staging.example`. لذلك لا يمكن الجزم بقيم مفاتيح التشغيل الفعلية أو إعدادات LLM على الخوادم. يوجد إعداد Firebase أصلي في Android وiOS، ويجلب التطبيق عنوان API من Firestore.

## ملخص تدفق البيانات الحالي

1. Flutter يمرر كل الطلبات عبر Dio و`ApiInterceptor` إلى عنوان API. عنوان البداية ثابت داخل `EndPoint.baseUrl`، ثم يحاول التطبيق تحديثه من Firestore.
2. Laravel يوفّر مصادر الوظائف والملفات الشخصية والمحفوظات والخطط، ويستدعي AI داخلياً عبر `FastApiAiClient` باستخدام JSON أو multipart، ورأس `X-API-Key` عند ضبط مفتاح.
3. FastAPI يوفّر استخراج CV وتحليل الوظائف والمطابقة والخطط والمقابلات والمرشد. تتفق بنيتا طلب المطابقة وردها عموماً بين `JobMatchingService` و`SkillGapAnalysisRequest/Response`، كما يتفق رفع الملف الداخلي على `file` و`candidate_id` مع endpoint `/api/v1/cv/extract-file`.
4. التكامل لا يكتمل في عدد من ميزات Flutter: رفع CV العادي لا يصل إلى خدمة AI، وواجهة المرشد لا يمررها Laravel إلى AI. كما أن نسخة المصدر المحلي ليست مطابقة تماماً للخادم الحي.

## العيوب المؤكدة والإصلاح المطلوب

### P0 — بيانات خاصة متاحة من دون مصادقة على الخادم الحي

أُجريت طلبات GET بلا Authorization إلى `https://iptvdemo.serv5group.com` في 6 نوفمبر 2026. أعادت مسارات المحادثات والسياق والخطط وXP استجابات 200، كما أعاد `/api/cv/preview` ملف PDF (200). استجابة السياق/الخطة تحتوي بيانات خاصة مرتبطة بمستخدم؛ لم يُحفظ محتوى الملف أو يُدرج هنا. هذا دليل مباشر على أن المسارات الحية لا تفرض حماية فعالة على هذه الطلبات أو أن وسيطاً أمامياً يتجاوزها. مصدر Backend المحلي يضع كثيراً من هذه المسارات داخل `auth:api`، ما يكشف أيضاً اختلافاً بين المصدر والنشر.

**الإصلاح:** تأمين كل endpoint للمستخدمين بمصادقة Laravel، ثم فرض الملكية على المحادثة والخطة وملف CV داخل كل Controller/Policy؛ لا يكفي إخفاؤها من التطبيق. أعد الاختبار بطلب بلا رمز (يجب أن يكون 401/403) ثم برمز مستخدم آخر (يجب أن يكون 403/404). راجع سجلات الوصول، وأوقف إتاحة ملفات CV العامة، ودوّر أي روابط/رموز دائمة إن استُخدمت.

مثال حماية المسار:

```php
Route::middleware(['auth:api', EnsureActiveCandidate::class])->group(function (): void {
    Route::get('/cv/preview/{cvDocument?}', [CvFileController::class, 'preview']);
    Route::get('/mentor/conversations', [MentorConversationController::class, 'index']);
    Route::get('/roadmaps', [RoadmapController::class, 'index']);
});
```

ويجب أن يتحقق Controller من ملكية السجل قبل إرجاعه، مثلاً `abort_unless($cvDocument->candidate_profile_id === $request->user()->candidateProfile?->id, 404);`.

### P1 — رفع CV من Flutter مرفوض باسم الحقل

Flutter يرسل `cv_file` إلى `POST /api/cv/upload`، بينما `UploadCvRequest` في Laravel يشترط `cv`. النتيجة المتوقعة 422 قبل حفظ الملف.

**إصلاح Flutter:**

```dart
return {
  'cv': MultipartFile.fromBytes(input.bytes, filename: input.fileName),
};
```

واجعل اختبارات العقد تستخدم الاسم `cv` نفسه، أو غيّر Laravel والعقد معاً إلى `cv_file`؛ لا تبقِ الاسمَين مختلفين.

### P1 — رفع CV لا يشغّل الاستخراج حتى بعد تصحيح الحقل

Flutter يستدعي `/api/cv/upload`، وهو `CvController::store` الذي يحفظ الملف بحالة `UPLOADED` فقط. استدعاء `ProcessCvJob::dispatch` معطّل في `CvService::uploadOrReplaceCv`، وكذلك في `retryProcessing`. يوجد endpoint منفصل `/api/ai/cv/upload` يستدعي AI تزامنياً، لكن Flutter لا يستخدمه. لذلك لا يبدأ الاستخراج في التدفق العادي، وتظل إعادة المحاولة غير معالجة.

**الإصلاح المقترح:** إعادة تفعيل Job خلف Queue، وربطه بـ `CvExtractionService::extractAndPersist`، وإطلاقه بعد commit؛ أعد إطلاقه أيضاً في retry. اجعل حالة السجل تتحول إلى `PROCESSING` ثم `COMPLETED` أو `FAILED`، وأبقِ حالة AI/ملخص الفشل متاحة لمسارات status/history. مثال:

```php
DB::afterCommit(fn () => ProcessCvJob::dispatch($cvDocument->id));
```

يجب أن يحمل الـ Job معرّف الوثيقة فقط، يعيد تحميلها، ثم يستدعي `app(CvExtractionService::class)->extractAndPersist($document)` مع سياسة retries وtimeouts مناسبة. كحل مؤقت أصغر، يمكن توجيه Flutter إلى `/api/ai/cv/upload` بعد مطابقة حقل الإدخال والاستجابة، لكنه يبقي الطلب طويلاً ومتزامناً.

### P1 — المرشد في نسخة Backend المحلية معطّل صراحةً وغير مربوط بتدفق AI

Flutter يتوقع CRUD للمحادثات: `/mentor/conversations`, `/mentor/context-preview`, ورسائل المحادثة. هذه المسارات غير معرفة في `routes/api.php` المحلي. الموجود فقط `POST /api/ai/mentor/ask`؛ والخدمة `AiMentorService::askMentor` تنتهي دائماً بإلقاء `mentor_contract_unavailable` ولا تستدعي `FastApiAiClient`. أما AI فيعرض `/api/v1/mentor/chat/stream` كـ SSE ويتطلب `MentorChatRequest` ومصادقة `get_current_user`؛ Laravel client الحالي لا يدعم SSE ولا يرسل هوية AI المتوافقة. لذلك لا يمكن توصيل Flutter مباشرة بهذا المسار بمجرد تغيير URL.

**الإصلاح:** اختيار عقد واحد. الأنسب أن ينشئ Laravel محادثات ورسائل مملوكة للمستخدم، ويبني payload من عقد `MentorChatRequest`، ويعمل proxy لتدفق AI مع تمرير/توليد هوية موثوقة متفق عليها، ثم يعيد SSE بالشكل الذي يقرأه Flutter. أضف endpoints CRUD والسياق التي يعتمدها Flutter، واختبارات عقد لكل حالة. لا تكتفِ بحذف الاستثناء النهائي في `AiMentorService`.

### P1 — بعض عمليات Flutter غير موجودة في مصدر Backend المحلي

المقارنة بين `EndPoint` و`routes/api.php`/`routes/cv.php` أظهرت الآتي:

| طلب Flutter | الحالة في Backend المحلي | الأثر / المطلوب |
|---|---|---|
| `GET /jobs/{id}` | غير معرّف للمستخدم؛ الموجود `/jobs` و`/jobs/{id}/save`، والتفاصيل للإدارة فقط | أضف details route للمستخدم مع `EnsureActiveUser` وResource مطابق لنموذج Flutter. فحص GET حي إلى `/api/jobs/1` أعاد 404؛ قد يكون غياب المسار أو عدم وجود المعرف. |
| `GET /roadmaps` | غير موجود؛ الموجود POST للإنشاء وGET للتفاصيل فقط | أضف index/pagination بما يطابق `data` و`meta` اللذين يقرأهما Flutter. |
| `GET /roadmaps/xp`, `GET /roadmaps/{id}/xp`, `PATCH /roadmaps/xp` | غير موجودة | أضف ملخص XP وتفاصيله ومنح XP، أو عدّل Flutter ليستخدم المسارات الفعلية. |
| `GET /cv/preview`, `/cv/file` ومشتقاتهما | غير موجودة في `routes/cv.php` | أضف تنزيل/عرض خاص مع تحقق الملكية و`Content-Disposition`، أو احذف وظائف Flutter المعتمدة عليها. |
| `POST /candidate/profile/avatar` | غير موجود | أضف route/controller/validation أو أوقف إرسال الرفع من Flutter. |

الطلبات GET إلى `/api/roadmaps` و`/api/cv/preview` نجحت على الخادم الحي بلا رمز في الفحص السابق؛ هذا لا يجعل كود المصدر المحلي مكتملاً، بل يدل على أن نشر الخادم يحتوي شيفرة مختلفة.

### P1 — مصدر Backend/OpenAPI لا يطابق نشر API وعنوان الخادم

Flutter يبدأ بـ `https://iptvdemo.serv5group.com/api/`، وهذا العنوان أعاد `/api/health` بحالة 200 وقاعدة بيانات متصلة. ملف OpenAPI في Backend يعلن `https://skillmatch.iptvdemo.serv5group.com`، لكن `/api/health` عليه أعاد 404 برسالة Laravel. كذلك الخادم الحي يدعم عدة مسارات لا تظهر في Backend المحلي. لا تنشر هذا المصدر قبل مطابقة الإصدار والعقد مع الخادم المقصود.

**الإصلاح:** اجعل OpenAPI يُولّد من نفس إصدار Laravel المنشور أو من مصدر واحد، صحح `servers` إلى المضيف الفعلي والمسار الصحيح، وأضف اختبار contract/route smoke لكل endpoint مستخدم في التطبيق إلى CI. عيّن عنوان Firestore من مصدر موثوق وتحقق من أنه يطابق هذا النشر.

### P1 — إعداد AI غير مضمون، ومفتاح الخدمة له قيم افتراضية غير آمنة

`Backend/.env.example` يترك `AI_SERVICE_API_KEY` فارغاً، بينما `AI-Serv5/.env.example` يطلب تفعيله بمفتاح. إذا فُعّل التحقق على AI دون تعيين المفتاح نفسه في Laravel، سترجع الاستدعاءات 401؛ وإذا لم يُضبط `ENABLE_API_KEY_AUTH` في AI فالقيمة الافتراضية `false` ويصبح AI بلا حماية. كما أن `AI-Serv5/src/core/config.py` يحتوي مفتاحاً افتراضياً ثابتاً ومفتاحاً سرياً افتراضياً؛ يجب ألا يُعتمد عليهما في أي نشر.

**الإصلاح:** أزل المفاتيح الثابتة، واجعل AI يرفض بدء بيئة الإنتاج إن لم يوجد مفتاح قوي ومصادقة مفعّلة؛ خزّن القيمة نفسها في Secret Manager على الجهتين. لا تضعها في Flutter. مثال قاعدة إعداد لاستخدامها في deploy:

```env
# Laravel secret
AI_SERVICE_BASE_URL=https://<ai-host>
AI_SERVICE_API_KEY=<secret-from-secret-manager>
AI_SERVICE_TIMEOUT=60
AI_SERVICE_CONNECT_TIMEOUT=5

# FastAPI secret (القيمة نفسها)
AI_SERVICE_API_KEY=<secret-from-secret-manager>
ENABLE_API_KEY_AUTH=true
LLM_PROVIDER=<google|openai|groq>
LLM_MODEL=<valid-model-for-provider>
LLM_API_KEY=<provider-secret>
```

### P1 — إعداد LLM النموذجي فارغ وخدمة AI الحية لم تجب

حقول `LLM_PROVIDER`, `LLM_MODEL`, `LLM_API_KEY` فارغة في `.env.example`. `get_llm()` يرفض إعداد النموذج صراحةً إذا لم توجد هذه القيم. لا يوجد `.env` محلي يثبت إعدادها على الخادم. كما انتهى فحص GET إلى `https://ai-serv5.fastapicloud.dev/health` بمهلة 10 ثوانٍ دون استجابة؛ لم أتمكن من تأكيد صحة AI الحي أو الوصول إلى مزوده.

**الإصلاح:** ضبط مزود/نموذج/مفتاح فعليين كأسرار في البيئة المنشورة، تنفيذ health/readiness يفحص إعداد LLM والاتصال بالمزود دون كشف المفاتيح، ومراقبة الـ timeout. لا تعتبر نجاح Health Laravel دليلاً على أن AI جاهز.

### P2 — مصدر إعداد عنوان API لا يطبق cache المعلن ويتسابق مع أول طلب

`DioConsumer` يضبط العنوان الثابت `EndPoint.baseUrl`. `AppInitializer.init()` يبدأ `refreshBaseUrl()` بـ `unawaited`، و`AppConfigService.currentBaseUrl`/cache لا يطبّق على Dio في التسجيل الظاهر. لذلك قد يستخدم التطبيق القيمة الثابتة قبل اكتمال Firestore، وفشل Firebase لا يمنع استخدام هذه القيمة، رغم أن التعليقات تقول إنه لا يوجد fallback وأن cache صالح سيستخدم.

**الإصلاح:** بعد تحميل SharedPreferences/Firebase، ضع العنوان المخزن الصالح على Dio قبل `runApp()`؛ ثم ابدأ التحديث البعيد دون حجب أول إطار. إن لم يوجد cache ولا إعداد بعيد، اترك `baseUrl` فارغاً كي يعمل فحص Dio fail-closed. احذف الثابت أو اجعله إعداد build صريحاً لا يتغلب على سياسة Firestore.

### P2 — اختلاف منفذ AI بين القالب وإعداد الحاوية

`.env.example` يذكر `API_PORT=8000`، بينما إعداد AI الافتراضي وDockerfile يشغلان 8001، و`src/api/main.py` يثبت تشغيله المحلي على 8001. `API_PORT` المقروء في config لا يضمن أن uvicorn يستخدمه.

**الإصلاح:** مصدر واحد للمنفذ، مثلاً `uvicorn.run(... port=settings.port)` مع Docker `CMD` يقرأ متغير البيئة، أو وثّق 8001 في كل الملفات. تحقق أيضاً من أن reverse proxy يوجّه للميناء نفسه.

## ما يتوافق في المسارات التي فُحصت

- Laravel `JobMatchingService` يرسل الحقول الأساسية التي يتطلبها `SkillGapAnalysisRequest`: `job_id`, `candidate_id`, `job_requirements`, `candidate_profile`، ويستهلك حقول الاستجابة الأساسية الموجودة في `SkillGapAnalysisResponse`.
- Laravel `CvExtractionService` يستدعي `/api/v1/cv/extract-file` بحقل multipart اسمه `file` و`candidate_id`، وهو متوافق مع endpoint AI. الخلل في أن تدفق Flutter المعتاد لا يصل إلى هذا المسار.
- تحليل الوصف الوظيفي يتوافق في اسم `job_description` وبنية `profile`، لكن AI يشترط طولاً من 50 إلى 20,000 حرف؛ يجب التحقق قبل الإرسال وإظهار خطأ واضح. كما لم يظهر استدعاء إنتاجي لـ `JobRequirementService` في شجرة `app`، بل تعريفه واستخدامه في الاختبارات فقط، فميزة تحليل متطلبات الإعلان تبدو غير موصولة في هذا المصدر.

## مراجعة إضافية: OTP والملف الشخصي وظهور البيانات

### OTP الثابت والبريد

- `Backend/.env.staging.example` يفعّل OTP الثابت ويضع رمزاً واحداً معروفاً. `EmailOtpService::staticCode()` يمنع الرمز في `production` فقط؛ لذلك يمكن استعماله في أي بيئة `staging` مشتركة إذا نُسخ المثال كما هو. لأن `send()` لا يرسل بريداً عندما يختار الرمز الثابت، المستخدم لن يستلم الرمز؛ النجاح يعتمد على معرفة الرمز الثابت. المسار نفسه يستخدمه رمز إعادة تعيين كلمة المرور، ما يجعل أي بيئة staging عامة معرضة لإعادة تعيين الحسابات برمز مشترك.
- `Backend/.env.example` يضع `MAIL_MAILER=log`. إذا لم تضبط بيئة الإنتاج mailer فعلياً، Laravel قد يسجل الرسالة محلياً/في log بدلاً من تسليمها، مع أن endpoint قد يعيد نجاحاً. لا يوجد `.env` فعلي يثبت إعداد البريد على الخادم الحي.
- Flutter يرسل `email` و`otp` بأسماء صحيحة، وBackend يعيد 422 عند الخطأ/الانتهاء و429 بعد المحاولات، وهي متوافقة مع عقد API المحفوظ. Flutter لا يستهلك access/refresh token من استجابة تحقق البريد، لكنه ينتقل عمداً إلى شاشة تسجيل الدخول؛ هذا ليس عيباً إذا كان هذا السلوك المقصود.

**الإصلاح:** اجعل الرمز الثابت متاحاً في `local`/`testing` فقط، لا في `staging`، واجعل قيمة القالب معطلة وفارغة. فعّل mail provider حقيقياً واختبر تسليم البريد والـ bounce في staging منفصل. مثال:

```php
private function staticCode(): ?string
{
    if (! in_array(app()->environment(), ['local', 'testing'], true)
        || ! config('otp.static_enabled')) {
        return null;
    }

    $code = config('otp.static_code');
    return is_string($code) && preg_match('/\A[0-9]{6}\z/', $code) ? $code : null;
}
```

في staging/production: `STATIC_OTP_ENABLED=false` و`MAIL_MAILER` مضبوط على SMTP/provider حقيقي. لا يكفي تغيير كود Flutter؛ توليد وتسليم OTP مسؤولية Backend.

### تحديث البروفايل: حقول Flutter غير مقبولة في Backend المحلي

عقد OpenAPI المحفوظ وFlutter يرسلان `full_name`, `phone`, `headline`, `location`, `summary`, وحقول روابط. لكن `ProfileUpdateRequest` المحلي لا يقبل إلا `job_title`, حقول الموقع المنفصلة و`professional_summary`؛ و`ProfileController::update` يطبق `validated()` على `CandidateProfile` فقط ولا يحدّث `User.name` أو `User.phone`. النتيجة أن Laravel يتجاهل حقول الاسم/الهاتف/headline/summary/location المجهولة، وقد يرجع نجاحاً دون حفظها؛ فتظهر القيم القديمة أو الفارغة عند إعادة جلب الملف.

**الإصلاح:** وحّد العقد أولاً. إما أن تعدل Flutter ليرسل حقول Backend الصريحة وتفصل حقول الموقع (`city`, `state`, `country`)، مع endpoint منفصل/جزء واضح لتحديث المستخدم؛ أو تجعل Laravel يقبل حقول OpenAPI ويحوّلها صراحةً إلى جداول `users` و`candidate_profiles`. لا تعتمد على `validated()` الحالي لحفظ مفاتيح لا يعرّفها FormRequest.

مثال اتجاه التعديل في Controller بعد إضافة validation لهذه الحقول:

```php
use Illuminate\Support\Arr;

$data = $request->validated();
if (array_key_exists('full_name', $data)) {
    $user->name = $data['full_name'];
}
if (array_key_exists('phone', $data)) {
    $user->phone = $data['phone'];
}
$user->save();

$profileData = Arr::only($data, ['github_url', 'linkedin_url']);
if (array_key_exists('headline', $data)) $profileData['job_title'] = $data['headline'];
if (array_key_exists('summary', $data)) $profileData['professional_summary'] = $data['summary'];
// حوّل الموقع إلى city/state/country بعقد واضح، أو أضف location كحقل رسمي.
```

أضف اختباراً يحدّث كل حقل ثم يعيد `GET /candidate/profile` ويتحقق من القيم المخزنة، لا من status 200 وحده.

### تأكيد بيانات CV: Flutter مطابق للعقد لكن Backend المحلي لا يطابقه

`CvVerifyParams.toJson()` يرسل `action`, `verified_skills`, `verified_educations`, `verified_experiences` مثل OpenAPI المحفوظ. لكن `VerifyCvExtractionRequest` في Backend المحلي يتحقق من `skills` و`experiences` فقط، ولا يقبل `action` أو مجموعات `verified_*` أو التعليم. ثم `CvController::verify` يمرر `validated()` كما هي إلى `CvService::verifyAndSyncExtractedData` الذي يتوقع `skills` و`experiences`. بالتالي بيانات التحقق التي يرسلها Flutter لا تصل إلى الحفظ؛ وقد يعود نجاح بلا مزامنة أي شيء. هذا سبب مباشر إضافي لاحتمال عدم ظهور معلومات مستخرجة في البروفايل.

**الإصلاح:** اجعل Laravel يطبق عقد API المحفوظ: اقبل `verified_skills`, `verified_educations`, `verified_experiences`, حوّلها إلى البنية الداخلية، ونفّذ upsert للسجلات المؤكدة داخل transaction. أو غيّر العقد وFlutter معاً؛ إبقاء جانبين مختلفين غير مقبول. أضف اختباراً يرسل payload Flutter نفسه ثم يعيد البروفايل ويتأكد من ظهور المهارات والتعليم والخبرات.

### بيانات موجودة في استجابة Backend لكن نموذج Flutter لا يحملها

`CandidateProfileResource` يرسل `certificates` و`languages`، لكن `CandidateProfileModel`/`CandidateProfileEntity` لا يقرآن هاتين القائمتين ولا يعرّفان لهما حقولاً. لذا حتى لو كانت البيانات صحيحة في قاعدة البيانات والـ JSON، تُسقط عند التحويل داخل Flutter ولن تصل إلى الواجهة. أضف `CertificateModel` و`LanguageModel` وقوائم في entity/parser/UI/cache، أو احذفهما من توقعات العرض إن لم تكن الواجهة تدعمهما.

### اختبار خريطة الحقول بدل اعتبار أي استجابة ناجحة دليلاً على الحفظ

تدفق الملف الشخصي صحيح شكلياً في القراءة: Backend يعيد `{data: {profile_exists, user, profile}}` وFlutter يقرأ `response.data` ثم يمرر الداخل إلى `CandidateProfileModel`. المهارات/المشاريع/الخبرات/التعليم/التفضيلات تقابل مفاتيح resource الحالية. الخلل الملموس في الكتابة والتحقق أعلاه، وفي غياب حقول certificates/languages من نموذج التطبيق. اختبر GET بعد كل PATCH/POST للتحقق من القيمة المخزنة وعرضها.

### مسارات اجتماعية معلنة لكنها غير منفذة في Flutter

زر Google sign-in موجود، لكن `AuthRemoteDataSourceImpl.loginWithGoogle()` يرمي `501` صراحةً؛ لا يوجد endpoint في Backend المحلي يتبادل Google ID token مقابل JWT الخاص بالتطبيق. Firebase Google Sign-In وحده لا ينشئ جلسة Laravel. إما إخفاء الزر حتى إضافة route تتحقق من Google ID token على السيرفر وتصدر رموز التطبيق، أو إكمال التكامل end-to-end.

## تحقق التشغيل المنفذ

- **مراجعة توثيق الموقع الحي:** فتحت `https://iptvdemo.serv5group.com/api/docs` بنجاح (200)، واستخرجت ملف Swagger الفعلي الذي تحمّله الصفحة من `https://iptvdemo.serv5group.com/api/docs/openapi.json`. قورنت كل عملية HTTP في الوثيقة الحية مع `docs/api/openapi.json`: كلاهما OpenAPI 3، الإصدار 1.0.0، وفيهما 120 مساراً و159 عملية، وعدد العمليات ذات اختلاف في التعريف/الحقول/الاستجابة **صفر**. هذا يؤكد أن snapshot المحلي حديث ومطابق للوثيقة الحية وقت الفحص، ويؤكد أن Flutter يفترض أن يُقاس على هذا العقد. لكنه لا يثبت تطابق Laravel المحلي مع الخادم المنشور، ولا أن التنفيذ يطبق التوثيق فعلاً.
- **قصور توثيق المصادقة:** وثيقة OpenAPI الحية لا تعرّف `securitySchemes` ولا `security` على العمليات المختارة (ومنها البروفايل ورفع CV وOTP)، وواجهة Swagger تخفي زر التفويض. لا يمكن اعتبار هذا وحده إثباتاً أن كل endpoint عام؛ لكن مع نتائج GET بلا Authorization الموثقة أعلاه، يلزم تصحيح التوثيق واختبار المصادقة على الخادم نفسه.
- `GET https://iptvdemo.serv5group.com/api/health`: 200؛ الحالة healthy وقاعدة البيانات connected وقت الفحص.
- `GET https://skillmatch.iptvdemo.serv5group.com/api/health`: 404؛ عنوان OpenAPI الحالي لا يطابق هذا المسار الحي.
- GET بلا Authorization إلى مسارات السياق/المحادثات/الخطط/XP وCV preview على المضيف الأول: 200؛ منها PDF فعلي لـ CV preview. تعامل معها كحادثة صلاحيات حتى يثبت العكس.
- AI health: انتهت مهلة 10 ثوانٍ دون استجابة.
- `flutter analyze` بدأ لكنه لم يعط نتيجة بعد نحو 100 ثانية، فأوقفته؛ لا أعتبر ذلك نجاحاً ولا فشلاً للتحليل.
- لم تتوفر `Backend/vendor/autoload.php` ولا بيئة `.venv` لـ AI؛ لذلك لم تُشغّل اختبارات PHP أو pytest محلياً. لم تُعدّل ملفات التنفيذ.

## ترتيب المعالجة

1. إغلاق الوصول غير الموثق لبيانات CV والمحادثات والخطط على الخادم الحي والتحقق من الملكية.
2. توحيد نسخة المصدر وعقد OpenAPI وعنوان الإنتاج، ثم اختبار المسارات الفعلية.
3. إصلاح حقل CV وإعادة تفعيل معالجة الاستخراج والـ retry.
4. تنفيذ تكامل المرشد فعلياً وتوحيد عقد SSE/المحادثات بين Flutter وLaravel وAI.
5. تأمين إعداد مفاتيح AI وLLM وإثبات readiness للخدمة.
6. إضافة endpoints الناقصة في Backend المحلي أو مزامنة المصدر من الإصدار الحي، ثم تشغيل التحليل والاختبارات بعد توفير الاعتماديات.

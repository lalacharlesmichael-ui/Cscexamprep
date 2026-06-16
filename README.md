# SibilPrep

Flutter Civil Service exam preparation quiz app backed by Supabase.

## Supabase setup

1. Create a Supabase project.
2. In **Authentication > Providers > Email**, disable **Confirm email**. The app turns usernames into internal `@users.cscquiz.app` auth addresses, so users cannot receive confirmation emails.
3. Open the Supabase SQL Editor and run [`supabase/schema.sql`](supabase/schema.sql). Re-run this file after pulling schema changes. It creates the tables, Row Level Security policies, profile trigger, admin approval function, exam catalog, starter questions, and question-integrity guardrails.
4. The app includes the current public Supabase URL and anon key as a fallback. You can override them locally with dart defines:

```powershell
C:\flutter\bin\flutter.bat run `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Use only the public publishable/anon key in the Flutter app. Never put the Supabase service-role key in client code.

The first account created after applying the schema becomes the administrator automatically. Every later user can create an account normally, then waits for an administrator to approve it from the Admin Dashboard.

Pending users cannot access the quiz dashboard until an administrator approves them. Administrators can also reject accounts that should not have access.

## Question import safety

The schema now blocks new question rows whose selected area does not belong to the selected exam type, or whose specific field does not belong to the selected area. If you already imported PDF/doc questions and suspect bad rows, sign in as an administrator and run this in the Supabase SQL Editor:

```sql
select *
from public.find_question_integrity_issues();
```

Fix or delete any returned rows, then run these checks when the result is empty:

```sql
alter table public.questions validate constraint questions_area_matches_exam_type;
alter table public.questions validate constraint questions_sub_area_matches_area;
```

## Vercel deployment

In Vercel, these Environment Variables are optional because the app has public fallback values. Add them for Production, Preview, and Development if you want to override the defaults:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

The project uses [`vercel.json`](vercel.json) and [`scripts/vercel-build.sh`](scripts/vercel-build.sh). Vercel will build Flutter web into `build/web`.

## GitHub

The GitHub Actions workflow in [`.github/workflows/flutter-ci.yml`](.github/workflows/flutter-ci.yml) runs `flutter analyze`, `flutter test`, and a Flutter web build on pushes and pull requests to `main`.

If registration reports an email rate limit, confirm that **Confirm email** is disabled. Supabase's built-in email service permits only a small number of emails per hour. Delete any pending unconfirmed test user before registering that username again.

## Promote an additional administrator

The first completed registration becomes the initial administrator automatically. To promote another approved account, open the Supabase **SQL Editor** and inspect the existing accounts:

```sql
select id, full_name, username, role
from public.profiles
order by id;
```

Promote the required account by username:

```sql
update public.profiles
set role = 'admin'
where username = 'cmkhel';
```

Verify the role:

```sql
select username, role
from public.profiles
where username = 'cmkhel';
```

Log out of the app and log in again as `cmkhel`. The app will open the **Admin Dashboard**.

To remove administrator access later:

```sql
update public.profiles
set role = 'user'
where username = 'cmkhel';
```

## Included features

- Supabase Auth username-based login and registration
- Administrator approval or rejection for new registrations
- Professional and Sub-Professional quiz levels
- Overall, area, and specific-topic quizzes
- Timed questions, result review, and progress analytics
- Admin question management and user-result reporting
- Supabase persistence with Row Level Security

## Verification

```powershell
C:\flutter\bin\flutter.bat analyze --no-fatal-infos
C:\flutter\bin\flutter.bat test
```

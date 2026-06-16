# SibilPrep

Flutter Civil Service exam preparation quiz app backed by Supabase.

## Supabase setup

1. Create a Supabase project.
2. In **Authentication > Providers > Email**, disable **Confirm email**. The app turns usernames into internal `@users.cscquiz.app` auth addresses, so users cannot receive confirmation emails.
3. Open the Supabase SQL Editor and run [`supabase/schema.sql`](supabase/schema.sql). Re-run this file after pulling schema changes. It creates the tables, Row Level Security policies, approval functions, profile trigger, exam catalog, and starter questions.
4. The Supabase project URL and public anon key are configured in `lib/main.dart`. Start the app normally:

```powershell
C:\flutter\bin\flutter.bat run
```

Use only the public publishable/anon key in the Flutter app. Never put the Supabase service-role key in client code.

The first registration request after applying the schema receives a bootstrap approval code and becomes the administrator. Every later user must:

1. Submit an approval request from the registration screen.
2. Wait for an administrator to accept the request.
3. Get the generated 6-digit code from the administrator.
4. Use that code, the same username, and a new password to complete registration.

Pending requests never store user passwords.

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
- Administrator approval and one-time code for new registrations
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

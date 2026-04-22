# Database Backup — Demo Environment

## Creating the backup (run before demo day)

```bash
# Dump full schema + data into a single file committed to the repo
mysqldump -u <user> -p \
    --single-transaction \
    --routines \
    --triggers \
    job_matching > docs/db_backup.sql
```

Then commit it:
```bash
git add docs/db_backup.sql
git commit -m "chore: add pre-demo database backup"
```

> **Note:** `db_backup.sql` is gitignored by default for security.
> Remove it from `.gitignore` before adding (or use `git add -f docs/db_backup.sql`).

## Restoring from backup

```bash
mysql -u <user> -p -e "DROP DATABASE IF EXISTS job_matching; \
  CREATE DATABASE job_matching CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u <user> -p job_matching < docs/db_backup.sql
```

## Why commit the backup?

The backup captures the exact database state rehearsed with.
If the app crashes during the demo and the DB becomes corrupted,
any teammate can restore it in under 60 seconds from the committed file.

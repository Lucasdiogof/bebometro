"""Applies ONLY what the 6-digit password recovery needs to Supabase Auth of
project jiisoqkryhmtopaojyyu:

  mailer_templates_recovery_content  <- supabase/email-templates/recovery.html
  mailer_subjects_recovery           <- trilingual subject
  mailer_otp_length                  <- 6 (only when different)

Nothing else is sent: SMTP, the other templates, redirects and "Confirm email"
(mailer_autoconfirm) are left exactly as they are, and the script stops if the
read-back shows any of them changed. No e-mail is sent, no account is created.

  SUPABASE_ACCESS_TOKEN=... python -I scripts/apply_recovery_code.py          # dry run
  SUPABASE_ACCESS_TOKEN=... python -I scripts/apply_recovery_code.py --apply
"""
import json
import os
import sys
import urllib.error
import urllib.request

REF = 'jiisoqkryhmtopaojyyu'
API = f'https://api.supabase.com/v1/projects/{REF}/config/auth'
HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATE = os.path.join(HERE, '..', 'supabase', 'email-templates', 'recovery.html')
SUBJECT = 'Redefinir senha · Reset password · Restablecer contraseña'
CODE_LENGTH = 6
# Settings that must not move while this runs.
WATCHED = ('mailer_autoconfirm', 'smtp_host', 'smtp_admin_email', 'site_url',
           'mailer_templates_confirmation_content', 'mailer_otp_exp')


def call(token, method, body=None):
    req = urllib.request.Request(
        API, method=method,
        data=None if body is None else json.dumps(body).encode(),
        headers={'Authorization': f'Bearer {token}', 'Content-Type': 'application/json',
                 'User-Agent': 'bebometro-setup'})
    try:
        with urllib.request.urlopen(req) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        print('HTTP', e.code, e.read().decode()[:500])
        raise SystemExit(1)


def main():
    token = os.environ.get('SUPABASE_ACCESS_TOKEN')
    if not token:
        raise SystemExit('Set SUPABASE_ACCESS_TOKEN.')
    apply = '--apply' in sys.argv
    with open(TEMPLATE, encoding='utf-8') as f:
        content = f.read().replace('\r\n', '\n')
    if '{{ .Token }}' not in content or '.ConfirmationURL' in content:
        raise SystemExit('recovery.html must show {{ .Token }} and no link.')

    before = call(token, 'GET')
    cur = before.get('mailer_templates_recovery_content') or ''
    print('Target project:', REF, '| mode:', 'APPLY' if apply else 'dry run')
    print('recovery template now: has {{ .Token }} =', '.Token' in cur,
          '| has link =', '.ConfirmationURL' in cur or '.TokenHash' in cur,
          '| same as repo =', cur == content)
    print('mailer_otp_length now:', before.get('mailer_otp_length'),
          '| mailer_otp_exp (s):', before.get('mailer_otp_exp'),
          '| mailer_autoconfirm:', before.get('mailer_autoconfirm'))

    patch = {}
    if cur != content:
        patch['mailer_templates_recovery_content'] = content
    if before.get('mailer_subjects_recovery') != SUBJECT:
        patch['mailer_subjects_recovery'] = SUBJECT
    if before.get('mailer_otp_length') != CODE_LENGTH:
        patch['mailer_otp_length'] = CODE_LENGTH
    print('Would change:', sorted(patch) or 'nothing')
    if not apply or not patch:
        return

    call(token, 'PATCH', patch)
    after = call(token, 'GET')
    ok = True
    for k, v in patch.items():
        same = after.get(k) == v
        ok = ok and same
        print(k, 'OK' if same else 'DIFF')
    for k in WATCHED:
        same = after.get(k) == before.get(k)
        ok = ok and same
        print('unchanged', k, 'OK' if same else 'CHANGED')
    if not ok:
        raise SystemExit(1)


if __name__ == '__main__':
    main()

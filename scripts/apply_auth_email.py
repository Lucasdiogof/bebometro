"""Applies the Bebometro e-mail setup to Supabase Auth: custom SMTP, the four
trilingual templates and their subjects. "Confirm email" is never touched
(the product signs people in right away; keep it OFF).

Only project jiisoqkryhmtopaojyyu is touched. Secrets come from the
environment and are never printed or written to disk:

  SUPABASE_ACCESS_TOKEN   personal access token of the account that owns the project
  BEBOMETRO_SMTP_PASS     SMTP password (for Resend: an API key with sending access)
  BEBOMETRO_SMTP_FROM     sender address, on a domain verified at the provider

Optional: BEBOMETRO_SMTP_HOST (default smtp.resend.com), BEBOMETRO_SMTP_PORT
(default 465), BEBOMETRO_SMTP_USER (default resend).

  python -I scripts/apply_auth_email.py             # show what would change
  python -I scripts/apply_auth_email.py --apply     # SMTP, then templates

To change ONLY the recovery template and the code length, use
scripts/apply_recovery_code.py instead. The script does not send any e-mail
and does not create accounts.
"""
import json
import os
import sys
import urllib.error
import urllib.request

REF = 'jiisoqkryhmtopaojyyu'
API = f'https://api.supabase.com/v1/projects/{REF}/config/auth'
HERE = os.path.dirname(os.path.abspath(__file__))
TPL = os.path.join(HERE, '..', 'supabase', 'email-templates')

SUBJECTS = {
    'confirmation': 'Confirme seu e-mail · Confirm your email · Confirma tu correo',
    'recovery': 'Redefinir senha',
    'email_change': 'Confirme o novo e-mail · Confirm your new email · Confirma tu nuevo correo',
    'reauthentication': 'Código de verificação · Verification code · Código de verificación',
}


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


def template(name):
    with open(os.path.join(TPL, f'{name}.html'), encoding='utf-8') as f:
        return f.read().replace('\r\n', '\n')


def main():
    token = os.environ.get('SUPABASE_ACCESS_TOKEN')
    password = os.environ.get('BEBOMETRO_SMTP_PASS')
    sender = os.environ.get('BEBOMETRO_SMTP_FROM')
    if not token:
        raise SystemExit('Set SUPABASE_ACCESS_TOKEN.')
    apply = '--apply' in sys.argv
    print('Target project:', REF, '| mode:', 'APPLY' if apply else 'dry run')

    before = call(token, 'GET')
    has_smtp = bool(before.get('smtp_host'))
    # The recovery e-mail carries only the code: it must have 6 digits.
    print('mailer_otp_length:', before.get('mailer_otp_length'), '(expected 6)',
          '| mailer_otp_exp (s):', before.get('mailer_otp_exp'))
    smtp = {}
    if password and sender:
        smtp = {
            'smtp_host': os.environ.get('BEBOMETRO_SMTP_HOST', 'smtp.resend.com'),
            'smtp_port': os.environ.get('BEBOMETRO_SMTP_PORT', '465'),
            'smtp_user': os.environ.get('BEBOMETRO_SMTP_USER', 'resend'),
            'smtp_pass': password,
            'smtp_admin_email': sender,
            'smtp_sender_name': 'Bebômetro',
        }
    elif not has_smtp:
        raise SystemExit('No SMTP on the project yet: set BEBOMETRO_SMTP_PASS and BEBOMETRO_SMTP_FROM.')

    templates = {}
    for name, subject in SUBJECTS.items():
        templates[f'mailer_templates_{name}_content'] = template(name)
        templates[f'mailer_subjects_{name}'] = subject

    shown = {k: ('<hidden>' if k == 'smtp_pass' else v) for k, v in smtp.items()}
    print('SMTP to set:', shown or '(already configured, left as is)')
    print('Templates/subjects to set:', len(templates))
    if not apply:
        return

    if smtp:
        call(token, 'PATCH', smtp)
    call(token, 'PATCH', templates)

    after = call(token, 'GET')
    ok = True
    for k, v in {**{k: v for k, v in smtp.items() if k != 'smtp_pass'}, **templates}.items():
        same = after.get(k) == v or (k == 'smtp_port' and str(after.get(k)) == str(v))
        ok = ok and same
        print(k, 'OK' if same else 'DIFF')
    print('smtp_pass stored:', bool(after.get('smtp_pass')))
    print('mailer_otp_length:', after.get('mailer_otp_length'),
          '| mailer_otp_exp (s):', after.get('mailer_otp_exp'))
    print('mailer_autoconfirm:', after.get('mailer_autoconfirm'),
          '(must stay True: "Confirm email" OFF)')
    if not ok:
        raise SystemExit(1)


if __name__ == '__main__':
    main()

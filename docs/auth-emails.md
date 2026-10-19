# E-mails de autenticação (Supabase) em pt-BR, en e es

> Passo a passo de SMTP e redirects: [`external-setup.md`](external-setup.md), seções 4 e 5.
> Estado em **14/10/2026**. Legenda: *implementado* (código no repositório), *configurado no servidor* (aplicado no projeto),
> *verificado pela API* (lido de volta), *validado no app* (fluxo executado e observado).

## Decisões em vigor

- Conta permanente obrigatória; o cadastro **entra direto**, sem confirmação de e-mail (`mailer_autoconfirm: true`, lido pela API
  pública `/auth/v1/settings` em 14/10/2026).
- Recuperação de senha por **código de 6 dígitos**, sem link, deep link nem PKCE.
- Não existe conversão de sessão anônima nem importação de dados antigos (código removido em 14/10/2026).

## Recuperação por código

| Etapa | Estado |
|---|---|
| App: pedir código (`resetPasswordForEmail`, sem `redirectTo`) | Implementado |
| App: verificar (`verifyOTP(type: OtpType.recovery, email, token)`) | Implementado |
| App: nova senha (`updateUser(password)`, só no estado `passwordRecovery`) | Implementado |
| Template `recovery.html` com `{{ .Token }}`, sem link | Implementado e **aplicado no servidor**: lido de volta em 19/10/2026 (dry run de `scripts/apply_recovery_code.py`): tem `{{ .Token }}`, sem link, idêntico ao repositório |
| `mailer_otp_length = 6` | **Lido em 19/10/2026** com token pessoal: 6 (validade `mailer_otp_exp` = 3600 s; `mailer_autoconfirm` = true) |
| E-mail real com código recebido | **Não observado** |
| Troca de senha concluída no app | **Não validado** |

**Tipo de OTP correto (conferido no pacote instalado `gotrue` 2.27.3, em `verifyOTP`):** `type: recovery` vai para `/verify` com
`type=recovery` e emite `AuthChangeEvent.passwordRecovery`. Não é `OtpType.email`/`magiclink` nem `signInWithOtp`, então não cria
conta nem faz login por código. `resetPasswordForEmail` só envia e-mail para conta existente; a mensagem do app é neutra ("se houver
uma conta com esse e-mail...").

**Variável do template (documentação oficial "Email Templates", conferida em 14/10/2026):** `{{ .Token }}` é o código numérico de uso
único; `{{ .ConfirmationURL }}` é o link. O `recovery.html` usa só `{{ .Token }}`. O idioma vem de `{{ .Data.language }}` (pt como
padrão).

### Comportamentos conferidos por leitura do código (não é teste)

- Código rejeitado ou falha de rede: o marcador local de recuperação é apagado, não há sessão e a tela de nova senha não abre; o erro
  aparece no campo do código (código inválido/expirado) ou no topo (sem conexão). E-mail e código digitados continuam na tela.
- Nova senha só é salva no estado `passwordRecovery` (`setPassword` recusa qualquer outro estado).
- "Cancelar e sair" na tela de nova senha encerra a sessão; o botão voltar do sistema não leva ao app (a tela é a raiz do portão).
- Sessão de recuperação sem nova senha salva: na reabertura, dentro de 2 h, volta à tela de nova senha; depois disso (ou com marcador
  de outro e-mail) a sessão é **encerrada**, nunca vira login normal.
- Logout apaga o marcador de recuperação.
- Reenvio: um único `Timer` por tela (cancelado no `dispose`) só redesenha a contagem; a espera de 60 s fica no `AuthController`.
- Logs: só o tipo do erro (`runtimeType`), nunca e-mail, código, token ou senha.
- Callbacks antigos: os estados `emailPending`, `needsPassword` e `legacyAnonymous` não existem mais; o portão só conhece
  `initializing`, `signedOut`, `reauthRequired`, `passwordRecovery` e `authenticated`.

### Aplicar no servidor (pendência do responsável)

```bash
SUPABASE_ACCESS_TOKEN=... python -I scripts/apply_recovery_code.py
```

Sem `--apply` só mostra o estado atual (template tem `{{ .Token }}`? tem link? `mailer_otp_length`, `mailer_otp_exp`,
`mailer_autoconfirm`) e o que mudaria. Com `--apply` envia **só** `mailer_templates_recovery_content`, `mailer_subjects_recovery` e,
se diferente, `mailer_otp_length = 6`; depois lê de volta e para com erro se SMTP, `site_url`, o template de confirmação,
`mailer_otp_exp` ou `mailer_autoconfirm` tiverem mudado. Não envia e-mail.

Alternativa manual: Auth → Email Templates → **Reset password** (colar `supabase/email-templates/recovery.html`, assunto
`Redefinir senha · Reset password · Restablecer contraseña`) e Auth → Providers → Email → **Email OTP Length = 6**.

Depois: pedir um código para uma conta **própria**, conferir que o e-mail mostra 6 dígitos e nenhum link, digitar no app e salvar
uma senha nova.

## Templates no repositório

| Tipo no painel | Arquivo | Usado pelo app hoje |
|---|---|---|
| Reset password | `supabase/email-templates/recovery.html` | Sim (código) |
| Reauthentication | `supabase/email-templates/reauthentication.html` | Só se "Secure password change" for ligado |
| Change email address | `supabase/email-templates/email_change.html` | Não (o app não troca e-mail) |
| Confirm signup | `supabase/email-templates/confirmation.html` | Não (confirmação desligada) |

Cada tipo tem um template por projeto (Go templates) e um assunto; por isso os assuntos são trilíngues. O idioma vem de
`user_metadata.language`, gravado pelo app no cadastro e ao trocar de idioma com a conta aberta. Contas sem o campo recebem
português. Quem pede recuperação sem estar logado recebe no idioma **gravado na conta**, não no do aparelho.

`scripts/apply_auth_email.py` aplica SMTP + os quatro templates (amplo; usar só para refazer tudo). A opção que ligava "Confirm
email" foi **removida**.

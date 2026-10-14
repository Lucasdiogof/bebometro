# E-mails de autenticação (Supabase) em pt-BR, en e es

> Passo a passo de configuração (assuntos, SMTP, redirects): [`external-setup.md`](external-setup.md), seções 4 e 5.
> Atualização de 13/10/2026: templates revisados (layout simples e responsivo, marca, teste de idioma protegido contra campo
> ausente). A API pública mostra que **"Confirm email" está desligado** hoje (`mailer_autoconfirm: true`); templates e SMTP
> continuam **não aplicados** e nenhum e-mail foi enviado. Em 13/10/2026 a API de gerenciamento recusou a alteração dos templates
> enquanto não há SMTP próprio; o `scripts/apply_auth_email.py` aplica SMTP + templates juntos quando houver credencial.
> **Atualização (13/10/2026): SMTP e templates foram aplicados e lidos de volta.** "Confirm email" segue desligado e nenhuma entrega real
> foi verificada.

**Estado:** as telas do app estão nos três idiomas (implementado em código). Os **e-mails** enviados pelo Supabase são
outra coisa: só ficam traduzidos depois que os templates abaixo forem colados no painel. **Nada disso foi aplicado
daqui** (sem acesso administrativo) e nenhum e-mail de teste foi enviado.

## O que o Supabase permite (documentação oficial conferida em 13/10/2026)

- Cada tipo de e-mail tem **um** template por projeto, em Go templates. Não há um template por idioma.
- O idioma pode vir de `user_metadata`: `{{ .Data.language }}` com `if/else` no próprio template (guia "Customizing
  Emails by Language").
- Assunto: um só por tipo; por isso os assuntos são trilíngues ("Confirme seu e-mail · Confirm your email · Confirma tu
  correo").
- Alternativas que exigiriam infraestrutura/serviço extra (não adotadas): Auth Hook de e-mail (Send Email hook) com
  provedor próprio.

## O que o app faz

- Grava `language` (`pt`, `en` ou `es`) em `user_metadata` no **cadastro** e na **conversão de conta antiga**, e
  atualiza quando a pessoa troca o idioma com a conta aberta (`AuthController.syncLanguage`, silencioso).
- Contas que nunca gravaram o idioma (criadas antes desta rodada e que não trocaram de idioma depois) recebem o
  e-mail em **português** (ramo `else`). Um e-mail de recuperação de senha pedido sem sessão usa o último idioma gravado.

## Aplicação (manual, por quem tem acesso ao painel)

Em **Auth → Email Templates**, para cada tipo, copiar o conteúdo do arquivo e ajustar o assunto:

| Tipo no painel | Arquivo |
|---|---|
| Confirm signup | `supabase/email-templates/confirmation.html` |
| Reset password | `supabase/email-templates/recovery.html` |
| Change email address | `supabase/email-templates/email_change.html` |
| Reauthentication | `supabase/email-templates/reauthentication.html` |

Magic link e Invite não são usados pelo app. Cada template traz o assunto sugerido no comentário do topo. Se o painel
recusar a sintaxe, o Supabase usa um template padrão (ver "Email template not updating" na documentação); conferir os
*Auth Logs*.

Observação: depois de colar, **testar com uma conta própria** nos três idiomas antes de liberar.

## Manual linking

O guia oficial "Anonymous Sign-Ins → Convert an anonymous user to a permanent user" diz que converter o usuário anônimo
exige vincular uma identidade e que isso requer **habilitar Manual linking** — inclusive no caso de e-mail via
`updateUser(email)`. O fluxo implementado (`AuthController.convertAnonymous`) é exatamente esse, então a exigência
**está confirmada pela documentação** (não é uma suposição) e o item do checklist permanece.

## Idioma do e-mail x idioma atual de quem pede

O Supabase renderiza o e-mail com os dados da **conta** (`user_metadata.language`). Uma pessoa que pede recuperação de senha sem
estar logada, num app com outro idioma escolhido agora, recebe o e-mail no idioma **gravado na conta**. A API do cliente não
permite escolher o idioma por pedido, então isso não é prometido. Contas sem o campo recebem português.

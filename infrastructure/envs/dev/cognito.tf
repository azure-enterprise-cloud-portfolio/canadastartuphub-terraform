
# ============================================================
# Canada Tech Intelligence
# DEV Cognito Authentication
# ============================================================
#
# This is the DEV environment. The user pool, the Google identity provider,
# the hosted-UI domain (cti-dev-auth) and the web app client all live here and
# are the ONLY Cognito resources this project is designed to have — see
# CLAUDE.md in the application repo.
#
# The callback and logout URLs below are DEV URLs. They were production URLs
# until 2026-11-18, which is why Google sign-in could not work on dev at all:
# Cognito validates `redirect_uri` against this list before it does anything
# else, so every /oauth2/authorize request from dev.canadatechintelligence.ca
# was answered with `error=redirect_mismatch`. A callback list is per-app-client
# and per-environment; it is never shared between dev and prod.

module "cognito" {
  source = "../../modules/cognito"

  project     = var.project
  environment = var.environment

  # Google Sign-In
  enable_google_login  = true
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  # ----------------------------------------------------------
  # DEV OAuth callback URLs
  # ----------------------------------------------------------
  # Cognito requires an EXACT string match, so the path matters: the
  # application completes the flow at /auth/callback and nowhere else.
  #
  # localhost is here so the flow can be exercised against `npm run build &&
  # npm start` before a deploy. It is safe on this list and only on this list:
  # it is a DEV-only pool, and Amplify's own redirect resolver picks an entry by
  # matching the browser's hostname, so a localhost entry is never selected
  # from a deployed page. Drop it if DEV should refuse local sign-in.
  oauth_callback_urls = [
    "https://dev.canadatechintelligence.ca/auth/callback",
    "http://localhost:3000/auth/callback",
  ]

  # ----------------------------------------------------------
  # DEV logout redirect URLs
  # ----------------------------------------------------------
  # Where Cognito's hosted /logout endpoint returns a customer who signed in
  # through Google. Amplify only visits that endpoint for a federated session —
  # an email/password sign-out never leaves the site — and it is what clears
  # the hosted-UI session cookie, without which "Continue with Google" would
  # silently re-authenticate the previous account on a shared computer.
  #
  # No query string: Cognito matches `logout_uri` exactly, so the landing page
  # cannot carry its own ?reason= parameter.
  oauth_logout_urls = [
    "https://dev.canadatechintelligence.ca/login",
    "http://localhost:3000/login",
  ]
}

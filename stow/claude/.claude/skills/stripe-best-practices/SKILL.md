---
name: stripe-best-practices
description: Use when implementing Stripe payment integration, handling webhooks, managing subscriptions, or troubleshooting payment flows
---

# Stripe Best Practices

Correct patterns for Stripe payment implementation.

## When to Use

- User is integrating Stripe Checkout, Payment Intents, or Subscriptions
- User needs to set up or debug webhooks
- User asks about idempotency, error handling, or PCI compliance
- User is building a billing or pricing page

## Quick Reference: Core Patterns

### Webhook Handler Pattern
```
1. Verify signature (stripe.webhooks.constructEvent)
2. Parse event type
3. Process idempotently (check if already handled)
4. Return 200 immediately (process async if heavy)
5. Implement retry logic for failures
```

Critical webhook events to handle:
| Event | Action |
|-------|--------|
| `checkout.session.completed` | Fulfill order, grant access |
| `invoice.payment_succeeded` | Extend subscription |
| `invoice.payment_failed` | Notify user, retry logic |
| `customer.subscription.deleted` | Revoke access |
| `payment_intent.payment_failed` | Show error to user |

### Idempotency
- Always pass `idempotencyKey` on create operations
- Use deterministic keys (e.g., `order_${orderId}`)
- Never retry with a different idempotency key for the same operation
- Keys expire after 24 hours

### Checkout Flow
1. Create Checkout Session server-side (never expose secret key)
2. Redirect to Stripe-hosted page OR use embedded checkout
3. Handle success via webhook (NOT success URL alone)
4. Success URL is for UX only — webhook is the source of truth

### Subscription Lifecycle
1. Create Customer → attach PaymentMethod
2. Create Subscription with `payment_behavior: 'default_incomplete'`
3. Handle `invoice.payment_succeeded` to activate
4. Handle `customer.subscription.updated` for plan changes
5. Handle cancellation with `cancel_at_period_end: true`

## Implementation Checklist

- [ ] Secret key only on server, publishable key on client
- [ ] Webhook signature verification on every endpoint
- [ ] Idempotency keys on all create/update API calls
- [ ] Webhook endpoint returns 200 within 5 seconds
- [ ] Failed webhooks have retry/dead-letter strategy
- [ ] Prices created in Stripe Dashboard or via API (not hardcoded)
- [ ] Test mode used during development (`sk_test_`)
- [ ] Stripe CLI for local webhook testing (`stripe listen --forward-to`)

## Common Mistakes

- **Trusting the success URL**: Fulfillment must happen in webhooks, not on redirect
- **Missing webhook signature verification**: Anyone can POST to your endpoint
- **Hardcoding prices**: Use Stripe Price objects; amounts change without deploys
- **Blocking webhook response**: Heavy processing must be async; return 200 fast
- **No idempotency**: Network retries can charge customers twice

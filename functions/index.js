const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { defineString } = require('firebase-functions/params');
const admin = require('firebase-admin');

admin.initializeApp();

// Définir le paramètre d'environnement pour le webhook Slack
const slackWebhookUrl = defineString('SLACK_WEBHOOK_URL');

exports.onNewOrderNotifySlack = onDocumentCreated(
  'restaurants/{rid}/orders/{oid}',
  async (event) => {
    const snap = event.data;
    if (!snap) {
      console.log('No data associated with the event');
      return;
    }

    const { rid, oid } = event.params;
    const data = snap.data() || {};
    
    const webhookUrl = slackWebhookUrl.value();
    if (!webhookUrl) {
      console.error('Slack webhook manquant');
      return;
    }

    const items = Array.isArray(data.items) ? data.items : [];
    const currency = (data.currency || 'ILS').toString();
    const tableNum = (String(data.table || 'table?')).replace(/^table/, '');
    const total = typeof data.total === 'number' ? data.total.toFixed(0) : String(data.total || '0');

    const lines = items.slice(0, 8).map(i => {
      const qty = i.quantity ?? 1;
      const name = i.name ?? '';
      const price = Number(i.price ?? 0);
      const subtotal = (price * qty).toFixed(0);
      return `• ${qty}× ${name} — ${subtotal} ${currency}`;
    });

    const text = [
      `🍽️ *Nouvelle commande*`,
      `• *Table:* ${tableNum}`,
      `• *Total:* ${total} ${currency}`,
      '',
      ...lines
    ].join('\n');

    try {
      const response = await fetch(webhookUrl, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ text })
      });

      await snap.ref.set({
        channel: {
          ...(data.channel || {}),
          slack: {
            sent: response.ok,
            at: admin.firestore.FieldValue.serverTimestamp()
          }
        }
      }, { merge: true });

      console.log(`Slack notification sent for order ${oid}`);

    } catch (err) {
      console.error('Slack error:', err);
      await snap.ref.set({
        channel: {
          ...(data.channel || {}),
          slack: {
            sent: false,
            error: String(err),
            at: admin.firestore.FieldValue.serverTimestamp()
          }
        }
      }, { merge: true });
    }
  }
);
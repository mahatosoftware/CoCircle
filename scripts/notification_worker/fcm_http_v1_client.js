const { GoogleAuth } = require('google-auth-library');

class FcmHttpV1Client {
  constructor({ projectId, credentials, authClient } = {}) {
    this.projectId = projectId;
    this.auth = authClient || new GoogleAuth({
      credentials,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });
    this._client = null;
  }

  async getAccessToken() {
    if (!this._client) {
      this._client = await this.auth.getClient();
    }
    const tokenResponse = await this._client.getAccessToken();
    return tokenResponse.token;
  }

  /**
   * Dispatches a single message via FCM HTTP v1 REST endpoint.
   * Endpoint: POST https://fcm.googleapis.com/v1/projects/{project_id}/messages:send
   */
  async sendMessage({ token, notification, data = {}, androidPriority = 'HIGH' }) {
    if (!token) {
      return { success: false, invalidToken: true, error: 'Empty token' };
    }

    const accessToken = await this.getAccessToken();
    const url = `https://fcm.googleapis.com/v1/projects/${this.projectId}/messages:send`;

    // Ensure all data values are stringified per FCM v1 specifications
    const stringData = {};
    for (const [key, value] of Object.entries(data)) {
      stringData[key] = value != null ? String(value) : '';
    }

    const payload = {
      message: {
        token,
        notification: {
          title: notification.title || '',
          body: notification.body || '',
        },
        data: stringData,
        android: {
          priority: androidPriority,
          notification: {
            channel_id: 'cocircle_expense_alerts',
            default_sound: true,
            notification_priority: 'PRIORITY_HIGH',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      },
    };

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      });

      const bodyText = await response.text();
      let json = {};
      try {
        json = JSON.parse(bodyText);
      } catch (_) {}

      if (response.ok) {
        return { success: true, messageId: json.name };
      }

      const status = response.status;
      const errorDetails = (json.error && json.error.details) ? JSON.stringify(json.error.details) : '';
      const errorCode = (json.error && json.error.status) ? json.error.status : '';
      const errorMessage = (json.error && json.error.message) ? json.error.message : bodyText;

      // Classify error type
      const isInvalidToken =
        status === 404 ||
        errorCode === 'UNREGISTERED' ||
        errorCode === 'INVALID_ARGUMENT' ||
        errorMessage.includes('not a valid FCM registration token') ||
        errorMessage.includes('Requested entity was not found') ||
        errorDetails.includes('UNREGISTERED');

      const isRetryable =
        status === 429 ||
        status === 503 ||
        errorCode === 'RESOURCE_EXHAUSTED' ||
        errorCode === 'UNAVAILABLE';

      const isFatalAuth = status === 401 || status === 403;

      return {
        success: false,
        status,
        invalidToken: isInvalidToken,
        retryable: isRetryable,
        fatalAuth: isFatalAuth,
        error: errorMessage,
      };
    } catch (netErr) {
      return {
        success: false,
        retryable: true,
        error: netErr.message,
      };
    }
  }
}

module.exports = { FcmHttpV1Client };

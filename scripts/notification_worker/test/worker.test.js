const { expect } = require('chai');
const sinon = require('sinon');
const { FcmHttpV1Client } = require('../fcm_http_v1_client');
const { EventProcessor, EVENT_STATUS } = require('../event_processor');

describe('CoCircle GitHub Actions + FCM HTTP v1 Notification Worker Test Suite', () => {
  let mockDb;
  let mockFcmClient;

  beforeEach(() => {
    mockDb = {
      collection: sinon.stub().callsFake((name) => ({
        doc: sinon.stub().callsFake((id) => ({
          id,
          get: sinon.stub().resolves({ exists: false }),
          set: sinon.stub().resolves(),
          update: sinon.stub().resolves(),
        })),
      })),
      getAll: sinon.stub(),
      runTransaction: sinon.stub(),
      batch: sinon.stub().returns({
        set: sinon.stub(),
        commit: sinon.stub().resolves(),
      }),
    };

    mockFcmClient = {
      sendMessage: sinon.stub().resolves({ success: true, messageId: 'msg_123' }),
    };
  });

  afterEach(() => {
    sinon.restore();
  });

  describe('1. FCM HTTP v1 Client Tests', () => {
    it('sends message with valid token and returns success', async () => {
      const mockAuth = {
        getClient: sinon.stub().resolves({
          getAccessToken: sinon.stub().resolves({ token: 'mock_oauth_token' }),
        }),
      };

      const client = new FcmHttpV1Client({ projectId: 'test-project', authClient: mockAuth });
      sinon.stub(global, 'fetch').resolves({
        ok: true,
        status: 200,
        text: sinon.stub().resolves(JSON.stringify({ name: 'projects/test-project/messages/msg_1' })),
      });

      const res = await client.sendMessage({
        token: 'device_token_abc',
        notification: { title: 'New expense added', body: 'Debasish added ₹2,500' },
        data: { tripId: 't1', expenseId: 'e1' },
      });

      expect(res.success).to.be.true;
      expect(res.messageId).to.equal('projects/test-project/messages/msg_1');
    });

    it('classifies 404 / UNREGISTERED as invalidToken', async () => {
      const mockAuth = {
        getClient: sinon.stub().resolves({
          getAccessToken: sinon.stub().resolves({ token: 'mock_oauth_token' }),
        }),
      };

      const client = new FcmHttpV1Client({ projectId: 'test-project', authClient: mockAuth });
      sinon.stub(global, 'fetch').resolves({
        ok: false,
        status: 404,
        text: sinon.stub().resolves(JSON.stringify({
          error: { code: 404, message: 'Requested entity was not found', status: 'UNREGISTERED' },
        })),
      });

      const res = await client.sendMessage({
        token: 'stale_token_dead',
        notification: { title: 'Test', body: 'Test' },
      });

      expect(res.success).to.be.false;
      expect(res.invalidToken).to.be.true;
    });

    it('classifies 429 / RESOURCE_EXHAUSTED as retryable', async () => {
      const mockAuth = {
        getClient: sinon.stub().resolves({
          getAccessToken: sinon.stub().resolves({ token: 'mock_oauth_token' }),
        }),
      };

      const client = new FcmHttpV1Client({ projectId: 'test-project', authClient: mockAuth });
      sinon.stub(global, 'fetch').resolves({
        ok: false,
        status: 429,
        text: sinon.stub().resolves(JSON.stringify({
          error: { code: 429, message: 'Quota exceeded', status: 'RESOURCE_EXHAUSTED' },
        })),
      });

      const res = await client.sendMessage({
        token: 'token_1',
        notification: { title: 'Test', body: 'Test' },
      });

      expect(res.success).to.be.false;
      expect(res.retryable).to.be.true;
    });
  });

  describe('2. Event Processor & State Machine Tests', () => {
    it('claims pending event atomically and updates status to processing', async () => {
      const processor = new EventProcessor({ db: mockDb, fcmClient: mockFcmClient, workerId: 'w1' });

      mockDb.runTransaction.callsFake(async (callback) => {
        const mockTransaction = {
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({ status: 'pending', attempts: 0 }),
          }),
          update: sinon.stub(),
        };
        return callback(mockTransaction);
      });

      const claimed = await processor.claimEvent({ id: 'evt_1' });
      expect(claimed).to.not.be.null;
      expect(claimed.attempts).to.equal(1);
    });

    it('recovers abandoned event when lease is expired (>10 minutes)', async () => {
      const processor = new EventProcessor({ db: mockDb, fcmClient: mockFcmClient, workerId: 'w2' });

      mockDb.runTransaction.callsFake(async (callback) => {
        const elevenMinutesAgo = Date.now() - (11 * 60 * 1000);
        const mockTransaction = {
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({
              status: 'processing',
              attempts: 1,
              leasedAt: { toMillis: () => elevenMinutesAgo },
            }),
          }),
          update: sinon.stub(),
        };
        return callback(mockTransaction);
      });

      const claimed = await processor.claimEvent({ id: 'evt_stale' });
      expect(claimed).to.not.be.null;
      expect(claimed.attempts).to.equal(2);
    });

    it('rejects claiming an event already actively leased (<10 minutes)', async () => {
      const processor = new EventProcessor({ db: mockDb, fcmClient: mockFcmClient, workerId: 'w3' });

      mockDb.runTransaction.callsFake(async (callback) => {
        const twoMinutesAgo = Date.now() - (2 * 60 * 1000);
        const mockTransaction = {
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({
              status: 'processing',
              attempts: 1,
              leasedAt: { toMillis: () => twoMinutesAgo },
            }),
          }),
          update: sinon.stub(),
        };
        return callback(mockTransaction);
      });

      const claimed = await processor.claimEvent({ id: 'evt_active' });
      expect(claimed).to.be.null;
    });
  });

  describe('3. Recipient Resolution, Preferences, & Privacy', () => {
    it('excludes creator and validates current trip and circle membership', async () => {
      const processor = new EventProcessor({ db: mockDb, fcmClient: mockFcmClient });

      mockDb.collection.withArgs('trips').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({ circleId: 'c1', participantIds: ['userCreator', 'userActive', 'userRemovedFromCircle'] }),
          }),
        }),
      });
      mockDb.collection.withArgs('circles').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({ memberIds: ['userCreator', 'userActive', 'userUnrelated'] }),
          }),
        }),
      });
      mockDb.getAll.resolves([
        {
          exists: true,
          id: 'userActive',
          data: () => ({ displayName: 'Active Member', fcmTokens: ['token_active'] }),
        },
      ]);

      const event = {
        tripId: 't1',
        circleId: 'c1',
        createdBy: 'userCreator',
        metadata: {},
      };

      const result = await processor.resolveRecipients(event);
      expect(result.recipients).to.have.lengthOf(1);
      expect(result.recipients[0].uid).to.equal('userActive');
    });

    it('respects lock-screen privacy by masking amounts when hideAmountsOnLockScreen is true', async () => {
      const processor = new EventProcessor({ db: mockDb, fcmClient: mockFcmClient });

      const mockEventRef = { update: sinon.stub().resolves() };
      const eventDoc = {
        ref: mockEventRef,
        data: () => ({
          eventId: 'evt_priv_1',
          eventType: 'expense_created',
          tripId: 't1',
          circleId: 'c1',
          expenseId: 'exp_priv',
          createdBy: 'creator_1',
          status: 'pending',
          metadata: { title: 'Hotel Stay', amount: 8000 },
        }),
      };

      sinon.stub(processor, 'claimEvent').resolves(eventDoc.data());
      sinon.stub(processor, 'resolveRecipients').resolves({
        recipients: [
          {
            uid: 'userPrivate',
            displayName: 'Private User',
            hideAmountsOnLockScreen: true,
            tokens: ['token_priv'],
          },
        ],
        tripData: { name: 'Goa Trip' },
        circleData: { currency: '₹' },
      });

      const res = await processor.processEvent(eventDoc);
      expect(res.completed).to.be.true;

      const fcmArgs = mockFcmClient.sendMessage.firstCall.args[0];
      expect(fcmArgs.notification.body).to.not.include('₹8,000');
      expect(fcmArgs.notification.body).to.include('updated arrangements for "Hotel Stay" in Goa Trip');
    });

    it('tracks partial delivery and does not resend to already delivered recipients on retry', async () => {
      const processor = new EventProcessor({ db: mockDb, fcmClient: mockFcmClient });

      const mockEventRef = { update: sinon.stub().resolves() };
      const eventDoc = {
        ref: mockEventRef,
        data: () => ({
          eventId: 'evt_partial_1',
          eventType: 'expense_created',
          tripId: 't1',
          circleId: 'c1',
          expenseId: 'exp_1',
          createdBy: 'creator_1',
          status: 'retryable',
          deliveredRecipients: ['userA'], // userA was delivered before crash
          metadata: { title: 'Dinner', amount: 1500 },
        }),
      };

      sinon.stub(processor, 'claimEvent').resolves(eventDoc.data());
      sinon.stub(processor, 'resolveRecipients').resolves({
        recipients: [
          { uid: 'userA', displayName: 'User A', tokens: ['tok_a'] },
          { uid: 'userB', displayName: 'User B', tokens: ['tok_b'] },
        ],
        tripData: { name: 'Trip' },
        circleData: { currency: '₹' },
      });

      const res = await processor.processEvent(eventDoc);
      expect(res.completed).to.be.true;

      // Only userB should have received a notification
      expect(mockFcmClient.sendMessage.calledOnce).to.be.true;
      expect(mockFcmClient.sendMessage.firstCall.args[0].token).to.equal('tok_b');
    });

    it('prunes dead FCM tokens when FCM HTTP v1 returns invalidToken', async () => {
      mockFcmClient.sendMessage.resolves({
        success: false,
        invalidToken: true,
        error: 'Requested entity was not found',
      });

      const processor = new EventProcessor({ db: mockDb, fcmClient: mockFcmClient });
      const mockEventRef = { update: sinon.stub().resolves() };
      const eventDoc = {
        ref: mockEventRef,
        data: () => ({
          eventId: 'evt_dead_1',
          eventType: 'expense_created',
          tripId: 't1',
          circleId: 'c1',
          expenseId: 'exp_1',
          createdBy: 'creator_1',
          status: 'pending',
          metadata: { title: 'Lunch', amount: 500 },
        }),
      };

      sinon.stub(processor, 'claimEvent').resolves(eventDoc.data());
      sinon.stub(processor, 'resolveRecipients').resolves({
        recipients: [
          { uid: 'userStale', displayName: 'Stale User', tokens: ['dead_token_123'] },
        ],
        tripData: { name: 'Trip' },
        circleData: { currency: '₹' },
      });

      const res = await processor.processEvent(eventDoc);
      expect(res.completed).to.be.true;
      expect(res.cleanedTokens).to.equal(1);
      expect(res.notificationsFailed).to.equal(1);
    });
  });
});

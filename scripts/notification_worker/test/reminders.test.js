const { expect } = require('chai');
const sinon = require('sinon');
const { RemindersProcessor } = require('../reminders_processor');

describe('CoCircle Anti-Irritation Scheduled Reminders Test Suite', () => {
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
        where: sinon.stub().returns({
          get: sinon.stub().resolves({ docs: [], size: 0 }),
        }),
      })),
      getAll: sinon.stub(),
    };

    mockFcmClient = {
      sendMessage: sinon.stub().resolves({ success: true, messageId: 'msg_reminder' }),
    };
  });

  afterEach(() => {
    sinon.restore();
  });

  describe('1. Quiet Hours Evaluator', () => {
    it('defers notification when user local time is 11 PM (23:00)', () => {
      const processor = new RemindersProcessor({ db: mockDb, fcmClient: mockFcmClient });
      // Stub current time to 17:30 UTC -> in IST (+330 min) that is 23:00 (11 PM)
      sinon.stub(Date, 'now').returns(new Date('2026-11-21T17:30:00Z').getTime());

      const inQuiet = processor.isQuietHours({
        notificationPreferences: { quietHoursEnabled: true },
        timezoneOffsetMinutes: 330, // IST
      });

      expect(inQuiet).to.be.true;
    });

    it('allows notification when user local time is 2 PM (14:00)', () => {
      const processor = new RemindersProcessor({ db: mockDb, fcmClient: mockFcmClient });
      // 08:30 UTC -> in IST (+330 min) that is 14:00 (2 PM)
      sinon.stub(Date, 'now').returns(new Date('2026-11-21T08:30:00Z').getTime());

      const inQuiet = processor.isQuietHours({
        notificationPreferences: { quietHoursEnabled: true },
        timezoneOffsetMinutes: 330,
      });

      expect(inQuiet).to.be.false;
    });

    it('bypasses quiet hours when user explicitly disabled quietHoursEnabled', () => {
      const processor = new RemindersProcessor({ db: mockDb, fcmClient: mockFcmClient });
      sinon.stub(Date, 'now').returns(new Date('2026-11-21T17:30:00Z').getTime());

      const inQuiet = processor.isQuietHours({
        notificationPreferences: { quietHoursEnabled: false },
        timezoneOffsetMinutes: 330,
      });

      expect(inQuiet).to.be.false;
    });
  });

  describe('2. Upcoming Trip Milestone Reminders', () => {
    it('dispatches reminder at 24h milestone and commits delivery log', async () => {
      const processor = new RemindersProcessor({ db: mockDb, fcmClient: mockFcmClient });
      const nowMs = new Date('2026-11-21T10:00:00Z').getTime();
      sinon.stub(Date, 'now').returns(nowMs);

      // Trip departs exactly in 24 hours
      const tripStartDate = new Date(nowMs + 24 * 60 * 60 * 1000);
      const tripDoc = {
        id: 'trip_goa_1',
        data: () => ({
          name: 'Goa Weekend Trip',
          startDate: { toMillis: () => tripStartDate.getTime() },
          participantIds: ['user_rahul'],
          isActive: true,
          status: 'confirmed',
        }),
      };

      mockDb.collection.withArgs('trips').returns({
        where: sinon.stub().returns({
          get: sinon.stub().resolves({ docs: [tripDoc], size: 1 }),
        }),
      });

      mockDb.collection.withArgs('notification_delivery_log').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({ exists: false }), // Not yet delivered
          set: sinon.stub().resolves(),
        }),
      });

      mockDb.collection.withArgs('users').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({
              displayName: 'Rahul',
              fcmTokens: ['tok_rahul'],
              notificationPreferences: { tripRemindersEnabled: true, quietHoursEnabled: false },
            }),
          }),
        }),
      });

      const res = await processor.processUpcomingTripReminders();
      expect(res.sent).to.equal(1);
      expect(mockFcmClient.sendMessage.calledOnce).to.be.true;

      const fcmArgs = mockFcmClient.sendMessage.firstCall.args[0];
      expect(fcmArgs.notification.title).to.include('Upcoming Trip: Goa Weekend Trip');
      expect(fcmArgs.notification.body).to.include('departs tomorrow');
    });

    it('skips trip reminder if already recorded in delivery log', async () => {
      const processor = new RemindersProcessor({ db: mockDb, fcmClient: mockFcmClient });
      const nowMs = new Date('2026-11-21T10:00:00Z').getTime();
      sinon.stub(Date, 'now').returns(nowMs);

      const tripStartDate = new Date(nowMs + 24 * 60 * 60 * 1000);
      const tripDoc = {
        id: 'trip_goa_1',
        data: () => ({
          name: 'Goa Weekend Trip',
          startDate: { toMillis: () => tripStartDate.getTime() },
          participantIds: ['user_rahul'],
          isActive: true,
        }),
      };

      mockDb.collection.withArgs('trips').returns({
        where: sinon.stub().returns({
          get: sinon.stub().resolves({ docs: [tripDoc], size: 1 }),
        }),
      });

      mockDb.collection.withArgs('notification_delivery_log').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({ exists: true }), // ALREADY DELIVERED!
        }),
      });

      const res = await processor.processUpcomingTripReminders();
      expect(res.sent).to.equal(0);
      expect(res.skipped).to.equal(1);
      expect(mockFcmClient.sendMessage.called).to.be.false;
    });
  });

  describe('3. Poll Closing Reminders & Unvoted Member Filtering', () => {
    it('notifies only unvoted members and excludes members who already voted', async () => {
      const processor = new RemindersProcessor({ db: mockDb, fcmClient: mockFcmClient });
      const nowMs = new Date('2026-11-21T10:00:00Z').getTime();
      sinon.stub(Date, 'now').returns(nowMs);

      // Poll closes in 1 hour
      const deadline = new Date(nowMs + 60 * 60 * 1000);
      const pollDoc = {
        id: 'poll_dinner_1',
        data: () => ({
          tripId: 'trip_1',
          question: 'Where should we eat Dinner?',
          deadline: { toMillis: () => deadline.getTime() },
          isActive: true,
          votes: {
            user_has_voted: [0], // user_has_voted already voted!
          },
        }),
      };

      mockDb.collection.withArgs('polls').returns({
        where: sinon.stub().returns({
          get: sinon.stub().resolves({ docs: [pollDoc], size: 1 }),
        }),
      });

      mockDb.collection.withArgs('trips').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({ participantIds: ['user_has_voted', 'user_not_voted'] }),
          }),
        }),
      });

      mockDb.collection.withArgs('notification_delivery_log').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({ exists: false }),
          set: sinon.stub().resolves(),
        }),
      });

      mockDb.collection.withArgs('users').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({
              displayName: 'Unvoted User',
              fcmTokens: ['tok_unvoted'],
              notificationPreferences: { pollRemindersEnabled: true, quietHoursEnabled: false },
            }),
          }),
        }),
      });

      const res = await processor.processPollClosingReminders();

      // Only user_not_voted receives the reminder!
      expect(res.sent).to.equal(1);
      expect(res.skipped).to.equal(1); // user_has_voted skipped
      expect(mockFcmClient.sendMessage.calledOnce).to.be.true;

      const fcmArgs = mockFcmClient.sendMessage.firstCall.args[0];
      expect(fcmArgs.notification.title).to.include('Poll Closing Soon: Where should we eat Dinner?');
      expect(fcmArgs.notification.body).to.include('closes in 1 hour');
    });
  });

  describe('4. Pending Task Daily Digest Reminders', () => {
    it('groups multiple open tasks into a single digest and guarantees max once per 24 hours', async () => {
      const processor = new RemindersProcessor({ db: mockDb, fcmClient: mockFcmClient });

      const task1 = { id: 'task_1', data: () => ({ tripId: 'trip_1', title: 'Book Zoomcar', assignedTo: 'user_dev', isCompleted: false }) };
      const task2 = { id: 'task_2', data: () => ({ tripId: 'trip_1', title: 'Pack First-Aid Box', assignedTo: 'user_dev', isCompleted: false }) };

      mockDb.collection.withArgs('tasks').returns({
        where: sinon.stub().returns({
          get: sinon.stub().resolves({ docs: [task1, task2], size: 2 }),
        }),
      });

      mockDb.collection.withArgs('trips').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({ name: 'Goa Trip' }),
          }),
        }),
      });

      mockDb.collection.withArgs('notification_delivery_log').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({ exists: false }),
          set: sinon.stub().resolves(),
        }),
      });

      mockDb.collection.withArgs('users').returns({
        doc: sinon.stub().returns({
          get: sinon.stub().resolves({
            exists: true,
            data: () => ({
              displayName: 'Dev',
              fcmTokens: ['tok_dev'],
              notificationPreferences: { taskRemindersEnabled: true, quietHoursEnabled: false },
            }),
          }),
        }),
      });

      const res = await processor.processPendingTaskReminders();

      // Exactly 1 digest message sent for both tasks!
      expect(res.sent).to.equal(1);
      expect(mockFcmClient.sendMessage.calledOnce).to.be.true;

      const fcmArgs = mockFcmClient.sendMessage.firstCall.args[0];
      expect(fcmArgs.notification.title).to.equal('2 Pending Tasks: Goa Trip');
      expect(fcmArgs.notification.body).to.include('You have 2 open tasks for Goa Trip: "Book Zoomcar" and 1 more.');
    });
  });
});

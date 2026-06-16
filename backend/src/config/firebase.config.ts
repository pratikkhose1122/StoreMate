import { Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';

const logger = new Logger('FirebaseConfig');

/**
 * Initializes Firebase Admin SDK.
 *
 * For ID token verification, only the projectId is required.
 * A full service account is needed only for operations like
 * custom token creation, FCM, etc.
 */
export function initializeFirebase(projectId: string): void {
  if (admin.apps.length > 0) {
    logger.log('Firebase Admin SDK already initialized.');
    return;
  }

  if (!projectId || projectId === 'your_firebase_project_id') {
    logger.warn(
      'FIREBASE_PROJECT_ID is not configured. ' +
        'Firebase token verification will fail. ' +
        'Set FIREBASE_PROJECT_ID in your .env file.',
    );
  }

  admin.initializeApp({
    projectId,
  });

  logger.log(`Firebase Admin SDK initialized for project: ${projectId}`);
}

/**
 * Verifies a Firebase ID token and returns the decoded token.
 * Throws an error if verification fails.
 */
export async function verifyFirebaseToken(
  idToken: string,
): Promise<admin.auth.DecodedIdToken> {
  return admin.auth().verifyIdToken(idToken);
}

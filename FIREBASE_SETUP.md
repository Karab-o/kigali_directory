# Firebase setup – Authentication & Firestore

Follow these steps so sign-up and login work and your app stays connected to Firebase Authentication and Cloud Firestore.

---

## 1. Use the correct Firebase project

Your app is already configured for project **`indivassign2`** (`firebase_options.dart` and `google-services.json`).  
Use that same project in the steps below.

---

## 2. Enable Email/Password sign-in (fixes “Authentication error”)

The “Authentication error. Please try again.” (or similar) on sign-up usually means **Email/Password sign-in is not enabled** in Firebase.

1. Open [Firebase Console](https://console.firebase.google.com/).
2. Select project **indivassign2** (or your project).
3. Go to **Build → Authentication**.
4. Open the **Sign-in method** tab.
5. Click **Email/Password**.
6. Turn **Enable** ON.
7. Leave “Email link” off if you only use email + password.
8. Click **Save**.

After this, sign-up and login with email/password will work from the app.

---

## 2b. Verification email not arriving?

Firebase sends the verification email from **noreply@*yourproject*.firebaseapp.com**. Many providers treat this as low-trust, so the email often goes to **Spam** or **Junk**.

**What to do:**
1. **Check Spam / Junk** for an email from Firebase.
2. In the app, **sign in** with the account you created → you’ll see the **Verify email** screen. Tap **“Resend verification email”** and check your inbox and spam again.
3. (Optional) In Firebase Console go to **Authentication → Templates**. You can edit the “Email address verification” template and, if you have one, set a **custom SMTP** so emails come from your own domain and are less likely to be filtered.

---

## 3. Firestore security rules (so profile and listings work)

Your app:

- Writes the user profile to **`users/{userId}`** on sign-up.
- Reads/writes **`listings`** and **`listings/{id}/reviews`**.

Rules must allow these operations for signed-in users.

1. In Firebase Console go to **Build → Firestore Database**.
2. Open the **Rules** tab.
3. Use one of the rule sets below.

**Option A – Simple (good for development)**

- Any signed-in user can read/write `users` and `listings` (and reviews).

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
        && resource.data.createdBy == request.auth.uid;
      match /reviews/{reviewId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
      }
    }
  }
}
```

**Option B – Stricter (recommended for production)**

- Users can only read/write their own `users/{userId}` doc.
- Listings: anyone signed-in can read; only the creator can update/delete.
- Reviews: anyone signed-in can read; signed-in users can create.

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
        && resource.data.createdBy == request.auth.uid;
      match /reviews/{reviewId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
      }
    }
  }
}
```

4. Click **Publish**.

If rules are wrong, you’ll see errors like “Permission denied” or “Firebase error … Check Firestore rules” in the app (the updated auth service will show a clearer message).

---

## 4. Create Firestore (if you haven’t already)

1. **Build → Firestore Database**.
2. If you see “Create database”:
   - Click it, choose **Start in test mode** (or production and then set rules as in step 3), pick a location, then **Enable**.

No need to create `users` or `listings` collections by hand; the app creates them when the first user signs up and when the first listing is added.

---

## 5. Check connectivity

- **Device/emulator**: ensure it has internet (Wi‑Fi or mobile data).
- **Emulator**: use an image with **Google Play** (and Google APIs) so Firebase works correctly.
- **Android**: your `applicationId` in `build.gradle.kts` must match the Android app in Firebase (`com.example.individual_assignment2` in your `google-services.json`). It already does.

---

## 6. What the app does (backend integration)

- **Sign up**:  
  Firebase Auth creates the user → app sends verification email → app updates display name → app writes **`users/{uid}`** in Firestore (profile). This links the authenticated user to a Firestore profile as required.
- **Log in**:  
  Firebase Auth only; then the app loads profile from **`users/{uid}`**.
- **Listings**:  
  All listing create/read/update/delete go through **Firestore**; each listing has **`createdBy`** set to the current user’s UID so only the owner can update/delete.

If something still fails, the app will now show a **more specific error** (e.g. “Email/password sign-in is not enabled…”, “Permission denied…”, “No internet…”). Use that message to see whether the problem is Auth, Firestore rules, or network.

---

## Quick checklist

- [ ] Firebase project is **indivassign2** (or the one in your config).
- [ ] **Authentication → Sign-in method**: **Email/Password** is **Enabled**.
- [ ] **Firestore** database is **created**.
- [ ] **Firestore → Rules**: rules allow read/write for `users/{userId}` and the `listings` (and reviews) pattern above.
- [ ] Device/emulator has **internet** and (on Android) uses a **Google Play** image if using an emulator.

After that, try **Sign up** again; you should either succeed or see a clear error explaining what to fix.
